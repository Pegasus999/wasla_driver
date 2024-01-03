import 'dart:async';
import 'dart:convert';
import "dart:math";
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasla_driver/Constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/Trip.dart';
import 'package:wasla_driver/Screens/HomePage.dart';
import 'package:wasla_driver/Services/API.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class OrderPage extends StatefulWidget {
  OrderPage({
    super.key,
    required this.trip,
    required this.socket,
    required this.user,
    this.passed,
  });
  final Trip trip;
  final Driver user;
  final IO.Socket socket;
  bool? passed;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Position? userPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool accepted = false;
  bool arrived = false;
  bool onRoad = false;
  bool clicked = false;
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  late PolylinePoints polylinePoints;

  int seconds = 0;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    getUserPosition();
    polylinePoints = PolylinePoints();
    ongoingOrder();
  }

  ongoingOrder() {
    if (widget.passed != null) {
      if (mounted) {
        setState(() {
          accepted = true;
          arrived = true;
        });
      }
    }
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          seconds++;
        });
      }
    });
  }

  void stopTimer() {
    timer.cancel();
  }

  acceptRide() {
    widget.socket.emit(
        "rideAccept", {"tripId": widget.trip.id, "userId": widget.user.id});
  }

  getUserPosition() async {
    Position? location;
    try {
      location = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          userPosition = location!;
        });
      }
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print("Error getting user location: $e");
    }
  }

  setMarkers() {
    setState(() {
      _markers = Set();
      _markers.addAll([
        Marker(
            markerId: const MarkerId("you"),
            position: LatLng(userPosition!.latitude, userPosition!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(100)),
        Marker(
            markerId: const MarkerId('client'),
            position: LatLng(widget.trip.pickUpLocationLatitude,
                widget.trip.pickUpLocationLongtitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(150)),
        Marker(
          markerId: const MarkerId('destinationPin'),
          position: LatLng(widget.trip.destinationLatitude,
              widget.trip.destinationLongtitude),
        )
      ]);
    });
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants.apiKey,
      PointLatLng(widget.trip.pickUpLocationLatitude,
          widget.trip.pickUpLocationLongtitude),
      PointLatLng(
          widget.trip.destinationLatitude, widget.trip.destinationLongtitude),
    );
    List<LatLng> polylineCoordinates = [];
    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: const PolylineId('trip'),
            color: const Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
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
      if (length < 200) {
        if (!arrived) {
          if (mounted) {
            setState(() {
              arrived = true;
            });
          }
        }
      }
      if (mounted) {
        setState(() {
          _polylines = {};
          _polylines.add(Polyline(
              width: 10,
              polylineId: const PolylineId('client'),
              color: const Color(0xFF08A5CB),
              points: polylineCoordinates));
        });
      }
    }
    Future.delayed(const Duration(minutes: 1), () {
      if (!arrived || onRoad) {
        editPolylines(point);
      }
    });
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

  void openGoogleMaps(LatLng point) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      await launchUrl(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.google.android.apps.maps&pcampaignid=web_share"));
    }
  }

  void endRide() async {
    double duration = seconds / 60;
    widget.socket.emit('rideEnd',
        {"tripId": widget.trip.id, "duration": duration.toStringAsFixed(2)});
    print("event emitted");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          user: widget.user,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showCancelDialog(),
      child: SafeArea(
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
      ),
    );
  }

  _map() {
    return userPosition != null
        ? GoogleMap(
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.trip.pickUpLocationLatitude,
                    widget.trip.pickUpLocationLongtitude),
                zoom: 15),
            onMapCreated: (controller) {
              _controller.complete(controller);
              setMarkers();
              setPolylines();
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  Positioned _bottomContrainer() {
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
    final double lat1 = userPosition!.latitude;
    final double lon1 = userPosition!.longitude;
    final double lat2 = widget.trip.pickUpLocationLatitude;
    final double lon2 = widget.trip.pickUpLocationLongtitude;

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
      return "${distance.toStringAsFixed(2)} km away";
    }
  }

  pickedClientUp() {
    return !onRoad
        ? Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          print("CALL");
                        },
                        icon: const FaIcon(FontAwesomeIcons.phone)),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: IconButton(
                        onPressed: () {
                          startTimer();
                          setState(() {
                            onRoad = true;
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.check)),
                  ),
                ],
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "The ride is ongoing !!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  style: const ButtonStyle(
                      minimumSize: MaterialStatePropertyAll(Size(150, 40))),
                  icon: const FaIcon(FontAwesomeIcons.route),
                  onPressed: () {
                    openGoogleMaps(LatLng(widget.trip.pickUpLocationLatitude,
                        widget.trip.pickUpLocationLongtitude));
                  },
                  label: const Text("Get directions")),
              ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: seconds > 60
                          ? MaterialStatePropertyAll(Constants.main)
                          : MaterialStatePropertyAll(
                              Constants.main.withOpacity(0.4)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(150, 40))),
                  icon: const FaIcon(FontAwesomeIcons.circleCheck),
                  onPressed: () {
                    if (seconds > 60) {
                      showConfirmationDialog();
                    }
                  },
                  label: const Text("End Trip"))
            ],
          );
  }

  showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Ride"),
        content: const SizedBox(
          height: 70,
          child: Center(child: Text("Have you reached your destination?")),
        ),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              if (mounted) {
                setState(() {
                  onRoad = false;
                });
              }
              stopTimer();
              endRide();
            },
          ),
        ],
      ),
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
        Text(userPosition != null ? calculateDistance() : ""),
        const Divider(
          height: 20,
          color: Colors.transparent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red[400],
              child: IconButton(
                  color: Colors.white,
                  onPressed: () {
                    showDenyDialog();
                  },
                  icon: const FaIcon(FontAwesomeIcons.xmark)),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: userPosition != null
                  ? Colors.green[400]
                  : Colors.green[400]!.withOpacity(0.4),
              child: IconButton(
                  color: Colors.white,
                  onPressed: () async {
                    if (mounted) {
                      if (!clicked) {
                        setState(() {
                          clicked = true;
                        });

                        checkTrip().then((exist) {
                          print(exist);
                          if (exist == false) {
                            return;
                          }
                          if (userPosition != null) {
                            setState(() {
                              accepted = true;
                            });
                            acceptRide();
                            editPolylines(LatLng(
                                widget.trip.pickUpLocationLatitude,
                                widget.trip.pickUpLocationLongtitude));
                          }
                        });
                      }
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.check)),
            )
          ],
        )
      ],
    );
  }

  Future<bool> checkTrip() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${API.base_url}driver/checkTrip');
      final body = jsonEncode({'tripId': widget.trip.id});
      final response = await http.post(url, headers: headers, body: body);
      final json = jsonDecode(response.body);
      print(json);
      if (json['exist'] == true) {
        return true;
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Ride Cancelled"),
              content: SizedBox(
                height: 50,
                child: Text('Sadly,${json['message'] ?? ""}'),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            user: widget.user,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text("OK"))
              ],
            ),
          );
        }
        return false;
      }
    } catch (err) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ride Cancelled"),
            content: const SizedBox(
              height: 50,
              child: Text('Sadly, an error occured'),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: widget.user,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text("OK"))
            ],
          ),
        );
      }
      return false;
    }
  }

  showDenyDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Cancel Order"),
              content: const SizedBox(
                height: 70,
                child: Center(
                    child: Text("You sure you want to refuse this request?")),
              ),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: widget.user,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ));
  }

  showCancelDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Cancel Order"),
              content: const SizedBox(
                height: 70,
                child: Center(
                    child: Text("You sure you want to cancel this ride?")),
              ),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    widget.socket.emit("rideCancel",
                        {"tripId": widget.trip.id, "userId": widget.user.id});
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          user: widget.user,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ));
  }

  order() {
    return arrived
        ? pickedClientUp()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${widget.trip.client.firstName} ${widget.trip.client.lastName}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 40,
                color: Colors.transparent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          print('HI');
                          showCancelDialog();
                        },
                        icon: const FaIcon(FontAwesomeIcons.xmark)),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          openGoogleMaps(LatLng(
                              widget.trip.pickUpLocationLatitude,
                              widget.trip.pickUpLocationLongtitude));
                        },
                        icon: const FaIcon(FontAwesomeIcons.route)),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          print("CALL");
                          startTimer();
                          setState(() {
                            arrived = true;
                            onRoad = true;
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.phone)),
                  ),
                ],
              )
            ],
          );
  }
}
