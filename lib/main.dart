import 'package:flutter/material.dart';
import 'package:wasla_driver/Screens/HomePage.dart';
import 'package:wasla_driver/Screens/Orders/OrderPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: OrderPage());
  }
}
