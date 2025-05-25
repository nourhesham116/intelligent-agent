import 'package:flutter/material.dart';

class HuffmanQuizPage extends StatefulWidget {
  const HuffmanQuizPage({Key? key}) : super(key: key);

  @override
  _HuffmanQuizPageState createState() => _HuffmanQuizPageState();
}

class _HuffmanQuizPageState extends State<HuffmanQuizPage> {
  int currentQuestion = 0;
  int score = 0;
  bool quizCompleted = false;
  int? selectedOption;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the main advantage of Huffman coding?',
      'options': [
        'It uses fixed-length binary codes',
        'It stores data uncompressed',
        'It gives shorter codes to more frequent symbols',
        'It sorts symbols alphabetically',
      ],
      'answer': 2,
    },
    {
      'question': 'Which data structure is used in Huffman tree construction?',
      'options': ['Stack', 'Queue', 'Priority Queue', 'Hash Map'],
      'answer': 2,
    },
    {
      'question': 'What does moving left in a Huffman tree add to the code?',
      'options': ['1', '0', 'Nothing', 'Depends on frequency'],
      'answer': 1,
    },
  ];

  List<int?> userAnswers = [];

  void submitAnswer() {
    if (selectedOption == null) return;

    userAnswers.add(selectedOption);

    if (selectedOption == questions[currentQuestion]['answer']) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedOption = null;
      });
    } else {
      setState(() => quizCompleted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3DFE),
        elevation: 0,
        title: const Text(
          'Huffman Quiz',
          style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A0CA3),
              Color(0xFF7209B7),
              Color(0xFF4361EE),
              Color(0xFF4CC9F0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(60)),
          ),
          child:
              quizCompleted
                  ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Color(0xFF5C3DFE),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Quiz Completed!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[700],
                              fontFamily: 'Orbitron',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Your Score: $score / ${questions.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Review:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3DFE),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ...List.generate(questions.length, (index) {
                          final q = questions[index];
                          final correctIndex = q['answer'];
                          final selected = userAnswers[index];

                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.black12,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Q${index + 1}: ${q['question']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(q['options'].length, (i) {
                                    final isCorrect = i == correctIndex;
                                    final isSelected = i == selected;

                                    Color bgColor = Colors.white;
                                    Color textColor = Colors.black87;
                                    if (isCorrect) {
                                      bgColor = const Color(
                                        0xFFD1F7C4,
                                      ); // light green
                                    }
                                    if (isSelected && !isCorrect) {
                                      bgColor = const Color(
                                        0xFFFFD6D6,
                                      ); // light red
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isCorrect
                                                ? Icons.check_circle
                                                : isSelected
                                                ? Icons.cancel
                                                : Icons.circle_outlined,
                                            color:
                                                isCorrect
                                                    ? Colors.green
                                                    : isSelected
                                                    ? Colors.red
                                                    : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              q['options'][i],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: textColor,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  )
                  : buildQuestionCard(),
        ),
      ),
    );
  }

  Widget buildQuestionCard() {
    final q = questions[currentQuestion];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${currentQuestion + 1} of ${questions.length}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Color(0xFF5C3DFE),
          ),
        ),
        const SizedBox(height: 16),

        // White Question Card
        Card(
          color: Colors.white,
          shadowColor: Colors.black12,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q['question'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(q['options'].length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color:
                          selectedOption == index
                              ? const Color.fromARGB(255, 79, 118, 197)
                              : Colors.white,
                      border: Border.all(
                        color:
                            selectedOption == index
                                ? const Color(0xFF5C3DFE)
                                : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<int>(
                      value: index,
                      groupValue: selectedOption,
                      activeColor: const Color(0xFF5C3DFE),
                      title: Text(
                        q['options'][index],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => selectedOption = val);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Submit Button
        Center(
          child: ElevatedButton(
            onPressed: submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C3DFE),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
            ),
            child: const Text(
              'Submit Answer',
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
      ],
    );
  }
}
