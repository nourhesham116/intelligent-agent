import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage1.dart';
import 'forgotPass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showToast("No user found for that email!");
        return;
      }

      final userDoc = snapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData['password'] != password) {
        _showToast("Wrong password! Please re-check your password.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', userData['email']);
      await prefs.setString('user_name', userData['name']);
      await prefs.setString('user_id', userDoc.id);

      print("✅ Login success, stored prefs:");
      print("user_id: ${prefs.getString('user_id')}");
      print("user_email: ${prefs.getString('user_email')}");
      print("user_name: ${prefs.getString('user_name')}");

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
          title: const Text('Sign In', style: TextStyle(fontFamily: 'montserrat1')),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: _signIn,
                    child: const Text('Login', style: TextStyle(fontFamily: 'montserrat1')),
                  ),
                ),
              ],
            )));
  }
}
