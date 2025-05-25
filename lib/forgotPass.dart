import 'package:flutter/material.dart';

class ForgotPass extends StatefulWidget {
  @override
  ForgotPassState createState() => ForgotPassState();
}

class ForgotPassState extends State<ForgotPass> {
  final TextEditingController emailController = TextEditingController();

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SmartPark',
          style: TextStyle(fontFamily: 'painter'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ListView(
          children: <Widget>[
            const Center(
              child: Text(
                'Smart Parking System',
                style: TextStyle(
                  fontFamily: 'montserrat1',
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  fontFamily: 'montserrat',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Please enter your email',
                labelStyle: const TextStyle(color: Colors.amber),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    _showMessage("OTP sent to $email!");
                  } else {
                    _showMessage("Please enter an email address.");
                  }
                },
                child: const Text(
                  'Send OTP',
                  style: TextStyle(
                    fontFamily: 'montserrat1',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
