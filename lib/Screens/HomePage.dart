import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wasla_driver/Models/Driver.dart';
import 'package:wasla_driver/Models/Trip.dart';
import 'package:wasla_driver/Screens/ButtonPage.dart';
import 'package:wasla_driver/Screens/HistoryPage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wasla_driver/Screens/Orders/OrderPage.dart';
import 'package:wasla_driver/Screens/SettingsPage.dart';

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
    (user, socket) => SettingsPage()
  ];
  int _index = 0;
  late IO.Socket socket;

  @override
  void initState() {
    initSocket();
    // TODO: implement initState
    super.initState();
    setListener();
  }

  setListener() {
    socket.on("rideRequest", (data) {
      print("object");
      Trip trip = Trip.fromJson(data['trip']);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderPage(
              trip: trip,
              user: widget.user,
              socket: socket,
            ),
          ));
    });
  }

  initSocket() {
    socket = IO.io("http://172.20.10.5:5000", {
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
