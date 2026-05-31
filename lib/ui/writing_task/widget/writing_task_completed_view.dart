import 'package:ai_teacher/ui/writing_task/widget/writing_feedback_html_text.dart';
import 'package:flutter/material.dart';

class WritingTaskCompletedView extends StatelessWidget {
  const WritingTaskCompletedView({
    super.key,
    required this.translationScore,
    required this.backTranslationScore,
    required this.backTranslationFeedback,
    required this.onDone,
  });

  final int translationScore;
  final int backTranslationScore;
  final String backTranslationFeedback;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrophyBanner(
                  translationScore: translationScore,
                  backTranslationScore: backTranslationScore,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2-bosqich: Qayta tarjima tahlili',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      WritingFeedbackHtmlText(
                        feedback: backTranslationFeedback,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _DoneBar(onTap: onDone),
      ],
    );
  }
}

class _TrophyBanner extends StatelessWidget {
  const _TrophyBanner({
    required this.translationScore,
    required this.backTranslationScore,
  });

  final int translationScore;
  final int backTranslationScore;

  int get _average => ((translationScore + backTranslationScore) / 2).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF065F46), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vazifa yakunlandi!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _ScorePill(label: '1-bosqich', score: translationScore),
                    const SizedBox(width: 8),
                    _ScorePill(label: '2-bosqich', score: backTranslationScore),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "O'rtacha ball: $_average / 100",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DoneBar extends StatelessWidget {
  const _DoneBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: const Color(0xFF059669),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Tugallash',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
