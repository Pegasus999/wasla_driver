import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla_driver/Constants.dart';
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
  int today = 0;
  int month = 0;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    getState();
    getIncome();
    getUserPosition();
  }

  getIncome() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${API.base_url}driver/getIncome');
      final body = jsonEncode({'id': widget.user.id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            today = json['today'];
            month = json['month'];
          });
        }
      }
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error occured")));
    }
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

  getState() async {
    bool result = await API.getState(context, widget.user.id);
    if (mounted) {
      setState(() {
        isOn = result;
        widget.user.active = result;
      });
    }
  }

  changeState() async {
    bool result = await API.turnOn(context, !isOn, widget.user.id);
    print(result);
    setState(() {
      isOn = result;
    });
    print(isOn);

    if (isOn) {
      widget.socket.connect();
      widget.socket.emit("add", {"userId": widget.user.id});
      _updateLocation();
    }
  }

  _updateLocation() {
    if (isOn) {
      widget.socket.emit("updateLocation", {
        "userId": widget.user.id,
        "latitude": userPosition!.latitude,
        "longtitude": userPosition!.longitude
      });

      Future.delayed(const Duration(minutes: 2), () {
        _updateLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userPosition != null
        ? Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text("Monthly Income"),
                          content: SizedBox(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Today's income : $today DA"),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text("This Month's income : $month DA"),
                              ],
                            ),
                          )),
                    );
                  },
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
                        const Text(
                          "Today's income",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "$today DA",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
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
                            : Colors.transparent, // Change shadow color here
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
                    icons: <AnimatedIconItem>[
                      AnimatedIconItem(
                        backgroundColor: Colors.black,
                        icon: Icon(Icons.power_settings_new_outlined,
                            color: Constants.main),
                      ),
                      AnimatedIconItem(
                        backgroundColor: Colors.black,
                        icon: Icon(Icons.close, color: Constants.mainLight),
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
