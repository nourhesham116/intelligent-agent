import 'package:escapecode_mobile/dataProviders.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage1.dart';
import 'login_page.dart'; // ⬅️ Add login page route

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
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty) {
      _showToast("Please fill all fields.");
      return;
    }

    if (_password.text != _confirm.text) {
      _showToast("Passwords do not match.");
      return;
    }

    try {
      final newUser = await _firestore.collection("users").add({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "password":
            _password.text.trim(), // ⚠️ Storing in plain text is insecure
        "createdAt": FieldValue.serverTimestamp(),
      });

      context.read<DataProvider>().setEmail(_email.text.trim());
      context.read<DataProvider>().setName(_name.text.trim());
      context.read<DataProvider>().setID(newUser.id);

      _showToast("User registered successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(_name, 'Name'),
            const SizedBox(height: 14),
            _buildField(_email, 'Email'),
            const SizedBox(height: 14),
            _buildField(_password, 'Password', obscure: true),
            const SizedBox(height: 14),
            _buildField(_confirm, 'Confirm Password', obscure: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}
