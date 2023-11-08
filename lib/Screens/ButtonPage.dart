import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Services/API.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key, required this.user, required this.socket});
  final Driver user;
  final IO.Socket socket;
  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage>
    with SingleTickerProviderStateMixin {
  bool isOn = false;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    getState();
    _handleLocationPermission();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      Future.delayed(
          const Duration(seconds: 30), () => _handleLocationPermission());
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        Future.delayed(
            const Duration(seconds: 2), () => _handleLocationPermission());
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, please enable it from settings.')));
      Future.delayed(
          const Duration(seconds: 2), () => _handleLocationPermission());
      return false;
    }
    getUserPosition();
    return true;
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
      if (mounted) {
        setState(() {
          userPosition = location!;
        });
      }
    }
  }

  _updateLocation() async {
    if (userPosition != null) {
      print("here");
      widget.socket.emit("locationUpdate", {
        "userId": widget.user.id,
        "latitude": userPosition!.latitude,
        "longtitude": userPosition!.longitude
      });
      if (isOn) {
        Future.delayed(const Duration(minutes: 5), () => {getUserPosition()});
        Future.delayed(const Duration(minutes: 6), () => {_updateLocation()});
      }
    }
  }

  getState() async {
    bool result = await API.getState(context, widget.user.id);
    setState(() {
      isOn = result;
    });
  }

  changeState() async {
    bool result = await API.turnOn(context, !isOn, widget.user.id);
    setState(() {
      isOn = result;
    });
    if (isOn) {
      _updateLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return userPosition != null
        ? Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // Color of the shadow
                          offset: Offset(0, 2), // Offset of the shadow (x, y)
                          blurRadius: 5, // Spread of the shadow
                          spreadRadius: 3, // Extent of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black54),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Today's income",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "0.00 DA",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isOn
                            ? const Color.fromARGB(255, 115, 207, 118)
                            : Colors.blue, // Change shadow color here
                        blurRadius: 10,
                        spreadRadius: isOn ? 20 : 0, // Control shadow spread
                      ),
                    ],
                  ),
                  child: AnimatedIconButton(
                    size: 100,
                    onPressed: () {
                      changeState();
                    },
                    duration: const Duration(milliseconds: 500),
                    initialIcon: !isOn ? 0 : 1,
                    splashColor: Colors.green,
                    icons: const <AnimatedIconItem>[
                      AnimatedIconItem(
                        backgroundColor: Colors.black,
                        icon: Icon(Icons.power_settings_new_outlined,
                            color: Colors.purple),
                      ),
                      AnimatedIconItem(
                        backgroundColor: Colors.black,
                        icon: Icon(Icons.close, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                // AnimatedIconButton
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
