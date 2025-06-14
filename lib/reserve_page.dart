import 'dart:convert';
import 'package:escapecode_mobile/ProfilePage.dart';
import 'package:escapecode_mobile/generate.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class ReservePage extends StatefulWidget {
  final String userId;
  final bool flag;
  const ReservePage({super.key, required this.userId, required this.flag});

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select Reservation Time"),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                widget.flag
                    ? ElevatedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded),
                      label: const Text("Pick Time"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : const SizedBox(height: 24),
                SizedBox(
                  height: 30,
                  child: Center(
                    child:
                        widget.flag
                            ? (selectedTime != null
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedTime!.format(context),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                : const Text(
                                  "No time selected",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ))
                            : null,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed:
                      () =>
                          widget.flag
                              ? selectedTime != null
                                  ? _attemptReservationAgg(true)
                                  : null
                              : _attemptReservationAgg(false),
                  // selectedTime != null
                  //     ? (widget.flag
                  //         ? _attemptReservation
                  //         : _attemptInstatntReservation)
                  //     : null,
                  child: const Text("Confirm Reservation"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.flag
                            ? selectedTime != null
                                ? Colors.yellow[700]
                                : null
                            : Colors.yellow[800],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.grey[900],
              hourMinuteTextColor: Colors.yellow,
              dialHandColor: Colors.yellow[700],
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _attemptReservationAgg(bool reserve) async {
    if (reserve) {
      final now = TimeOfDay.now();
      final diffMinutes = _timeDifferenceInMinutes(now, selectedTime!);

      if (diffMinutes > 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You can only reserve within 1 hour before your parking time',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.yellow,
          ),
        );
        return;
      }
    }
    try {
      final existing =
          await FirebaseFirestore.instance
              .collection('spots')
              .where('occupied', isEqualTo: true)
              .where('user_id', isEqualTo: widget.userId)
              .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You already have a reservation.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final availableSpots =
          await FirebaseFirestore.instance
              .collection('spots')
              .where('occupied', isEqualTo: false)
              .get();

      if (availableSpots.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No free spots available',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.yellow,
          ),
        );
        return;
      }

      final spotDoc = availableSpots.docs.first;
      final spotId = spotDoc.id;
      final spotNum = spotDoc['spot_number'];
      // final nowDate = DateTime.now();
      // final reservationDateTime =
      //     DateTime(
      //       nowDate.year,
      //       nowDate.month,
      //       nowDate.day,
      //       selectedTime!.hour,
      //       selectedTime!.minute,
      //     ).toUtc();

      final uuid = const Uuid().v4();
      final generationTime = DateTime.now().toUtc().toIso8601String();
      final qrContent =
          "reservation_id:$uuid\nuser_id:${widget.userId}\nspot:$spotNum\ngenerated_at:$generationTime";
      // "reservation_id:$uuid\nuser_id:${widget.userId}\nspot:$spotNum\nat:$reservationDateTime\ngenerated_at:$generationTime";
      final qrBase64 = await _generateQrBase64(qrContent);
      print("hello gello default res" + qrBase64);
      await FirebaseFirestore.instance.collection('spots').doc(spotId).update({
        'occupied': true,
        'user_id': widget.userId,

        'timestamp': FieldValue.serverTimestamp(),
        'qr_code': qrBase64,

        'reservation_id': reserve ? uuid : null,
        'generated_at': generationTime,
        "reserved": reserve ? true : false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Spot $spotNum reserved successfully',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow[700],
        ),
      );

      Navigator.pop(context);
      Navigator.push(
        context,
        // MaterialPageRoute(builder: (_) => ProfilePage()),
        MaterialPageRoute(builder: (_) => GeneratePage(qrData: widget.userId)),
      );
    } catch (e) {
      print("❌ ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to reserve a spot',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.redAccent,
        ),
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
    // print('data of generate base 64 gello' + data);
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
