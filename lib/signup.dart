import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homePage1.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _firestore = FirebaseFirestore.instance;

  Future<void> _signUp() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty || _confirm.text.isEmpty) {
      _showToast("Please fill all fields.");
      return;
    }

    if (_password.text != _confirm.text) {
      _showToast("Passwords do not match.");
      return;
    }

    try {
      await _firestore.collection("users").add({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "password": _password.text.trim(), // ⚠️ Storing plain text password is NOT secure
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showToast("User saved successfully!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage1()));
    } catch (e) {
      print("⚠️ Error saving user: $e");
      _showToast("Something went wrong while saving.");
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: InputDecoration(labelText: 'Name')),
            SizedBox(height: 10),
            TextField(controller: _email, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 10),
            TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 10),
            TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(45)),
            ),
          ],
        ),
      ),
    );
  }
}
