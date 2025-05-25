import 'package:flutter/material.dart';
import 'huffman/HuffmanLessonSelector.dart';

class LessonsPage extends StatelessWidget {
  LessonsPage({Key? key}) : super(key: key);

  final List<String> lessonTitles = [
    'Huffman',
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _AnimatedGridOverlay()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Lesson',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: lessonTitles.length,
                      itemBuilder: (context, index) {
                        return _buildLessonTile(context, lessonTitles[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == 'Huffman') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HuffmanLessonSelector()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Open lesson: $title")));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color.fromARGB(255, 218, 97, 209),
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 218, 97, 209).withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
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
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}

// 🔄 Animated grid overlay
class _AnimatedGridOverlay extends StatefulWidget {
  const _AnimatedGridOverlay();

  @override
  State<_AnimatedGridOverlay> createState() => _AnimatedGridOverlayState();
}

class _AnimatedGridOverlayState extends State<_AnimatedGridOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: GridPainter(_controller));
  }
}

class GridPainter extends CustomPainter {
  final Animation<double> animation;

  GridPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    final paint =
        Paint()
          ..color = const Color.fromARGB(255, 239, 106, 201).withOpacity(0.05)
          ..strokeWidth = 1;

    final offset = animation.value * spacing;

    for (double x = -spacing + offset; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -spacing + offset; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
