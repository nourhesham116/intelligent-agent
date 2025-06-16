import 'dart:async';
import 'package:escapecode_mobile/dataProviders.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
    cleanExpiredReservations();
    _startPeriodicCleanup();
  }

  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      cleanExpiredReservations();
    });
  }

  Future<void> cleanExpiredReservations() async {
    final now = DateTime.now().toUtc();
    final snapshot = await FirebaseFirestore.instance
        .collection('spots')
        .where('occupied', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final reservationField = data['reservation_datetime'];

      if (reservationField == null || reservationField is! Timestamp) {
        continue;
      }

      final DateTime reservationTime = reservationField.toDate();

      if (now.isAfter(reservationTime)) {
        await FirebaseFirestore.instance.collection('spots').doc(doc.id).update({
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
      }
    }
  }

  Future<void> _loadCurrentUserId() async {
    final provider = context.read<DataProvider>();
    setState(() {
      currentUserId = provider.ID ?? 'guest';
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
        title: const Text(
          'Parking Lot',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'montserrat1',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('spots').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading spots',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    );
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
                    children: limitedSpots
                        .map((spot) => _buildSpotTile(spot))
                        .toList(),
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
                    builder: (_) =>
                        ReservePage(userId: currentUserId, flag: true),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reserve a Spot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotTile(QueryDocumentSnapshot spot) {
    final bool occupied = spot['occupied'] ?? false;
    final bool reserved = spot['reserved'] ?? false;
    final int spotNum = spot['spot_number'];

    Color bgColor;
    Color iconColor;
    Color borderColor;
    String statusLabel;

    if (reserved && occupied) {
      bgColor = Colors.blue.shade900.withOpacity(0.3);
      iconColor = Colors.blueAccent;
      borderColor = Colors.blue;
      statusLabel = 'Reserved';
    } else if (!reserved && occupied) {
      bgColor = Colors.red.shade900.withOpacity(0.3);
      iconColor = Colors.redAccent;
      borderColor = Colors.red;
      statusLabel = 'Occupied';
    } else {
      bgColor = Colors.green.shade900.withOpacity(0.2);
      iconColor = Colors.greenAccent;
      borderColor = Colors.green;
      statusLabel = 'Free';
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
            statusLabel,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
