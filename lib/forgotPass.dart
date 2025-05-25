import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPass extends StatefulWidget {
  @override
  ForgotPassState createState() => ForgotPassState();
}

class ForgotPassState extends State<ForgotPass> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('CODE SHINOBIS', style: TextStyle(fontFamily: 'painter')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Smart Parking System',
                style: TextStyle(
                  fontFamily: 'montserrat1',
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Forgot Password',
                style: TextStyle(fontFamily: 'montserrat', fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Please enter your email',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.black,
foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                onPressed: () {
                  if (emailController.text.trim().isNotEmpty) {
                    Fluttertoast.showToast(
                      msg: "OTP sent!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please enter an email id!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: const Text(
                  'Send OTP',
                  style: TextStyle(fontFamily: 'montserrat1'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
