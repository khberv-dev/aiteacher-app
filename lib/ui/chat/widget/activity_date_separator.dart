import 'package:flutter/material.dart';

class ActivityDateSeparator extends StatelessWidget {
  const ActivityDateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: _Line()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: _Line()),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x14000000));
  }
}
