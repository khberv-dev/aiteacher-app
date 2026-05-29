import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shown when the user has no vocabulary words yet — the server populates
/// these from AI Speaking assessments, so we point them there.
class TrainingEmptyView extends StatelessWidget {
  const TrainingEmptyView({super.key, required this.onStartSpeaking});

  final VoidCallback onStartSpeaking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySubtle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Lug'atingiz hali bo'sh",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "AI Speaking mashqini yakunlang — siz uchun ustuvor so'zlar "
            "shu yerda jamlanadi.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onStartSpeaking,
              icon: const Icon(Icons.mic_rounded),
              label: const Text(
                "AI Speaking ochish",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
