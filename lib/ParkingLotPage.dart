import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reserve_page.dart';

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
      backgroundColor: Colors.black, // 🔲 BLACK BACKGROUND
      appBar: AppBar(
        title: const Text('Parking Lot'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('spots').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading spots', style: TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.yellow));
                  }

                  final spots = snapshot.data!.docs;

                  // 🔍 Debug
                  print("🔥 Total documents: ${spots.length}");
                  for (var doc in spots) {
                    print("➡️ Spot: ${doc['spot_number']} | occupied: ${doc['occupied']}");
                  }

                  // ✅ Sort by spot_number and take only 8
                  final sortedSpots = spots
                    ..sort((a, b) =>
                        (a['spot_number'] as int).compareTo(b['spot_number'] as int));
                  final limitedSpots = sortedSpots.take(8).toList();

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    children: limitedSpots.map((spot) => _buildSpotTile(spot)).toList(),
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
                    builder: (_) => ReservePage(userId: currentUserId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Reserve a Spot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpotTile(QueryDocumentSnapshot spot) {
    final bool occupied = spot['occupied'] ?? false;
    final int spotNum = spot['spot_number'];
    final String userId = spot['user_id'] ?? '';

    Color bgColor;
    Color iconColor;
    Color borderColor;

    if (occupied) {
      if (userId == currentUserId) {
        bgColor = Colors.yellow.shade800.withOpacity(0.3); // current user's car
        iconColor = Colors.yellow;
        borderColor = Colors.yellow;
      } else {
        bgColor = Colors.red.shade900.withOpacity(0.3);
        iconColor = Colors.redAccent;
        borderColor = Colors.red;
      }
    } else {
      bgColor = Colors.green.shade900.withOpacity(0.2);
      iconColor = Colors.greenAccent;
      borderColor = Colors.green;
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
            occupied ? 'Occupied' : 'Free',
            style: TextStyle(
              color: occupied ? Colors.red[200] : Colors.greenAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
