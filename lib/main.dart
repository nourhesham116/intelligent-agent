import 'package:escapecode_mobile/ProfilePage.dart';
import 'package:escapecode_mobile/dataProviders.dart';
import 'package:escapecode_mobile/login_page.dart';
import 'package:escapecode_mobile/reserve_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'homePage1.dart';
import 'scan.dart'; // ✅ for admin page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    late Widget initialPage;

    final provider = context.read<DataProvider>();
    final user = FirebaseAuth.instance.currentUser;

    final String? userId = provider.ID;
    final bool isLoggedIn = userId != null;
    final bool isLoggedInDB = user != null;
    final bool isAdmin = provider.Admin;

    if (!isLoggedIn && !isLoggedInDB) {
      initialPage = LoginPage();
    } else if (isAdmin) {
      initialPage = ScanPage(); // ✅ admin goes to scanner
    } else {
      initialPage = ReservePage(
        userId: '5cJFYKJw5clLCl5Bpt9f',
        flag: true,
      ); // ✅ user goes to main home
      // initialPage = HomePage1(); // ✅ user goes to main home
    }

    return MaterialApp(
      title: 'Smart Parking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'montserrat'),
      home: initialPage,
    );
  }
}
