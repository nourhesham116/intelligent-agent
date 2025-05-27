import 'package:escapecode_mobile/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage1.dart';
import 'scan.dart'; // ✅ for admin page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('user_id');
  final bool isLoggedIn = userId != null;
  final bool isAdmin = prefs.getBool('is_admin') ?? false;

  Widget initialPage;

  if (!isLoggedIn) {
    initialPage = const LoginPage();
  } else if (isAdmin) {
    initialPage =  ScanPage(); // ✅ admin goes to scanner
  } else {
    initialPage = HomePage1(); // ✅ user goes to main home
  }

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;
  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'montserrat'),
      home: initialPage,
    );
  }
}
