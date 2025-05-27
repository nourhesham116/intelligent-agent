import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

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
          // Optional: delete user's reservation if exists
          await firestore.collection("parking").doc(user.uid).delete();

          // Clear spot info without deleting the document
          await firestore.collection("spots").doc(spot).update({
            "occupied": false,
            "user_id": "",
            "timestamp": "",
            "reservation_id": "",
            "reservation_datetime": "",
            "reservation_time": "",
          });

          setState(() {
            statusMessage = "🟢 Spot #$spot has been freed successfully.";
          });
        } else {
          setState(() {
            statusMessage = "⚠️ No user logged in.";
          });
        }
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
  title: const Text(
    "Scanner",
    style: TextStyle(
      fontFamily: 'montserrat1',
      color: Colors.white,
    ),
  ),
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()), // or HomePage1()
          (route) => false,
        );
      },
    )
  ],
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
