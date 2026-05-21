import 'package:flutter/material.dart';

class ReportSectionLabel extends StatelessWidget {
  const ReportSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B6860),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
      ),
    );
  }
}
