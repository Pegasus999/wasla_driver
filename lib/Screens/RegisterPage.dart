import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum Acc { taxi, tow }

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController phoneController = TextEditingController(text: "+213");
  Acc? type;
  bool valid = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 200,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    color: Colors.grey,
                  ),
                  child: type != null ? forms(context) : accountType(context),
                ),
              ))
            ],
          ),
        ),
      )),
    );
  }

  forms(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  type = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: const Center(
                  child: Icon(
                    Icons.arrow_left,
                    size: 30,
                  ),
                ),
              ),
            ),
            const Text(
              "Create an account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 30,
            )
          ],
        ),
        const SizedBox(
          height: 40,
        ),
        const Text(
          "Account Details",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 60,
        ),
        SizedBox(
          width: 300,
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    )),
                const SizedBox(height: 20),
                TextFormField(
                    decoration: InputDecoration(
                  labelText: "Password",
                )),
                const SizedBox(height: 20),
                TextFormField(
                    decoration: InputDecoration(
                  labelText: "Confirm Password",
                )),
                const SizedBox(height: 90),
                ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStatePropertyAll(Size(200, 50))),
                    onPressed: () {
                      if (RegExp(r'^\+213\d{9}')
                          .hasMatch(phoneController.text)) {
                        setState(() {
                          valid = true;
                        });
                      } else {
                        setState(() {
                          valid = false;
                        });
                      }
                      _showPinPopUp();
                    },
                    child: const Text("Next"))
              ],
            ),
          ),
        )
      ],
    );
  }

  _showPinPopUp() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Verfiy Phone Number"),
            content: Container(
                width: 250,
                height: 250,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "A verification code has been sent to ${phoneController.text}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PinInputTextField(
                          decoration: CirclePinDecoration(
                              strokeColorBuilder:
                                  const FixedColorBuilder(Colors.black))),
                      const SizedBox(
                        height: 40,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Didn't receive a text?\n",
                                style: TextStyle(color: Colors.black)),
                            WidgetSpan(child: SizedBox(height: 30)),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                                text: "Resend",
                                style: TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.underline))
                          ],
                        ),
                      ),
                    ]))));
  }

  Column accountType(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 10,
        ),
        const Text(
          "Create an account",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 40,
        ),
        const Text(
          "Account Type",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 60,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    type = Acc.taxi;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black,
                              offset: Offset(1, 2),
                              spreadRadius: 2)
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Taxi Driver",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    type = Acc.tow;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black,
                              offset: Offset(1, 2),
                              spreadRadius: 2)
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Towing Driver",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 100,
        ),
      ],
    );
  }
}
