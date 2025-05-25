import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'homePage1.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String? name;
  String? email;
  int? spotNumber;
  String? reservationTime;
  DateTime? reservationDateTime;
  String? qrBase64;
  String message = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    print("🔍 Loaded user_id: $userId");

    if (userId == null) {
      setState(() => message = "No user logged in.");
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      final userData = userDoc.data();
      print("📄 Full user data: $userData");

      if (userData == null) {
        setState(() => message = "User document not found.");
        return;
      }

      name = userData['name'] ?? 'Unknown';
      email = userData['email'] ?? 'Unknown';

      final spots = await FirebaseFirestore.instance
          .collection('spots')
          .where('user_id', isEqualTo: userId)
          .where('occupied', isEqualTo: true)
          .get();

      if (spots.docs.isNotEmpty) {
        final spot = spots.docs.first;
        spotNumber = spot.data()['spot_number'];
        reservationTime = spot.data()['reservation_time'];
        qrBase64 = spot.data()['qr_code'];
        final resDateStr = spot.data()['reservation_datetime'];
        if (resDateStr != null && resDateStr != '') {
          reservationDateTime = DateTime.tryParse(resDateStr);
        }
      }

      setState(() => message = "");
    } catch (e) {
      print("❌ Error loading profile: $e");
      setState(() => message = "Error loading profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrWidget = qrBase64 != null
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.memory(base64Decode(qrBase64!)),
          )
        : const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontFamily: 'painter')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: message.isNotEmpty
            ? Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : ListView(
                children: [
                  const Center(
                    child: Text(
                      'USER PROFILE',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'montserrat1',
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Name: $name", style: const TextStyle(color: Colors.white)),
                  Text("Email: $email", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 30),
                  if (spotNumber != null && reservationTime != null && reservationDateTime != null) ...[
                    Text("Reserved Spot: $spotNumber", style: const TextStyle(color: Colors.white)),
                    Text("Reservation Time: $reservationTime", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    StreamBuilder<Duration>(
                      stream: Stream.periodic(const Duration(seconds: 1), (_) {
                        final now = DateTime.now().toUtc();
                        return reservationDateTime!.difference(now);
                      }),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Calculating...", style: TextStyle(color: Colors.white70));
                        }
                        final diff = snapshot.data!;
                        if (diff.isNegative) {
                          return const Text("Reservation time has passed.", style: TextStyle(color: Colors.red));
                        }
                        final h = diff.inHours.toString().padLeft(2, '0');
                        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
                        final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
                        return Text("$h:$m:$s remaining", style: const TextStyle(color: Colors.greenAccent, fontSize: 18));
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Your QR Code:", style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    Center(child: qrWidget),
                  ] else
                    const Text("No active reservation.", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage1()),
                        (route) => false,
                      );
                      Future.delayed(const Duration(milliseconds: 300), () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Logged out successfully"),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
    );
  }
}
