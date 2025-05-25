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

  String qrCodeResult = "";

  Future<void> scanQRCode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      final User? firebaseUser = auth.currentUser;

      final scannedData = result.rawContent.isNotEmpty
          ? result.rawContent
          : "UserXYZ - UserXYZ@gmail.com";

      setState(() {
        qrCodeResult = scannedData;
      });

      if (firebaseUser != null) {
        await firestore
            .collection("parking")
            .doc(firebaseUser.uid)
            .set({
          "User info": qrCodeResult,
        });
      }
    } catch (e) {
      setState(() {
        qrCodeResult = "Scan failed or cancelled.";
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
          style: TextStyle(fontFamily: 'montserrat1'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              "RESULT:",
              style: TextStyle(
                fontFamily: 'montserrat',
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              qrCodeResult.isNotEmpty ? qrCodeResult : "No QR scanned yet.",
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: scanQRCode,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.black, width: 3.0),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "Open Scanner",
                style: TextStyle(
                  fontFamily: 'montserrat',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
