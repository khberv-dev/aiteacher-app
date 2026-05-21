import 'package:flutter/material.dart';

class PartnerAvatar extends StatelessWidget {
  const PartnerAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B4B).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ai_girl.png',
          width: 228,
          height: 228,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
