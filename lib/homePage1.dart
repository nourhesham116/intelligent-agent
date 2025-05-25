import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'generate.dart';
import 'ProfilePage.dart';
import 'ParkingLotPage.dart'; // ✅ Make sure this file exists

class HomePage1 extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Smart Parking System",
          style: TextStyle(fontFamily: 'montserrat1'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Fluttertoast.showToast(
                msg: user == null
                    ? "No user logged in!"
                    : "Logged in as: ${user.email}",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 40.0),
            customButton("Reservation", () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ParkingLotPage(), // ✅ Opens the parking lot
              ));
            }),
            const SizedBox(height: 20.0),
            customButton("Instant QR Code", () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GeneratePage(),
              ));
            }),
          ],
        ),
      ),
    );
  }

  Widget customButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.black, width: 3.0),
        ),
        backgroundColor: Colors.white,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
