import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_feedback_html_text.dart';
import 'package:flutter/material.dart';

class WritingTaskFeedbackView extends StatelessWidget {
  const WritingTaskFeedbackView({
    super.key,
    required this.score,
    required this.feedback,
    required this.onContinue,
  });

  final int score;
  final String feedback;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreCard(score: score),
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
                      Text(
                        l10n.writingTaskFeedbackTitle,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      WritingFeedbackHtmlText(feedback: feedback),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _ContinueBar(
          label: l10n.writingTaskFeedbackContinueButton,
          onTap: onContinue,
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final int score;

  Color get _color {
    if (score >= 80) return const Color(0xFF059669);
    if (score >= 60) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$score',
              style: TextStyle(
                color: _color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.writingTaskFeedbackStepLabel,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 80
                      ? l10n.writingTaskScoreExcellent
                      : score >= 60
                      ? l10n.writingTaskScoreGood
                      : l10n.writingTaskScoreNeedsPractice,
                  style: TextStyle(
                    color: _color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.writingTaskScoreOutOf100(score),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
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

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.label, required this.onTap});

  final String label;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
