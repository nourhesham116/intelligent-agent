import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String statusMessage = "No QR scanned yet.";

  Future<void> scanQRCode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      final scannedData = result.rawContent;

      if (scannedData.isEmpty) {
        setState(() {
          statusMessage = "⚠️ Scan failed or cancelled.";
        });
        return;
      }

      final spotMatch = RegExp(r'spot:(\d+)').firstMatch(scannedData);
      final spot = spotMatch?.group(1);

      if (spot != null) {
        final User? user = auth.currentUser;

        if (user != null) {
          await firestore.collection("parking").doc(user.uid).set({
            "spot": spot,
            "scanned_at": FieldValue.serverTimestamp(),
          });
        }

        setState(() {
          statusMessage = "✅ QR Code scanned successfully. It belongs to Spot #$spot";
        });
      } else {
        setState(() {
          statusMessage = "⚠️ Spot number not found in QR.";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "⚠️ Scan failed or cancelled.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Scanner", style: TextStyle(fontFamily: 'montserrat1')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusMessage,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
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
      backgroundColor: Colors.black,
    );
  }
}
