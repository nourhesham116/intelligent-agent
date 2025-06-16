import 'dart:convert';
import 'package:escapecode_mobile/dataProviders.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  DateTime? reservationDateTime;
  String? qrBase64;
  String message = "Loading...";
  String? spotDocId;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await Future.delayed(Duration.zero);
    final provider = context.read<DataProvider>();
    userId = provider.ID;

    if (userId == null || userId!.isEmpty) {
      setState(() => message = "No user logged in.");
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      final userData = userDoc.data();

      if (userData == null) {
        setState(() => message = "User document not found.");
        return;
      }

      name = userData['name'] ?? 'Unknown';
      email = userData['email'] ?? 'Unknown';

      final spots = await FirebaseFirestore.instance
          .collection('spots')
          .where('user_id', isEqualTo: userId)
          .where('reserved', isEqualTo: true)
          .limit(1)
          .get();

      if (spots.docs.isNotEmpty) {
        final spot = spots.docs.first;
        spotDocId = spot.id;
        spotNumber = spot['spot_number'];
        reservationTime = spot['reservation_time'];
        qrBase64 = spot['qr_code'];

        final resTimestamp = spot['reservation_datetime'];
        if (resTimestamp is Timestamp) {
          reservationDateTime = resTimestamp.toDate();
        }
      }

      setState(() => message = "");
    } catch (e) {
      print("\u274c Error loading profile: $e");
      setState(() => message = "Error loading profile.");
    }
  }

  Future<void> _autoClearReservation() async {
    if (spotDocId == null) return;

    await FirebaseFirestore.instance.collection('spots').doc(spotDocId).update({
      'occupied': false,
      'reserved': false,
      'user_id': "",
      'qr_code': "",
      'reservation_id': "",
      'reservation_datetime': null,
      'reservation_time': "",
      'timestamp': null,
      'generated_at': "",
    });

    setState(() {
      spotNumber = null;
      reservationTime = null;
      reservationDateTime = null;
      qrBase64 = null;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservation expired and cleared."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrWidget = qrBase64 != null && qrBase64!.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.memory(base64Decode(qrBase64!)),
          )
        : const Text("No QR code available.", style: TextStyle(color: Colors.white70));

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
            ? Center(child: Text(message, style: const TextStyle(color: Colors.white)))
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
                  if (spotNumber != null && reservationDateTime != null) ...[
                    Text("Reserved Spot: $spotNumber", style: const TextStyle(color: Colors.white)),
                    Text("Reservation Time: ${reservationTime ?? 'Unknown'}", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    StreamBuilder<Duration>(
                      stream: Stream.periodic(const Duration(seconds: 1), (_) {
                        final now = DateTime.now().toUtc();
                        final graceEnd = reservationDateTime!.add(const Duration(minutes: 10));
                        return graceEnd.difference(now);
                      }),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Calculating...", style: TextStyle(color: Colors.white70));
                        }

                        final now = DateTime.now().toUtc();

                        if (now.isBefore(reservationDateTime!)) {
                          final remaining = reservationDateTime!.difference(now);
                          final h = remaining.inHours.toString().padLeft(2, '0');
                          final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
                          final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
                          return Text("$h:$m:$s remaining",
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 18));
                        }

                        final timeLeft = reservationDateTime!.add(const Duration(minutes: 10)).difference(now);

                        if (timeLeft > Duration.zero) {
                          final m = timeLeft.inMinutes.toString().padLeft(2, '0');
                          final s = (timeLeft.inSeconds % 60).toString().padLeft(2, '0');
                          return Text("\u23f3 Grace Period: $m:$s",
                              style: const TextStyle(color: Colors.redAccent, fontSize: 18));
                        } else {
                          _autoClearReservation();
                          return const Text("Reservation auto-cleared.",
                              style: TextStyle(color: Colors.redAccent));
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Your QR Code:", style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    Center(child: qrWidget),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cancelReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Cancel Reservation"),
                    ),
                  ] else
                    const Text("No active reservation.", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      context.read<DataProvider>().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _cancelReservation() async {
    try {
      final spotQuery = await FirebaseFirestore.instance
          .collection('spots')
          .where('user_id', isEqualTo: userId)
          .where('reserved', isEqualTo: true)
          .limit(1)
          .get();

      if (spotQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No active reservation found."), backgroundColor: Colors.grey),
        );
        return;
      }

      final spotDoc = spotQuery.docs.first;

      await FirebaseFirestore.instance.collection('spots').doc(spotDoc.id).update({
        'occupied': false,
        'reserved': false,
        'user_id': "",
        'qr_code': "",
        'reservation_id': "",
        'reservation_datetime': null,
        'reservation_time': "",
        'timestamp': null,
        'generated_at': "",
      });

      setState(() {
        spotNumber = null;
        qrBase64 = null;
        reservationDateTime = null;
        reservationTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reservation cancelled successfully."), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("\u274c Cancel error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel reservation."), backgroundColor: Colors.red),
      );
    }
  }
}