import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wasla_driver/Constants.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  bool arrived = false;
  bool onRoad = false;
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
            children: [
              Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                color: Colors.red,
                child: Center(
                  child: Text("Fill"),
                ),
              ),
              order()
            ],
          ),
        ),
      ),
    );
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
                  onPressed: () {},
                  label: const Text("Get directions")),
              ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Constants.main),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(150, 40))),
                  icon: const FaIcon(FontAwesomeIcons.circleCheck),
                  onPressed: () {
                    showConfirmationDialog();
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  order() {
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
          child: arrived
              ? pickedClientUp()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Some random name",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
                              onPressed: () {},
                              icon: const FaIcon(FontAwesomeIcons.xmark)),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.deepPurple,
                          child: IconButton(
                              color: Colors.white,
                              onPressed: () {},
                              icon: const FaIcon(FontAwesomeIcons.route)),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green,
                          child: IconButton(
                              color: Colors.white,
                              onPressed: () {},
                              icon: const FaIcon(FontAwesomeIcons.phone)),
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
