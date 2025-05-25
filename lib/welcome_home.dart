import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup.dart';

class WelcomeHomePage extends StatelessWidget {
  const WelcomeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('SMART PARK', style: TextStyle(fontFamily: 'painter')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
            },
            child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Smart Parking System!',
          style: TextStyle(fontSize: 24, fontFamily: 'montserrat1'),
        ),
      ),
    );
  }
}
