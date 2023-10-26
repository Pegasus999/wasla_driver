import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isOn = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(""),
          actions: [
            GestureDetector(
              child: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 30,
              ),
            )
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.black.withOpacity(0.3), Colors.white]),
            ),
          ),
        ),
        body: Center(
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
                setState(() {
                  isOn = !isOn;
                });
              },
              duration: const Duration(milliseconds: 500),
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
      ),
    );
  }
}
