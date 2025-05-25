import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GeneratePageState();
}

class GeneratePageState extends State<GeneratePage> {
  String qrData = "Code Shinobis"; // Default placeholder

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final id = prefs.getString('user_id');

    if (email == null || id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User info not found.")),
      );
      return;
    }

    setState(() {
      qrData = "Name: $name\nEmail: $email\nID: $id";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("QR code generated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Your Unique QR Code',
          style: TextStyle(fontFamily: 'montserrat1'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 40.0),
            const Text(
              "User QR Code Generator",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'montserrat',
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: _loadUserData,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.black, width: 3.0),
                ),
              ),
              child: const Text(
                "Generate Your Unique QR",
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
