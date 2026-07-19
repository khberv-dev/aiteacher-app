import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

enum _ErrorSeverity { weak, medium, good }

class _ErrorRow {
  const _ErrorRow({
    required this.emoji,
    required this.name,
    required this.count,
    required this.maxCount,
  });

  final String emoji;
  final String name;
  final int count;
  final int maxCount;

  _ErrorSeverity get severity {
    if (count >= 7) return _ErrorSeverity.weak;
    if (count >= 4) return _ErrorSeverity.medium;
    return _ErrorSeverity.good;
  }

  double get barFraction =>
      maxCount == 0 ? 0 : (count / maxCount).clamp(0.0, 1.0);
}

class ReportGrammarErrorsCard extends StatelessWidget {
  const ReportGrammarErrorsCard({super.key, required this.detail});

  final GrammarDetail detail;

  static ({String emoji, String label}) _categoryDisplayFor(
    AppLocalizations l10n,
    String key,
  ) {
    return switch (key) {
      'tenses' => (
        emoji: '⏰',
        label: l10n.speakingReportGrammarErrorsCardTensesLabel,
      ),
      'conditionals' => (
        emoji: '📌',
        label: l10n.speakingReportGrammarErrorsCardConditionalsLabel,
      ),
      'prepositions' => (
        emoji: '🔗',
        label: l10n.speakingReportGrammarErrorsCardPrepositionsLabel,
      ),
      'articles' => (
        emoji: '📄',
        label: l10n.speakingReportGrammarErrorsCardArticlesLabel,
      ),
      'conjunctions' => (
        emoji: '🔀',
        label: l10n.speakingReportGrammarErrorsCardConjunctionsLabel,
      ),
      'wordOrder' => (
        emoji: '🔤',
        label: l10n.speakingReportGrammarErrorsCardWordOrderLabel,
      ),
      _ => (emoji: '•', label: key),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = detail.errorsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final rows = entries.map((entry) {
      final display = _categoryDisplayFor(l10n, entry.key);
      return _ErrorRow(
        emoji: display.emoji,
        name: display.label,
        count: entry.value,
        maxCount: maxCount,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0A000000)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportSectionLabel(
              text: l10n.speakingReportGrammarErrorsCardSectionLabel,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _Row(row: rows[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final _ErrorRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = switch (row.severity) {
      _ErrorSeverity.weak => const Color(0xFFEF4444),
      _ErrorSeverity.medium => const Color(0xFFF59E0B),
      _ErrorSeverity.good => const Color(0xFF0D9488),
    };
    final (chipBg, chipFg, chipText) = switch (row.severity) {
      _ErrorSeverity.weak => (
        const Color(0x14EF4444),
        const Color(0xFF991B1B),
        l10n.speakingReportGrammarErrorsCardSeverityWeakLabel,
      ),
      _ErrorSeverity.medium => (
        const Color(0x1FF5B700),
        const Color(0xFF92400E),
        l10n.speakingReportGrammarErrorsCardSeverityMediumLabel,
      ),
      _ErrorSeverity.good => (
        const Color(0x1A0D9488),
        const Color(0xFF065F46),
        l10n.speakingReportGrammarErrorsCardSeverityGoodLabel,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBE4)),
      ),
      child: Row(
        children: [
          Text(row.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              row.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 5,
                color: const Color(0xFFE8E5DE),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: row.barFraction,
                  child: Container(color: color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.speakingReportGrammarErrorsCardCountLabel(row.count),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              chipText,
              style: TextStyle(
                color: chipFg,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
