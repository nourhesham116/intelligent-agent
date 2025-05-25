import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ParkingLotPage extends StatefulWidget {
  const ParkingLotPage({super.key});

  @override
  State<ParkingLotPage> createState() => _ParkingLotPageState();
}

class _ParkingLotPageState extends State<ParkingLotPage> {
  String currentUserId = 'guest';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id') ?? 'guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Lot'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('spots')
              .orderBy('spot_number')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading spots'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final spots = snapshot.data!.docs;
            final leftSpots = spots.take(4).toList();
            final rightSpots = spots.skip(4).take(4).toList();

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: leftSpots
                        .map((spot) => _buildSpotTile(spot, context))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rightSpots
                        .map((spot) => _buildSpotTile(spot, context))
                        .toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpotTile(QueryDocumentSnapshot spot, BuildContext context) {
    final bool occupied = spot['occupied'] ?? false;
    final int spotNum = spot['spot_number'];
    final String userId = spot['user_id'] ?? '';

    Color bgColor;
    if (occupied) {
      bgColor = (userId == currentUserId) ? Colors.blue[100]! : Colors.red[100]!;
    } else {
      bgColor = Colors.green[100]!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Icon(
            occupied ? Icons.directions_car : Icons.local_parking,
            size: 40,
            color: occupied ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 5),
          Text('Spot $spotNum', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          occupied
              ? const Text('Occupied', style: TextStyle(fontSize: 12))
              : ElevatedButton(
                  onPressed: () => _reserveSpot(spot.id, spotNum, context),
                  child: const Text('Reserve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _reserveSpot(String docId, int spotNum, BuildContext context) async {
    try {
      final doc = FirebaseFirestore.instance.collection('spots').doc(docId);
      final snapshot = await doc.get();

      if (snapshot['occupied'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spot already taken')),
        );
        return;
      }

      final qrContent = "user_id:$currentUserId\nspot_number:$spotNum";
      final qrBase64 = await _generateQrBase64(qrContent);

      await doc.update({
        'occupied': true,
        'user_id': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'qr_code': qrBase64,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot reserved and QR generated!')),
      );
    } catch (e) {
      print('Reservation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reserve spot')),
      );
    }
  }

  Future<String> _generateQrBase64(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
        embeddedImageStyle: null,
      );
      final imageData = await painter.toImageData(300);
      return base64Encode(imageData!.buffer.asUint8List());
    } else {
      throw Exception("Failed to generate QR");
    }
  }
}