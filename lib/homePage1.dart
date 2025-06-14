import 'package:escapecode_mobile/dataProviders.dart';
import 'package:escapecode_mobile/reserve_page.dart';
import 'package:escapecode_mobile/scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generate.dart';
import 'ProfilePage.dart';
import 'ParkingLotPage.dart';
import 'login_page.dart';

class HomePage1 extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {
  String? userName;
  String? userEmail;
  String currentUserId = 'guest';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRole();
      _loadUserInfo();
    });
  }

  Future<void> _loadCurrentUserId() async {
    // final prefs = await SharedPreferences.getInstance();
    final provider = context.read<DataProvider>();
    setState(() {
      currentUserId = provider.ID ?? 'guest';
    });
  }

  Future<void> _checkRole() async {
    // final prefs = await SharedPreferences.getInstance();
    final provider = context.read<DataProvider>();
    final isAdmin = provider.Admin ?? false;

    if (isAdmin) {
      // Redirect admin out of this page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ScanPage()),
        (route) => false,
      );
    }
  }

  Future<void> _loadUserInfo() async {
    // final prefs = await SharedPreferences.getInstance();
    final provider = context.read<DataProvider>();
    setState(() {
      userName = provider.Name;
      userEmail = provider.Email;
    });
  }

  void _handleAction(VoidCallback onLoggedInAction) async {
    // final prefs = await SharedPreferences.getInstance();

    final provider = context.read<DataProvider>();
    final isLoggedIn = provider.ID != null;

    if (!isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      onLoggedInAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          userName != null ? 'Welcome, $userName' : 'SmartPark',
          style: const TextStyle(
            fontFamily: 'montserrat1',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (userEmail != null)
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Fluttertoast.showToast(
                msg:
                    userEmail == null
                        ? "No user logged in!"
                        : "Logged in as: $userEmail",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 0.8,
              child: Image.asset(
                'assets/images/yellow_car.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find Your",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: 'montserrat',
                  ),
                ),
                const Text(
                  "Parking Space",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'montserrat',
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    selectionCard("Reservation", Icons.directions_car, () {
                      _handleAction(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParkingLotPage(),
                          ),
                        );
                      });
                    }, isYellow: true),
                    const SizedBox(width: 12),
                    selectionCard("Instant QR", Icons.qr_code_scanner, () {
                      _handleAction(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ReservePage(
                                  userId: currentUserId,
                                  flag: false,
                                ),
                          ),
                          // MaterialPageRoute(builder: (_) => GeneratePage()),
                        );
                      });
                    }, isYellow: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget selectionCard(
    String label,
    IconData icon,
    VoidCallback onTap, {
    required bool isYellow,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: 140,
        decoration: BoxDecoration(
          color: isYellow ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isYellow ? Colors.white : Colors.black),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isYellow ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
