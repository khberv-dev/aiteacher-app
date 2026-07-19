import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/vocabulary/data/speaking_evaluation.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Result of the speaking check — overlays the flashcard while shown.
class TrainingEvaluationCard extends StatelessWidget {
  const TrainingEvaluationCard({
    super.key,
    required this.word,
    required this.evaluation,
    required this.onContinue,
  });

  /// The word that was being practised (for the header).
  final String word;
  final SpeakingEvaluation evaluation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final correct = evaluation.correct;
    final headerColor = correct
        ? const Color(0xFF16A34A)
        : const Color(0xFFB91C1C);
    final headerBg = correct
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: headerBg,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: headerColor,
                  ),
                  child: Icon(
                    correct ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        correct
                            ? l10n.vocabularyEvalCorrectTitle
                            : l10n.vocabularyEvalIncorrectTitle,
                        style: TextStyle(
                          color: headerColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        word,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _ScorePill(score: evaluation.score, color: headerColor),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (evaluation.transcription.isNotEmpty) ...[
                    _SectionLabel(l10n.vocabularyYouSaidLabel),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '“${evaluation.transcription}”',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (evaluation.pronunciationFeedback.isNotEmpty) ...[
                    _SectionLabel(l10n.vocabularyPronunciationLabel),
                    const SizedBox(height: 4),
                    Text(
                      evaluation.pronunciationFeedback,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (evaluation.usageFeedback.isNotEmpty) ...[
                    _SectionLabel(l10n.vocabularyUsageLabel),
                    const SizedBox(height: 4),
                    Text(
                      evaluation.usageFeedback,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (evaluation.suggestion.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              evaluation.suggestion,
                              style: const TextStyle(
                                color: Color(0xFF7C2D12),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        correct
                            ? l10n.vocabularyWordRemovedContinue
                            : l10n.commonContinue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}
