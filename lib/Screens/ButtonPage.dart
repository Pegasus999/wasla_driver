import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            width: 200,
            height: 80,
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                color: Colors.grey, // Color of the shadow
                offset: Offset(0, 2), // Offset of the shadow (x, y)
                blurRadius: 5, // Spread of the shadow
                spreadRadius: 3, // Extent of the shadow
              ),
            ], borderRadius: BorderRadius.circular(30), color: Colors.black54),
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
      ],
    );
  }
}
