import 'package:flutter/material.dart';

class LekinDivider extends StatelessWidget {
  const LekinDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final lineColor = Colors.white.withValues(alpha: 0.15);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'LEKIN',
            style: TextStyle(
              color: Color(0xFF8FA3B5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}
