import 'package:flutter/material.dart';
import 'huffman_quiz.dart';

class HuffmanCodePage extends StatefulWidget {
  const HuffmanCodePage({Key? key}) : super(key: key);

  @override
  State<HuffmanCodePage> createState() => _HuffmanCodePageState();
}

class _HuffmanCodePageState extends State<HuffmanCodePage> {
  int currentPage = 0;

  final List<Map<String, dynamic>> codeSnippets = [
    {
      'code': 'struct Node { char symbol; int freq; Node *left, *right; };',
      'explanation':
          'Defines the node structure for the tree. Each node holds a character and its frequency.',
      'icon': Icons.account_tree_outlined,
      'color': Colors.deepPurple,
    },
    {
      'code':
          'struct Compare { bool operator()(Node* a, Node* b) { return a->freq > b->freq; } };',
      'explanation':
          'Defines how nodes are compared in the priority queue — smaller frequencies have higher priority.',
      'icon': Icons.compare_arrows,
      'color': Colors.purple,
    },
    {
      'code': 'priority_queue<Node*, vector<Node*>, Compare> pq;',
      'explanation':
          'Creates a min-heap using a priority queue for efficient tree construction.',
      'icon': Icons.layers,
      'color': Colors.indigo,
    },
    {
      'code': 'while (pq.size() > 1) { ... }',
      'explanation':
          'Keeps combining the two lowest frequency nodes until one final tree is built.',
      'icon': Icons.loop,
      'color': Colors.teal,
    },
    {
      'code': 'Node* merged = new Node( left->freq + right->freq);',
      'explanation':
          'Merges two nodes into a new internal node with combined frequency.',
      'icon': Icons.merge_type,
      'color': Colors.blue,
    },
    {
      'code': 'void generateCodes(Node* root, string code) { ... }',
      'explanation':
          'Recursively traverses the tree to assign a binary code to each symbol.',
      'icon': Icons.code,
      'color': Colors.deepOrange,
    },
  ];

  Widget codeLine(String code, String explanation, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1FF),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * 2;
    int endIndex = (startIndex + 2).clamp(0, codeSnippets.length);
    final currentSnippets = codeSnippets.sublist(startIndex, endIndex);

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3A0CA3),
                  Color(0xFF7209B7),
                  Color(0xFF4361EE),
                  Color(0xFF4CC9F0),
                ],
              ),
            ),
          ),

          // 🔙 Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // Back to HuffmanIntroPage
                },
              ),
            ),
          ),

          // ⚪ Foreground content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Understanding the Huffman Challenge',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        color: Color(0xFF5C3DFE),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...currentSnippets.map(
                      (snippet) => codeLine(
                        snippet['code'],
                        snippet['explanation'],
                        snippet['icon'],
                        snippet['color'],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ⏭️ Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (currentPage > 0)
                          ElevatedButton(
                            onPressed: () {
                              setState(() => currentPage--);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C3DFE),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (endIndex < codeSnippets.length)
                          ElevatedButton(
                            onPressed: () {
                              setState(() => currentPage++);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CC9F0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (endIndex >= codeSnippets.length)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HuffmanQuizPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CC9F0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Continue to Quiz',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
