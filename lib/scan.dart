import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String statusMessage = "No QR scanned yet.";

  Future<void> scanQRCode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      final scannedQRCode = result.rawContent;

      if (scannedQRCode.isEmpty) {
        setState(() {
          statusMessage = "⚠️ Scan cancelled or failed.";
        });
        return;
      }

      // 🔍 Look for a spot where qr_code == scannedQRCode
      final query = await firestore
          .collection("spots")
          .where("qr_code", isEqualTo: scannedQRCode)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          statusMessage = "❌ QR code not found in any spot.";
        });
        return;
      }

      final matchedDoc = query.docs.first;
      final spotId = matchedDoc.id;
      final spotData = matchedDoc.data();
      final spotNumber = spotData['spot_number'] ?? spotId;

      // ✅ Update the spot to free it
      await firestore.collection("spots").doc(spotId).update({
        "occupied": false,
        "user_id": "",
        "timestamp": "",
        "reservation_id": "",
        "reservation_datetime": "",
        "reservation_time": "",
      });

      setState(() {
        statusMessage = "🟢 Spot #$spotNumber has been freed successfully.";
      });
    } catch (e) {
      setState(() {
        statusMessage = "❌ Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Scanner",
          style: TextStyle(
            fontFamily: 'montserrat1',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusMessage,
                style: const TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/scanner.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: scanQRCode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Open Scanner",
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
