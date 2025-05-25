import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassesManager extends StatefulWidget {
  const ClassesManager({Key? key}) : super(key: key);

  @override
  _ClassesManagerState createState() => _ClassesManagerState();
}

class _ClassesManagerState extends State<ClassesManager> {
  TextEditingController classController = TextEditingController();
  TextEditingController farahClassController = TextEditingController();
  List<String> classNames = [];
  List<String> farahClassNames = [];
  Map<String, List<Map<String, dynamic>>> classPuzzles = {};

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadFarahClasses();
  }

  void _loadClasses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      classNames = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _loadFarahClasses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('classes').get();
    for (var doc in snapshot.docs) {
      final puzzles = doc['puzzles'] ?? [];
      classPuzzles[doc.id] = List<Map<String, dynamic>>.from(puzzles);
    }
    setState(() {
      farahClassNames = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _addClass() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Add Class',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          content: TextField(
            controller: classController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter class name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onPressed: () async {
                String className = classController.text.trim();
                if (className.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('classes')
                      .doc(className)
                      .set({'created_at': FieldValue.serverTimestamp()});
                  setState(() {
                    classNames.add(className);
                  });
                  classController.clear();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addFarahClass() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Add Farah Class',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          content: TextField(
            controller: farahClassController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter class name',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onPressed: () async {
                String className = farahClassController.text.trim();
                if (className.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('farahclasses')
                      .doc(className)
                      .set({
                        'created_at': FieldValue.serverTimestamp(),
                        'puzzles': [],
                      });
                  setState(() {
                    farahClassNames.add(className);
                  });
                  farahClassController.clear();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addPuzzleToFarahClass(String className) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> puzzles = [
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
          'Graph coloring',
          'Huffman',
          'Tsp',
        ];

        String selectedPuzzle = '';
        int puzzleSize = 0;
        List<String> parameters = [];
        List<TextEditingController> freqControllers = List.generate(
          6,
          (_) => TextEditingController(),
        );
        List<TextEditingController> symbolControllers = List.generate(
          6,
          (_) => TextEditingController(),
        );
        int? targetNumber;
        int? targetValue;
        int? nodeCount;
        int? extraEdgeCount;
        int? maxWeight;
        List<Map<String, int>> knapsackBoxes = [];

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              title: Text(
                'Add Puzzle to $className',
                style: const TextStyle(color: Colors.cyanAccent),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedPuzzle.isEmpty ? null : selectedPuzzle,
                      hint: const Text(
                        'Select a Puzzle',
                        style: TextStyle(color: Colors.white),
                      ),
                      dropdownColor: Colors.black87,
                      onChanged: (newPuzzle) {
                        setLocalState(() {
                          selectedPuzzle = newPuzzle!;
                          puzzleSize = 0;
                          parameters = [];
                          knapsackBoxes = [];
                        });
                      },
                      items:
                          puzzles
                              .map(
                                (puzzle) => DropdownMenuItem(
                                  value: puzzle,
                                  child: Text(
                                    puzzle,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),

                    // N-Queens
                    if (selectedPuzzle == 'N-Queens')
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter grid size',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          puzzleSize = int.tryParse(value) ?? 0;
                        },
                      ),

                    // Bubble Sort
                    if (selectedPuzzle == 'Bubble Sort') ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter size of array',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          setLocalState(() {
                            puzzleSize = int.tryParse(value) ?? 0;
                            parameters = List.generate(puzzleSize, (_) => '');
                          });
                        },
                      ),
                      for (int i = 0; i < parameters.length; i++)
                        TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Element ${i + 1}',
                            hintStyle: const TextStyle(color: Colors.white54),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                            ),
                          ),
                          onChanged: (value) {
                            parameters[i] = value;
                          },
                        ),
                    ],

                    // Binary & Linear Search
                    if (selectedPuzzle == 'Binary Search' ||
                        selectedPuzzle == 'Linear Search') ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter size of array',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          setLocalState(() {
                            puzzleSize = int.tryParse(value) ?? 0;
                            parameters = List.generate(puzzleSize, (_) => '');
                          });
                        },
                      ),
                      for (int i = 0; i < parameters.length; i++)
                        TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Element ${i + 1}',
                            hintStyle: const TextStyle(color: Colors.white54),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyanAccent),
                            ),
                          ),
                          onChanged: (value) {
                            parameters[i] = value;
                          },
                        ),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                              selectedPuzzle == 'Binary Search'
                                  ? 'Enter targetNumber'
                                  : 'Enter target',
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          if (selectedPuzzle == 'Binary Search') {
                            targetNumber = int.tryParse(value) ?? 0;
                          } else {
                            targetValue = int.tryParse(value) ?? 0;
                          }
                        },
                      ),
                    ],

                    // TSP
                    if (selectedPuzzle == 'Tsp') ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter node count',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          nodeCount = int.tryParse(value) ?? 0;
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter extra edge count',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          extraEdgeCount = int.tryParse(value) ?? 0;
                        },
                      ),
                    ],

                    // Knapsack
                    if (selectedPuzzle == 'Knapsack') ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter number of boxes',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          setLocalState(() {
                            puzzleSize = int.tryParse(value) ?? 0;
                            parameters = List.filled(puzzleSize * 2, '');
                          });
                        },
                      ),
                      for (int i = 0; i < puzzleSize; i++)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Value ${i + 1}',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  parameters[i] = value;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Weight ${i + 1}',
                                  hintStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  parameters[i + puzzleSize] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter max weight',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          maxWeight = int.tryParse(value) ?? 0;
                        },
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter target',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onChanged: (value) {
                          targetValue = int.tryParse(value) ?? 0;
                        },
                      ),
                    ],

                    // Graph Coloring & Huffman (Already present)
                    // [no changes required here]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  onPressed: () async {
                    Map<String, dynamic> puzzleData = {
                      'puzzle_name':
                          selectedPuzzle == 'N-Queens'
                              ? 'Nqueens'
                              : selectedPuzzle,
                    };

                    if (selectedPuzzle == 'N-Queens') {
                      puzzleData['grid_size'] = puzzleSize;
                    } else if (selectedPuzzle == 'Bubble Sort') {
                      puzzleData['size'] =
                          parameters
                              .map((e) => int.tryParse(e.trim()) ?? 0)
                              .toList();
                    } else if (selectedPuzzle == 'Binary Search' ||
                        selectedPuzzle == 'Linear Search') {
                      puzzleData['parameters'] =
                          parameters
                              .map((e) => int.tryParse(e.trim()) ?? 0)
                              .toList();
                      puzzleData[selectedPuzzle == 'Binary Search'
                              ? 'targetNumber'
                              : 'target'] =
                          selectedPuzzle == 'Binary Search'
                              ? targetNumber ?? 0
                              : targetValue ?? 0;
                    } else if (selectedPuzzle == 'Tsp') {
                      puzzleData['nodeCount'] = nodeCount ?? 0;
                      puzzleData['extraEdgeCount'] = extraEdgeCount ?? 0;
                    } else if (selectedPuzzle == 'Knapsack') {
                      List<Map<String, int>> boxes = [];
                      for (int i = 0; i < puzzleSize; i++) {
                        int value = int.tryParse(parameters[i]) ?? 0;
                        int weight =
                            int.tryParse(parameters[i + puzzleSize]) ?? 0;
                        boxes.add({'value': value, 'weight': weight});
                      }
                      puzzleData['boxes'] = boxes;
                      puzzleData['maxWeight'] = maxWeight ?? 0;
                      puzzleData['target'] = targetValue ?? 0;
                    } else if (selectedPuzzle == 'Graph coloring') {
                      Map<String, List<String>> connections = {};
                      for (var line in parameters) {
                        if (line.trim().isEmpty) continue;
                        var parts = line.split(':');
                        if (parts.length == 2) {
                          var node = parts[0].trim();
                          var neighbors =
                              parts[1]
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                          connections[node] = neighbors;
                        }
                      }
                      puzzleData['connections'] =
                          connections.entries
                              .map(
                                (entry) =>
                                    "${entry.key}:${entry.value.join(',')}",
                              )
                              .toList();
                    } else if (selectedPuzzle == 'Huffman') {
                      puzzleData['frequencies'] =
                          freqControllers
                              .map((c) => int.tryParse(c.text.trim()) ?? 0)
                              .toList();
                      puzzleData['symbols'] =
                          symbolControllers.map((c) => c.text.trim()).toList();
                    }

                    await FirebaseFirestore.instance
                        .collection('farahclasses')
                        .doc(className)
                        .update({
                          'puzzles': FieldValue.arrayUnion([puzzleData]),
                        });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFarahClassList() {
    return ListView.builder(
      itemCount: farahClassNames.length,
      itemBuilder: (context, index) {
        String className = farahClassNames[index];
        List<Map<String, dynamic>> puzzles = classPuzzles[className] ?? [];
        return ExpansionTile(
          title: Text(
            className,
            style: const TextStyle(color: Colors.cyanAccent),
          ),
          children: [
            for (var puzzle in puzzles)
              ListTile(
                title: Text(
                  puzzle['puzzle_name'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  puzzle.entries
                      .where((e) => e.key != 'puzzle_name')
                      .map((e) {
                        if (e.key == 'connections' && e.value is Map) {
                          return "connections:\n" +
                              (e.value as Map).entries
                                  .map(
                                    (entry) =>
                                        "  ${entry.key}: ${(entry.value as List).join(', ')}",
                                  )
                                  .join("\n");
                        } else if (e.key == 'raw_connections') {
                          return "raw: ${(e.value as List).join(', ')}";
                        } else if (e.value is List) {
                          return "${e.key}: ${e.value}";
                        } else {
                          return "${e.key}: ${e.value}";
                        }
                      })
                      .join("\n"),
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            TextButton.icon(
              icon: const Icon(Icons.add, color: Colors.cyanAccent),
              label: const Text(
                'Add Puzzle',
                style: TextStyle(color: Colors.cyanAccent),
              ),
              onPressed: () => _addPuzzleToFarahClass(className),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addClass,
          child: const Text(
            'Add Class (classes)',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
        ),
        ElevatedButton(
          onPressed: _addFarahClass,
          child: const Text(
            'Add Class (farahclasses)',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
        ),
        const SizedBox(height: 20),
        const Text(
          'Farah Classes:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Expanded(child: _buildFarahClassList()),
      ],
    );
  }
}
