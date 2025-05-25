import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<Map<String, dynamic>> students = [
    {
      'name': 'John Smith',
      'id': 'STD-1234',
      'email': 'jsmith@edu.com',
      'group': 'Group A',
      'score': 92,
      'totalTime': '01:45:36',
      'puzzlesCompleted': 3,
      'puzzles': [
        {'title': 'Fibonacci', 'time': '00:22:15', 'completed': true},
        {'title': 'Knapsack', 'time': '00:52:21', 'completed': true},
        {'title': 'Bubble Sort', 'time': '00:31:00', 'completed': true},
      ],
      'expanded': false,
      'showDetails': true,
    },
    {
      'name': 'Alex Johnson',
      'id': 'STD-5678',
      'email': 'ajohnson@edu.com',
      'group': 'Group B',
      'score': 78,
      'totalTime': '02:05:33',
      'puzzlesCompleted': 2,
      'puzzles': [
        {'title': 'Fibonacci', 'time': '00:28:10', 'completed': true},
        {'title': 'Knapsack', 'time': '00:42:50', 'completed': true},
        {'title': 'Bubble Sort', 'time': '', 'completed': false},
      ],
      'expanded': false,
      'showDetails': false,
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredStudents =
        students
            .where(
              (s) =>
                  s['name'].toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Student Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search student...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredStudents.length,
              itemBuilder:
                  (context, index) =>
                      _buildStudentTile(index, filteredStudents[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(int index, Map<String, dynamic> student) {
    return Card(
      color: Colors.grey[900],
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        student['group'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    student['expanded'] ? Icons.expand_less : Icons.expand_more,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed:
                      () => setState(
                        () => student['expanded'] = !student['expanded'],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: student['puzzlesCompleted'] / 5,
              color: Colors.green,
              backgroundColor: Colors.white24,
            ),
            const SizedBox(height: 6),
            Text(
              '${student['puzzlesCompleted']} / 5 Puzzles Completed',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            if (student['expanded']) ...[
              const Divider(height: 24, color: Colors.white24),
              _infoRow(Icons.badge, 'ID', student['id']),
              _infoRow(Icons.email, 'Email', student['email']),
              _infoRow(Icons.timer, 'Total Time', student['totalTime']),
              _infoRow(Icons.score, 'Score', '${student['score']}%'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Puzzle Details',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...student['puzzles'].map(_puzzleItem).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _puzzleItem(Map<String, dynamic> puzzle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                puzzle['title'],
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                puzzle['completed'] ? Icons.check_circle : Icons.cancel,
                color: puzzle['completed'] ? Colors.green : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                puzzle['time'].isNotEmpty ? puzzle['time'] : '-',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
