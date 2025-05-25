import 'package:flutter/material.dart';
import 'homePage1.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup.dart';
import 'scan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'ProfilePage.dart';
import 'forgotPass.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ NEW import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(fontFamily: 'montserrat'),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _signIn() async {
    final email = loginController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast("Please enter both email and password.");
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showToast("No user found for that email!");
        return;
      }

      final userDoc = snapshot.docs.first;
      final user = userDoc.data() as Map<String, dynamic>;

      if (user['password'] != password) {
        _showToast("Wrong password! Please re-check your password.");
        return;
      }

      // ✅ Save user info locally
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user['email']);
      await prefs.setString('user_name', user['name']);
      await prefs.setString('user_id', userDoc.id);

      _showToast("Login successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage1()),
      );
    } catch (e) {
      print("⚠️ Sign-in error: $e");
      _showToast("An unexpected error occurred.");
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

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
                    style: TextStyle(fontFamily: 'montserrat1', fontSize: 30),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontFamily: 'montserrat', fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: loginController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPass()));
                  },
                  child: const Text('Forgot Password', style: TextStyle(fontFamily: 'montserrat')),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(fontFamily: 'montserrat1')),
                      onPressed: _signIn,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Do not have an account?', style: TextStyle(fontFamily: 'montserrat')),
                    TextButton(
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontFamily: 'montserrat', fontSize: 17),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                      },
                    ),
                  ],
                ),
              ],
            )));
  }
}
