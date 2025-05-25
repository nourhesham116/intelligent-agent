import 'package:flutter/material.dart';
import 'homePage1.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';


class ProfilePage extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserData() async {
    final User? firebaseUser = auth.currentUser;
    final DocumentSnapshot userDoc =
        await firestore.collection("users").doc(firebaseUser?.uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('CODE SHINOBIS', style: TextStyle(fontFamily: 'painter')),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          String name = 'USER NAME   :   UserXYZ';
          String email = 'USER EMAIL   :   UserXYZ@gmail.com';

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data.'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            name = "USER NAME   :   ${data['User name']}";
            email = "USER EMAIL   :   ${data['User email']}";
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'USER PROFILE',
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
                    'Customer',
                    style: TextStyle(fontFamily: 'montserrat', fontSize: 20),
                  ),
                ),
                const SizedBox(height: 30),
                Text(name),
                const SizedBox(height: 10),
                Text(email),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text('Log out', style: TextStyle(fontFamily: 'montserrat1')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
