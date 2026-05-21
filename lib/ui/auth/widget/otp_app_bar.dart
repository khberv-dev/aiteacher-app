import 'package:ai_teacher/app/theme/app_radius.dart';
import 'package:flutter/material.dart';

class OtpAppBar extends StatelessWidget {
  const OtpAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          _BackChip(onTap: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F5F1),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5F1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: const Color(0xFFE2DED7), width: 1.5),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1A1A1A),
            size: 18,
          ),
        ),
      ),
    );
  }
}
