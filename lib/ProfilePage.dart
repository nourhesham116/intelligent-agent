import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

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

      name = userData.containsKey('name') ? userData['name'] : 'Unknown';
      email = userData.containsKey('email') ? userData['email'] : 'Unknown';

      final spots = await FirebaseFirestore.instance
          .collection('spots')
          .where('user_id', isEqualTo: userId)
          .where('occupied', isEqualTo: true)
          .get();

      if (spots.docs.isNotEmpty) {
        final spot = spots.docs.first;
        spotNumber = spot.data().containsKey('spot_number') ? spot['spot_number'] : null;
        reservationTime = spot.data().containsKey('reservation_time') ? spot['reservation_time'] : null;
        qrBase64 = spot.data().containsKey('qr_code') ? spot['qr_code'] : null;
      }

      setState(() => message = "");
    } catch (e) {
      print("❌ Error loading profile: $e");
      setState(() => message = "Error loading profile.");
    }
  }

  String _countdown(String? time) {
    if (time == null) return "";
    try {
      final now = DateTime.now();
      final parts = time.split(':');
      final resTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      final diff = resTime.difference(now);
      if (diff.isNegative) return "Reservation time has passed.";
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return "$h:$m:$s remaining";
    } catch (_) {
      return "Invalid reservation time format.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrWidget = qrBase64 != null
        ? Image.memory(base64Decode(qrBase64!))
        : const SizedBox();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(fontFamily: 'painter')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: message.isNotEmpty
            ? Center(child: Text(message))
            : ListView(
                children: [
                  const Center(
                    child: Text(
                      'USER PROFILE',
                      style: TextStyle(fontSize: 28, fontFamily: 'montserrat1', fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Name: $name"),
                  Text("Email: $email"),
                  const SizedBox(height: 30),
                  if (spotNumber != null && reservationTime != null) ...[
                    Text("Reserved Spot: $spotNumber"),
                    Text("Reservation Time: $reservationTime"),
                    const SizedBox(height: 10),
                    Text(
                      _countdown(reservationTime),
                      style: const TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    const Text("Your QR Code:"),
                    const SizedBox(height: 10),
                    Center(child: qrWidget),
                  ] else
                    const Text("No active reservation."),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
      ),
    );
  }
}
