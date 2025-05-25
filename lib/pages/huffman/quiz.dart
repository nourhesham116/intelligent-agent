import 'package:flutter/material.dart';

class HuffmanQuizPage extends StatefulWidget {
  const HuffmanQuizPage({Key? key}) : super(key: key);

  @override
  State<HuffmanQuizPage> createState() => _HuffmanQuizPageState();
}

class _HuffmanQuizPageState extends State<HuffmanQuizPage> {
  int score = 0;
  int currentQuestion = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': "What data structure is key to building Huffman Trees?",
      'options': ['Stack', 'Queue', 'Priority Queue', 'Binary Search Tree'],
      'answer': 'Priority Queue',
    },
    {
      'question': "Which characters get shorter codes in Huffman encoding??",
      'options': ['Rare ones', 'Most frequent', 'Alphabetical', 'Random'],
      'answer': 'Most frequent',
    },
    {
      'question': "What is the time complexity of building the Huffman Tree?",
      'options': ['O(n)', 'O(n log n)', 'O(log n)', 'O(n^2)'],
      'answer': 'O(n log n)',
    },
  ];

  void checkAnswer(String selected) {
    if (selected == questions[currentQuestion]['answer']) {
      score++;
    }

    if (currentQuestion + 1 < questions.length) {
      setState(() {
        currentQuestion++;
      });
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.black87,
              title: const Text(
                "Quiz Completed",
                style: TextStyle(color: Colors.cyanAccent),
              ),
              content: Text(
                "Your score: $score / ${questions.length}",
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1a),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Huffman Quiz",
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Q${currentQuestion + 1}: ${question['question']}",
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontFamily: 'Orbitron',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ...question['options'].map<Widget>((opt) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.cyanAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
