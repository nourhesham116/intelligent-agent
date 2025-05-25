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
                    return const Center(child: Text('Error loading spots'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final spots = snapshot.data!.docs;

                  // 🔍 Debug print
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
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children:
                        limitedSpots.map((spot) => _buildSpotTile(spot)).toList(),
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
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text("Reserve a Spot", style: TextStyle(fontSize: 18)),
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
    if (occupied) {
      bgColor = (userId == currentUserId) ? Colors.blue[100]! : Colors.red[100]!;
    } else {
      bgColor = Colors.green[100]!;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            occupied ? Icons.directions_car : Icons.local_parking,
            size: 40,
            color: occupied ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 8),
          Text('Spot $spotNum', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(occupied ? 'Occupied' : 'Free'),
        ],
      ),
    );
  }
}
