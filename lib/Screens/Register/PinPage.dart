import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => PinCodePageState();
}

class PinCodePageState extends State<PinCodePage> {
  String? pin;
  String? confirmPin;
  bool loading = false;
  List<Color> kDefaultRainbowColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.lightBlue[100],
          body: loading
              ? _loadingWidget()
              : Column(
                  children: [
                    const SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top) *
                          0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          confirmPin != null
                              ? const Text(
                                  "Confirm Pin",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : const Text(
                                  "Enter Pin",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              height: 150,
                              child: Center(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) =>
                                      _circle(index),
                                  itemCount: 6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    keyboard()
                  ],
                )),
    );
  }

  Expanded keyboard() {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(30),
          child: SizedBox(
            height: 370,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns
              ),
              itemCount: 12, // 0-9 and the center button
              itemBuilder: (context, index) {
                if (index == 11) {
                  return Center(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          shadowColor:
                              MaterialStatePropertyAll(Colors.transparent),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.transparent)),
                      onPressed: () {
                        // Handle button press (you can use onPressed to perform actions)
                        if (pin != null &&
                            pin!.length == 6 &&
                            confirmPin == null) {
                          setState(() {
                            confirmPin = pin;
                            pin = null;
                          });
                        } else if (confirmPin != null &&
                            pin != null &&
                            pin!.length == 6) {
                          if (confirmPin == pin) {
                            print("CORRECT");
                            setState(() {
                              loading = true;
                            });
                          } else {
                            print("INCORRECT");
                          }
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                      ),
                    ),
                  );
                } else if (index == 9) {
                  return Center(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          shadowColor:
                              MaterialStatePropertyAll(Colors.transparent),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.transparent)),
                      onPressed: () {
                        // Handle button press (you can use onPressed to perform actions)
                        if (confirmPin == null) {
                          if (pin != null) {
                            if (pin!.length != 1) {
                              setState(() {
                                pin = pin!.substring(0, pin!.length - 1);
                              });
                            } else {
                              setState(() {
                                pin = null;
                              });
                            }
                          }
                        } else {
                          if (pin != null) {
                            if (pin!.length != 1) {
                              setState(() {
                                pin = pin!.substring(0, pin!.length - 1);
                              });
                            } else {
                              setState(() {
                                pin = null;
                                confirmPin = null;
                              });
                            }
                          }
                        }
                      },
                      child: const Icon(
                        Icons.backspace,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  );
                } else {
                  String number = (index + 1).toString();
                  if (number == "11") {
                    number = "0";
                  }
                  return Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shadowColor: const MaterialStatePropertyAll(
                              Colors.transparent),
                          backgroundColor: const MaterialStatePropertyAll(
                              Colors.transparent),
                          shape: MaterialStatePropertyAll(
                              BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          minimumSize:
                              const MaterialStatePropertyAll(Size(150, 150))),
                      onPressed: () {
                        // Handle button press (you can use onPressed to perform actions)
                        if (pin != null) {
                          if (pin!.length != 6) {
                            setState(() {
                              pin = pin! + number;
                            });
                          }
                        } else {
                          setState(() {
                            pin = number;
                          });
                        }
                      },
                      child: Text(number,
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.black)),
                    ),
                  );
                }
              },
            ),
          )),
    );
  }

  _loadingWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: SizedBox(
          width: 50,
          child: LoadingIndicator(
            indicatorType: Indicator.lineScalePulseOut,
            strokeWidth: 2,
            colors: kDefaultRainbowColors,
          ),
        ),
      ),
    );
  }

  _circle(int index) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
              color:
                  pin != null && index <= pin!.length - 1 ? Colors.black : null,
              border: pin != null && index <= pin!.length - 1
                  ? null
                  : Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }
}
