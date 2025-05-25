import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NeonButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.cyanAccent,
        shadowColor: Colors.cyan,
        elevation: 20,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
