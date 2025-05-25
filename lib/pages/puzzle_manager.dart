import 'package:flutter/material.dart';

class PuzzleManager extends StatefulWidget {
  const PuzzleManager({Key? key}) : super(key: key);

  @override
  State<PuzzleManager> createState() => _PuzzleManagerState();
}

class _PuzzleManagerState extends State<PuzzleManager> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> predefinedPuzzles = [
    'Binary Search',
    'Bubble Sort',
    'Insertion Sort',
    'Linear Search',
    'N-Queens',
    'Coins',
    'Knapsack',
    'Fibonacci',
    'Floyd Warshall',
    'Palindrome Checker',
    'A*',
    'DFS',
  ];

  List<String> vrPuzzles = [];
  List<String> codingPuzzles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    vrPuzzles = List.from(predefinedPuzzles);
    codingPuzzles = List.from(predefinedPuzzles);
  }

  void _addPuzzle(List<String> puzzleList, String category) {
    showDialog(
      context: context,
      builder: (context) {
        String newPuzzle = '';
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Add New Puzzle to $category', style: TextStyle(color: Colors.cyanAccent)),
          content: TextField(
            onChanged: (value) {
              newPuzzle = value;
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter puzzle name',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newPuzzle.isNotEmpty) {
                  setState(() {
                    puzzleList.add(newPuzzle);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  void _deletePuzzle(List<String> puzzleList, int index) {
    setState(() {
      puzzleList.removeAt(index);
    });
  }

  Widget _buildPuzzleList(List<String> puzzleList, String category) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('$category Puzzles', style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.cyanAccent, size: 20),
            onPressed: () => _addPuzzle(puzzleList, category),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: puzzleList.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            title: Text(
              puzzleList[index],
              style: TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 18),
              onPressed: () => _deletePuzzle(puzzleList, index),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(text: 'VR'),
              Tab(text: 'Coding'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPuzzleList(vrPuzzles, 'VR'),
                _buildPuzzleList(codingPuzzles, 'Coding'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
