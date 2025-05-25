import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reserve_page.dart';

class ParkingLotPage extends StatefulWidget {
  const ParkingLotPage({super.key});

  @override
  State<ParkingLotPage> createState() => _ParkingLotPageState();
}

class _ParkingLotPageState extends State<ParkingLotPage> {
  String currentUserId = 'guest';
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    print("🟢 INIT: running initial cleanup");
    cleanExpiredReservations();
    print("🔁 Starting 1-minute periodic cleanup");
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      print("🔄 Triggered periodic cleanup");
      cleanExpiredReservations();
    });
  }

  Future<void> cleanExpiredReservations() async {
    final now = DateTime.now().toUtc();
    print("🕓 Running cleanup at $now (UTC)");

    final snapshot = await FirebaseFirestore.instance
        .collection('spots')
        .where('occupied', isEqualTo: true)
        .get();

    print("🔍 Found ${snapshot.docs.length} occupied spots");

    for (var doc in snapshot.docs) {
      final data = doc.data();
      print("📦 ${doc.id} data: $data");

      final reservationTimeStr = data['reservation_datetime'];

      if (reservationTimeStr == null || reservationTimeStr == "") {
        print("⚠️ Skipped ${doc.id} — no reservation_datetime");
        continue;
      }

      final reservationTime = DateTime.tryParse(reservationTimeStr);
      if (reservationTime == null) {
        print("❌ Skipped ${doc.id} — invalid reservation_datetime");
        continue;
      }

      print("⏰ Spot ${doc.id} reserved until $reservationTime | Now: $now");

      if (now.isAfter(reservationTime)) {
        print("✅ Cleaning expired spot ${doc.id}");
        await FirebaseFirestore.instance.collection('spots').doc(doc.id).update({
          'occupied': false,
          'user_id': "",
          'reservation_time': "",
          'timestamp': "",
          'qr_code': "",
          'reservation_datetime': "",
        });
      } else {
        print("⏳ Spot ${doc.id} still reserved");
      }
    }
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id') ?? 'guest';
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Parking Lot'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('spots').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading spots', style: TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.yellow));
                  }

                  final spots = snapshot.data!.docs;

                  final sortedSpots = spots
                    ..sort((a, b) => (a['spot_number'] as int)
                        .compareTo(b['spot_number'] as int));
                  final limitedSpots = sortedSpots.take(8).toList();

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: limitedSpots.map((spot) => _buildSpotTile(spot)).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservePage(userId: currentUserId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Reserve a Spot",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpotTile(QueryDocumentSnapshot spot) {
    final bool occupied = spot['occupied'] ?? false;
    final int spotNum = spot['spot_number'];
    final String userId = spot['user_id'] ?? '';
    final String reservationTimeStr = spot['reservation_datetime'] ?? '';
    final DateTime? reservationTime = reservationTimeStr.isNotEmpty
        ? DateTime.tryParse(reservationTimeStr)
        : null;

    final DateTime now = DateTime.now().toUtc();

    Color bgColor;
    Color iconColor;
    Color borderColor;

    if (reservationTime != null && reservationTime.isAfter(now)) {
      bgColor = Colors.blue.shade900.withOpacity(0.3);
      iconColor = Colors.blueAccent;
      borderColor = Colors.blue;
    } else if (occupied) {
      bgColor = Colors.red.shade900.withOpacity(0.3);
      iconColor = Colors.redAccent;
      borderColor = Colors.red;
    } else {
      bgColor = Colors.green.shade900.withOpacity(0.2);
      iconColor = Colors.greenAccent;
      borderColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            occupied ? Icons.directions_car : Icons.local_parking,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Spot $spotNum',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (reservationTime != null && reservationTime.isAfter(now))
                ? 'Reserved'
                : occupied
                    ? 'Occupied'
                    : 'Free',
            style: TextStyle(
              color: (reservationTime != null && reservationTime.isAfter(now))
                  ? Colors.blue[200]
                  : occupied
                      ? Colors.red[200]
                      : Colors.greenAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}