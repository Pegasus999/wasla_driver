import 'dart:async';
import "dart:math";
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasla_driver/Constants.dart';
import 'package:wasla_driver/Screens/HomePage.dart';
import 'package:wasla_driver/Services/API.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Position? userPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool accepted = false;
  bool ended = false;
  bool arrived = false;
  bool onRoad = false;
  Set<Marker> _markers = Set<Marker>();
  List<LatLng> points = [];
  Set<Polyline> _polylines = Set<Polyline>();
  late PolylinePoints polylinePoints;

  @override
  void initState() {
    super.initState();
    getTrip();
    getUserPosition();
    polylinePoints = PolylinePoints();
  }

  getUserPosition() async {
    if (userPosition == null) {
      Position? location;
      try {
        location = await Geolocator.getCurrentPosition();
      } catch (e) {
        // Handle any errors that may occur when getting the location.
        print("Error getting user location: $e");
      }
      print(location);
      if (mounted) {
        setState(() {
          userPosition = location!;
        });
      }
    }
  }

  getTrip() async {
    List<LatLng> list = await API.getClient();
    setState(() {
      points = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [_map(), _bottomContrainer()],
          ),
        ),
      ),
    );
  }

  _map() {
    return GoogleMap(
      markers: _markers,
      polylines: _polylines,
      mapType: MapType.normal,
      initialCameraPosition:
          CameraPosition(target: LatLng(36.805537, 7.713936), zoom: 15),
      onMapCreated: (controller) {
        _controller.complete(controller);
        setPolylines();
      },
    );
  }

  void openGoogleMaps() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${points[0].latitude},${points[0].longitude}';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      await launchUrl(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.google.android.apps.maps&pcampaignid=web_share"));
    }
  }

  markers() {
    setState(() {
      _markers = Set();
      _markers.addAll([
        Marker(
            markerId: MarkerId('client'),
            position: points[0],
            icon: BitmapDescriptor.defaultMarkerWithHue(150)),
        Marker(markerId: MarkerId('destinationPin'), position: points[1])
      ]);
    });
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(points[0].latitude, points[0].longitude),
      PointLatLng(points[1].latitude, points[1].longitude),
    );
    List<LatLng> polylineCoordinates = [];
    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _markers.addAll([
          Marker(
              markerId: const MarkerId('client'),
              position: points[0],
              icon: BitmapDescriptor.defaultMarkerWithHue(100)),
          Marker(
            markerId: const MarkerId('destinationPin'),
            position: points[1],
          )
        ]);
        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('trip'),
            color: const Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  double calculatePolylineLength(List<LatLng> polylineCoordinates) {
    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      final LatLng p1 = polylineCoordinates[i];
      final LatLng p2 = polylineCoordinates[i + 1];
      final distance = Geolocator.distanceBetween(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
      totalDistance += distance;
    }

    return totalDistance;
  }

  void editPolylines(LatLng point) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(userPosition!.latitude, userPosition!.longitude),
      PointLatLng(point.latitude, point.longitude),
    );
    List<LatLng> polylineCoordinates = [];
    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      double length = calculatePolylineLength(polylineCoordinates);
      print(length);
      if (length < 100) {
        if (!arrived) {
          setState(() {
            arrived = true;
          });
        } else {
          setState(() {
            ended = true;
            onRoad = false;
          });
          return;
        }
      }

      setState(() {
        _polylines = {};
        _markers = {};
        _markers.addAll([
          Marker(
              markerId: const MarkerId('client'),
              position: point,
              icon: BitmapDescriptor.defaultMarkerWithHue(100)),
          Marker(
              markerId: const MarkerId('me'),
              position: LatLng(userPosition!.latitude, userPosition!.longitude))
        ]);

        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('client'),
            color: const Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
    getUserPosition();
    if (!arrived || onRoad) {
      Future.delayed(const Duration(minutes: 2), () => editPolylines(point));
    }
  }

  _bottomContrainer() {
    return Positioned(
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(color: Colors.black),
            color: Colors.white,
          ),
          child: accepted ? order() : request(),
        ),
      ),
    );
  }

  String calculateDistance() {
    const double radius = 6371; // Earth's radius in kilometers
    final double lat1 = points[0].latitude;
    final double lon1 = points[0].longitude;
    final double lat2 = points[1].latitude;
    final double lon2 = points[1].longitude;

    final double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    final double dLon = (lon2 - lon1) * (3.141592653589793 / 180);

    final double a = (0.5 - cos(dLat) / 2) +
        cos(lat1 * (3.141592653589793 / 180)) *
            cos(lat2 * (3.141592653589793 / 180)) *
            (0.5 - cos(dLon) / 2);

    double distance = 2 * radius * asin(sqrt(a));
    if (distance < 1) {
      double number = distance * 1000;
      int meters = number.round();
      return "$meters m away";
    } else {
      return "$distance km away";
    }
  }

  pickedClientUp() {
    return ended
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Did you drop the client off?!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                  },
                  child: const Text("End Trip"))
            ],
          )
        : onRoad
            ? const Center(
                child: Text("The trip is ongoing"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Did you pick up the client?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(
                    height: 30,
                    color: Colors.transparent,
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            onRoad = true;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () {
                              editPolylines(points[1]);
                            },
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.check)),
                  )
                ],
              );
  }

  Column request() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "New Order",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(
          height: 10,
          color: Colors.transparent,
        ),
        Text(points.isNotEmpty ? calculateDistance() : ""),
        const Divider(
          height: 20,
          color: Colors.transparent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  )),
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: FaIcon(FontAwesomeIcons.xmark),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (userPosition != null) {
                  setState(() {
                    accepted = true;
                  });
                  editPolylines(points[0]);
                }
              },
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: FaIcon(FontAwesomeIcons.check),
              ),
            )
          ],
        )
      ],
    );
  }

  Column order() {
    return !arrived
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Client name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 40,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ));
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: FaIcon(FontAwesomeIcons.xmark),
                      )),
                  GestureDetector(
                      onTap: () {
                        openGoogleMaps();
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple,
                        child: FaIcon(FontAwesomeIcons.route),
                      )),
                  GestureDetector(
                    onTap: () {
                      // call user
                    },
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: FaIcon(FontAwesomeIcons.phone),
                    ),
                  )
                ],
              )
            ],
          )
        : pickedClientUp();
  }
}
