import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escapecode_mobile/dataProviders.dart';
import 'package:escapecode_mobile/homePage1.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratePage extends StatefulWidget {
  final String qrData;
  const GeneratePage({super.key, required this.qrData});
  @override
  State<StatefulWidget> createState() => GeneratePageState();
}

class GeneratePageState extends State<GeneratePage> {
  String qrData = "";

  String? userId;
  String? name;
  String? email;
  int? spotNumber;
  String? reservationTime;
  DateTime? reservationDateTime;
  String? qrBase64;
  String message = "Loading...";

  // Default placeholder
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? imageqr;

  Future<void> _loadUserData() async {
    // final prefs = await SharedPreferences.getInstance();
    // final name = prefs.getString('user_name');
    final provider = context.read<DataProvider>();
    final email = provider.Email;
    final id = provider.ID;

    if (email == null || id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info not found.")));
      return;
    }

    final spots =
        await FirebaseFirestore.instance
            .collection('spots')
            .where('user_id', isEqualTo: userId)
            .where('occupied', isEqualTo: true)
            .get();

    if (spots.docs.isNotEmpty) {
      final spot = spots.docs.first;
      spotNumber = spot.data()['spot_number'];
      reservationTime = spot.data()['reservation_time'];
      imageqr = spot.data()['qr_code'];
      final resDateStr = spot.data()['reservation_datetime'];
      if (resDateStr != null && resDateStr != '') {
        reservationDateTime = DateTime.tryParse(resDateStr);
      }
    }
    // setState(() {
    //   qrData = "Name: $name\nEmail: $email\nID: $id";
    //   print('hello gello generate page ' + qrData);
    // });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("QR code generated successfully!")),
    );
  }

  @override
  void initState() {
    super.initState();
    qrData = widget.qrData;
    _loadUserData();
    // qrData = widget.qrData;
    // imageqr = getQr() as String;
    // getQr()
    //     .then((qr) {
    //       setState(() {
    //         imageqr = qr;
    //       });
    //     })
    //     .catchError((e) {
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    //     });
  }

  Future<String> getQr() async {
    final query =
        await firestore
            .collection("spots")
            // .where(
            // "reservation_id",
            // isEqualTo: "3febc547-6399-4750-a785-4353322a2c74",
            // )
            .where("user_id", isEqualTo: qrData)
            .get();
    return query.docs.first.data()['qr_code'];
  }

  @override
  Widget build(BuildContext context) {
    final qrWidget =
        imageqr != null
            ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.memory(base64Decode(imageqr!)),
            )
            : const SizedBox();
    return Scaffold(
      backgroundColor: Colors.black, // 🖤 Background
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Your Unique QR Code',
          style: TextStyle(
            fontFamily: 'montserrat1',
            color: Colors.amber,
          ), // 🟡 Yellow title
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   padding: const EdgeInsets.all(12),
                //   child: QrImageView(
                //     data:
                //         "iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAABHNCSVQICAgIfAhkiAAACblJREFUeJzt3dFuGzcQBdC46H8n/nL3rZCMMFhmOZ658jlvLQRptZIuCN8M+eMHAAAA39Tbp//+aLqOLR8fv7/Mt7fPb+drnv/U41e6Xnf3elaqX/fU92Ha/az+nry/v//49evX1ms0+f+N/dN7HQDXCSwghsACYggsIIbAAmL8e+VBp9qQXdVt1LQWaVobeMqp6zz1vk61iqda6a7nX5n8e7fCAmIILCCGwAJiCCwghsACYlxqCVeqZ/d2nbqertYvfTZtV3UL1jVjeErX665M+L1bYQExBBYQQ2ABMQQWEENgATFutYSvKqWdSd95dfd1V1bP37Uzatfs57QZ0gpWWEAMgQXEEFhADIEFxBBYQIxv3RJ27SBaravdm7YD5+77OjX7eeq+Vc+cJrLCAmIILCCGwAJiCCwghsACYtxqCae1FdWzdV07VU6bNUvZcTT9Pk87d3LC790KC4ghsIAYAguIIbCAGAILiHGpJeyaidt1alZu2uNXqq9nV1erNe3zSr//k3/vVlhADIEFxBBYQAyBBcQQWECMpzrgY8Kw0BfqalVOPX/183S1Wl2qv/7V50W+qreHG2eFBcQQWEAMgQXEEFhADIEFxPhcW5TWD9NarWmtTfWOptX34ZSu8yJftX2bNmP4F99DLSGQR2ABMQQWEENgATEEFhDjacfRabNUu9fT1YI1tictUlq5aa3itHMSd99X186oj4+3wgJiCCwghsACYggsIIbAAmLcOpdwWqu4Mq0V6ppZ62pLp923U/dhWsu2kv66j6ywgBgCC4ghsIAYAguIIbCAGE8tYXU7k76j46lWqLqtq55xSznfcNpOs9Na45WuFvUKKywghsACYggsIIbAAmIILCBGySxhyjlou49Pafe6dqqsbhtXprXYXS3bqc9lpat9fmSFBcQQWEAMgQXEEFhADIEFxPj8Z/kjNcm0HT5XnAP458efcup1p+1we6olT7kPXS3/Y05ZYQExBBYQQ2ABMQQWEENgATFutYSNrcGWrp0tT5nWOk1rkbp2Oj1lWjs5rf18e3giKywghsACYggsIIbAAmIILCDGpR1H02egTl1neht46np2H9+14+u0dmzajqannv8rv7dWWEAMgQXEEFhA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",
                //     version: QrVersions.max,
                //     size: 200.0,
                //     backgroundColor: Colors.white,
                //   ),
                // ),
                Center(child: qrWidget),
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.all(10),
                //   child: Image.memory(base64Decode(imageqr)),
                // ),
                const SizedBox(height: 30),
                const Text(
                  "User QR Code Generator",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'montserrat',
                    fontSize: 20.0,
                    color: Colors.amber, // 🟡 Yellow
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      () => {
                        Navigator.pop(context),
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage1()),
                        ),
                      },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    backgroundColor: Colors.amber, // 🟡 Yellow button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    "Return back home",
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
        ),
      ),
    );
  }
}
