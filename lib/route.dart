import 'package:escapecode_mobile/dataProviders.dart';
import 'package:escapecode_mobile/homePage1.dart';
import 'package:escapecode_mobile/login_page.dart';
import 'package:escapecode_mobile/scan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialRouteDecider extends StatelessWidget {
  const InitialRouteDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final user = FirebaseAuth.instance.currentUser;

    final String? userId = provider.ID;
    final bool isLoggedIn = userId != null;
    final bool isLoggedInDB = user != null;
    final bool isAdmin = provider.Admin;

    if (!isLoggedIn && !isLoggedInDB) {
      return const LoginPage();
    } else if (isAdmin) {
      return ScanPage();
    } else {
      return HomePage1();
    }
  }
}
