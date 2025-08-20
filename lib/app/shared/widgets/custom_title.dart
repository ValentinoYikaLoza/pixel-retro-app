import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final String title;
  final double fontSize;

  const CustomTitle({super.key, required this.title, this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue.shade800,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
