import 'package:flutter/material.dart';
import 'package:wasla_driver/Screens/Register/PinPage.dart';
import 'package:wasla_driver/Screens/Register/RegisterPage.dart';

class RegisterDetails extends StatefulWidget {
  const RegisterDetails({super.key, required this.number, required this.type});
  final String number;
  final Acc type;
  @override
  State<RegisterDetails> createState() => _RegisterDetailsState();
}

class _RegisterDetailsState extends State<RegisterDetails> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController carNameController = TextEditingController();
  TextEditingController serviceNumberController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();
  bool secondPage = false;
  String formattedText = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey,
          body: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: secondPage ? carDetails() : personalDetails(),
            ),
          )),
    );
  }

  Column carDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Car Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 50),
        const Text(
          "Car Brand",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _input("e.g Renault", brandController),
        const SizedBox(height: 20),
        const Text(
          "Car Name",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _input("e.g Symbol", carNameController),
        const SizedBox(height: 20),
        const Text(
          "License Plate",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _input("0*****-116-25", licensePlateController),
        const SizedBox(height: 20),
        const Text(
          "Service Number",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _input("e.g 96", serviceNumberController),
        const SizedBox(height: 50),
        ElevatedButton(
            style: ButtonStyle(
                minimumSize: const MaterialStatePropertyAll(Size(200, 40)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))),
            onPressed: () {
              // _carDetailsValidation();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinCodePage(),
                  ));
            },
            child: const Text("Next"))
      ],
    );
  }

  Column personalDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Personal Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 50,
        ),
        _input("First Name", firstNameController),
        const SizedBox(height: 20),
        _input("Last Name", firstNameController),
        const SizedBox(height: 20),
        _input("ID Number", firstNameController),
        const SizedBox(height: 50),
        ElevatedButton(
            style: ButtonStyle(
                minimumSize: MaterialStatePropertyAll(Size(200, 40)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))),
            onPressed: () {
              if (widget.type == Acc.taxi) {
                setState(() {
                  secondPage = true;
                });
              }
            },
            child: const Text("Next"))
      ],
    );
  }

  _personalDetailsValidation() {
    // information validation logic
  }

  _carDetailsValidation() {
    if (RegExp(r'^\d{6}-\d{3}-\d{2}$').hasMatch(licensePlateController.text)) {
      if (carNameController.text.isNotEmpty &&
          brandController.text.isNotEmpty) {
        // next page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all the fields")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid license plate")));
    }
  }

  _input(String label, TextEditingController controller) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      height: 54,
      child: TextFormField(
        onTap: () {},
        onChanged: (value) {},
        controller: controller,
        textAlign: TextAlign.center,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            hintText: label,
            hintStyle: const TextStyle(
                color: Color.fromRGBO(26, 26, 27, 0.4), fontSize: 16)),
      ),
    );
  }
}
