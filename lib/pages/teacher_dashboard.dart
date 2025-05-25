import 'package:flutter/material.dart';
import 'puzzle_manager.dart';
import 'classes_manager.dart';
import 'reports.dart';
import 'lessons.dart'; // ✅ Make sure this matches your actual lessons class file

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int selectedIndex = 0;

  final List<String> sections = [
    'Dashboard',
    'Classes',
    'Puzzles',
    'Reports',
    'Lessons', // ✅ Moved Lessons to index 4
    'Settings',
  ];

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.class_,
    Icons.extension,
    Icons.bar_chart,
    Icons.menu_book, // ✅ Icon for Lessons
    Icons.settings,
  ];

  Widget _buildContent(int index) {
    switch (index) {
      case 1:
        return ClassesManager();
      case 2:
        return PuzzleManager();
      case 3:
        return ReportsPage();
      case 4:
        return LessonsPage(); // ✅ Rename to your actual lessons class name
      default:
        return Center(
          child: Text(
            sections[index],
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              shadows: [Shadow(blurRadius: 12, color: Colors.cyanAccent)],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: Text(
          sections[selectedIndex],
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 12, color: Colors.cyanAccent)],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black87),
              child: Center(
                child: Icon(Icons.android, color: Colors.cyanAccent, size: 40),
              ),
            ),
            for (int i = 0; i < icons.length; i++)
              ListTile(
                leading: Icon(
                  icons[i],
                  color:
                      selectedIndex == i ? Colors.cyanAccent : Colors.white54,
                ),
                title: Text(
                  sections[i],
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color:
                        selectedIndex == i ? Colors.cyanAccent : Colors.white,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedIndex = i;
                    Navigator.pop(context);
                  });
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(selectedIndex),
          ),
        ),
      ),
    );
  }
}
