import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wasla_driver/Screens/ButtonPage.dart';
import 'package:wasla_driver/Screens/HistoryPage.dart';
import 'package:wasla_driver/Screens/SettingsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? userPosition;
  List<Widget Function()> pages = [
    () => ButtonPage(),
    () => HistoryPage(),
    () => SettingsPage()
  ];
  int _index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleLocationPermission();
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
        body: pages[_index](),
      ),
    );
  }
}
