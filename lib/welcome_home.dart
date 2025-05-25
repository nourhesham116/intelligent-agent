import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup.dart';

class WelcomeHomePage extends StatelessWidget {
  const WelcomeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        backgroundColor: Colors.black.withOpacity(0.8),
        title: const Text('CODE SHINOBIS', style: TextStyle(fontFamily: 'painter')),
=======
        backgroundColor: Colors.black,
        title: const Text('SMART PARK', style: TextStyle(fontFamily: 'painter')),
>>>>>>> 527059ff36d44948e425a49bd822052f56edfd17
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/smart_parking_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // optional dark overlay
          ),
          const Center(
            child: Text(
              'Welcome to the Smart Parking System!',
              style: TextStyle(
                fontSize: 26,
                fontFamily: 'montserrat1',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}