import 'package:flutter/material.dart';
import 'signup.dart';
import 'teacher_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? emailError;
  String? passwordError;

 String? _validateEmail(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return 'Email cannot be empty';
  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@miuegypt\.edu\.eg$').hasMatch(trimmed)) {
    return 'Use your university email (e.g., @miuegypt.edu.eg)';
  }
  return null;
}


  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Minimum 6 characters required';
    return null;
  }

  void validate() {
    setState(() {
      emailError = _validateEmail(emailController.text);
      passwordError = _validatePassword(passwordController.text);
    });
  }

  Future<void> loginUser() async {
    validate();
    if (emailError != null || passwordError != null) return;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      emailController.clear();
      passwordController.clear();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherDashboard()),
      );
    } catch (error) {
      String message = 'Login failed';
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          message = 'No user found for that email.';
        } else if (error.code == 'wrong-password') {
          message = 'Incorrect password.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $message')),
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
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.cyanAccent, Colors.blueAccent],
                        ).createShader(bounds),
                        child: const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.cyanAccent, offset: Offset(0, 0)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
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
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.cyanAccent),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.cyanAccent,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          errorText: passwordError,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        child: const Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
