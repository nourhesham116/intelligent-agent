import 'package:flutter/material.dart';
import 'huffmanintro.dart';
import 'huffman_code.dart';
import 'huffman_quiz.dart';

class HuffmanLessonSelector extends StatelessWidget {
  const HuffmanLessonSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> lessonTitles = ['Introduction', 'Code', 'Quiz'];

    return Scaffold(
      body: Stack(
        children: [
          // Sci-fi gradient background with image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3A0CA3), // Deep violet
                  Color(0xFF7209B7), // Vivid purple
                  Color(0xFF4361EE), // Neon bluish-purple
                  Color(0xFF4CC9F0), // Accent cyan
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Image.asset('assets/images/huffman.png', height: 400),
              ),
            ),
          ),

          // White curved bottom section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.2,
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: Column(
                children:
                    lessonTitles.map((title) {
                      return GestureDetector(
                        onTap: () {
                          if (title == 'Introduction') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HuffmanIntroPage(),
                              ),
                            );
                          } else if (title == 'Code') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HuffmanCodePage(),
                              ),
                            );
                          } else if (title == 'Quiz') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HuffmanQuizPage(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFFF2F1FF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  78,
                                  158,
                                  219,
                                ).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C3DFE),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF5C3DFE),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
