import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservePage extends StatefulWidget {
  final String userId;
  const ReservePage({super.key, required this.userId});

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Reservation Time"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: const Text("Pick Time"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (selectedTime != null)
              Text(
                "Selected: ${selectedTime!.format(context)}",
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedTime == null ? null : _attemptReservation,
              child: const Text("Confirm Reservation"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _attemptReservation() async {
    final now = TimeOfDay.now();
    final diffMinutes = _timeDifferenceInMinutes(now, selectedTime!);

    if (diffMinutes > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only reserve within 1 hour before your parking time')),
      );
      return;
    }

    try {
      print("🔍 Searching for available spots...");
      final availableSpots = await FirebaseFirestore.instance
          .collection('spots')
          .where('occupied', isEqualTo: false)
          .get();

      if (availableSpots.docs.isEmpty) {
        print("❌ No free spots available.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No free spots available')),
        );
        return;
      }

      final spotDoc = availableSpots.docs.first;
      final spotId = spotDoc.id;
      final spotNum = spotDoc['spot_number'];
      final reservationTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      final qrContent =
          "user_id:${widget.userId}\nspot_number:$spotNum\nreservation:$reservationTime";
      final qrBase64 = await _generateQrBase64(qrContent);

      await FirebaseFirestore.instance.collection('spots').doc(spotId).update({
        'occupied': true,
        'user_id': widget.userId,
        'reservation_time': reservationTime,
        'timestamp': FieldValue.serverTimestamp(),
        'qr_code': qrBase64,
      });

      print("✅ Reservation complete for spot $spotNum");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spot $spotNum reserved successfully')),
      );

      Navigator.pop(context); // Go back to ParkingLotPage
    } catch (e, stacktrace) {
      print("❌ ERROR: $e");
      print("❌ STACKTRACE: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reserve a spot')),
      );
    }
  }

  int _timeDifferenceInMinutes(TimeOfDay t1, TimeOfDay t2) {
    final t1Minutes = t1.hour * 60 + t1.minute;
    final t2Minutes = t2.hour * 60 + t2.minute;
    return t2Minutes - t1Minutes;
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
      );
      final imageData = await painter.toImageData(300);
      return base64Encode(imageData!.buffer.asUint8List());
    } else {
      throw Exception("Failed to generate QR");
    }
  }
}
