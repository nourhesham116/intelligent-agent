import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'puzzle_manager.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

 bool isValidUniversityEmail(String email) {
  final pattern = RegExp(r'@miuegypt\.edu\.eg$');
  return pattern.hasMatch(email.trim().toLowerCase());
}


  String determineUserRole(String email) {
    String username = email.split('@')[0];
    if (RegExp(r'\d+\$').hasMatch(username)) return "Student";
    if (username.contains('.')) return "Teacher";
    return "Student"; // Default to student to avoid false "Unknown" case
  }

  void validateFields() {
    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (email.isEmpty) {
        emailError = 'Email is required';
      } else if (!isValidUniversityEmail(email)) {
        emailError = 'Use your university email (e.g., @miuegypt.edu.eg)';
      }

      if (password.isEmpty) {
        passwordError = 'Password is required';
      } else if (password.length < 6) {
        passwordError = 'Password must be at least 6 characters';
      }

      if (confirmPassword != password) {
        confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  Future<void> signUp() async {
    validateFields();
    if (emailError != null || passwordError != null || confirmPasswordError != null) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final role = determineUserRole(email);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection("Users").doc(credential.user!.uid).set({
        'email': email,
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      });

      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Account created')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PuzzleManager()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() => emailError = 'Email already in use.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ FirebaseAuthException: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/robot.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: emailError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: passwordError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Colors.cyanAccent),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: confirmPasswordError,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
