import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/Trip.dart';
import 'package:wasla_driver/Screens/ButtonPage.dart';
import 'package:wasla_driver/Screens/HistoryPage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla_driver/Screens/Orders/OrderPage.dart';
import 'package:wasla_driver/Screens/SettingsPage.dart';
import 'package:wasla_driver/Services/API.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.user});
  final Driver user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget Function(Driver user, IO.Socket socket)> pages = [
    (user, socket) => ButtonPage(
          user: user,
          socket: socket,
        ),
    (user, socket) => HistoryPage(user: user),
    (user, socket) => SettingsPage(user: user)
  ];
  int _index = 0;
  bool order = false;
  late IO.Socket socket;

  @override
  void initState() {
    initSocket();
    // TODO: implement initState
    super.initState();
    setListener();
    checkTrip();
  }

  checkTrip() async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final url = Uri.parse('${API.base_url}driver/tripCheck');
      final body = jsonEncode({'userId': widget.user.id});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        Trip trip = Trip.fromJson(json['trip']);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                user: widget.user,
                trip: trip,
                socket: socket,
                passed: true,
              ),
            ),
            (route) => false);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: const SizedBox(
                height: 50,
                child: Text('An error occured, please check your internet'),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      checkTrip();
                    },
                    child: const Text("Retry"))
              ]),
        );
      }
    }
  }

  void showNotificationAndroid(String title, String value) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'Channel Name',
            channelDescription: 'Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      value,
      notificationDetails,
      payload: 'Not present',
    );
  }

  setListener() {
    socket.on("rideRequest", (data) {
      showNotificationAndroid(
          "New Order", "you have a new ride order!! check it out.");
      if (!order && mounted) {
        Trip trip = Trip.fromJson(data['trip']);
        setState(() {
          widget.user.active = true;
          order = true;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                trip: trip,
                user: widget.user,
                socket: socket,
              ),
            ));
      }
    });
    socket.on('tripCanceled', (data) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ride Cancelled"),
            content: const SizedBox(
              height: 50,
              child: Text("Sadly, your client has cancelled your ride"),
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
    });

    socket.on('rideCancel', (data) {
      if (mounted && data['byWho'] != widget.user.id && order) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ride Cancelled"),
            content: const SizedBox(
              height: 50,
              child: Text("Sadly, your client has cancelled your ride"),
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
    });
  }

  initSocket() {
    socket = IO.io("https://wasla.online", {
      "transports": ['websocket'],
      "autoConnect": false
    });
    socket.connect();
    // socket!.emit("add", widget.user.id);
    socket.emit("add", {"userId": widget.user.id});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: FloatingNavbar(
          onTap: (int val) => setState(() => _index = val),
          currentIndex: _index,
          items: [
            FloatingNavbarItem(icon: Icons.home, title: 'Home'),
            FloatingNavbarItem(icon: Icons.history, title: 'History'),
            FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
          ],
        ),
        body: pages[_index](widget.user, socket),
      ),
    );
  }
}
