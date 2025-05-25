import 'package:flutter/material.dart';
import 'huffman_code.dart';

class HuffmanIntroPage extends StatelessWidget {
  const HuffmanIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔮 Sci-fi Gradient Background
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

          // 🔙 Back Button at the top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context); // 👈 return to selector
                },
              ),
            ),
          ),

          // ⚪ White curved foreground container
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
                      'Great job! You just used something called',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arial',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Huffman Encoding!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        color: Color(0xFF5C3DFE),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'What You Did:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arial',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• Identified and placed missing symbols in a binary tree based on frequency.',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          Text(
                            '• Completed the tree to ensure all leaf nodes were filled.',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          Text(
                            '• Traced paths from root to leaf: left adds a 0, right adds a 1.',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          Text(
                            '• Encoded each symbol using its binary path — frequent symbols get shorter codes.',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🚀 Continue Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HuffmanCodePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C3DFE),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
