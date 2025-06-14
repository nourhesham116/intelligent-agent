import 'package:escapecode_mobile/ProfilePage.dart';
import 'package:escapecode_mobile/dataProviders.dart';
import 'package:escapecode_mobile/login_page.dart';
import 'package:escapecode_mobile/reserve_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'homePage1.dart';
import 'scan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ❗️Force Firebase logout on every app start
  await FirebaseAuth.instance.signOut();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'montserrat'),
      home: LoginPage(), // ✅ Always start on login
    );
  }
}
