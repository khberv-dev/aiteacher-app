import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class _MonthEntry {
  const _MonthEntry({
    required this.month,
    required this.title,
    required this.fraction,
    required this.color,
  });

  final String month;
  final String title;
  final double fraction;
  final Color color;
}

class ReportMonthlyPlanCard extends StatelessWidget {
  const ReportMonthlyPlanCard({
    super.key,
    required this.focusAreas,
    required this.targetLevel,
    required this.currentLevel,
  });

  final List<String> focusAreas;
  final String targetLevel;
  final String currentLevel;

  static const _palette = <Color>[
    Color(0xFF0D9488),
    Color(0xFF3B82F6),
    Color(0xFF7C3AED),
    Color(0xFFF5B700),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <_MonthEntry>[
      for (var i = 0; i < focusAreas.length; i++)
        _MonthEntry(
          month: l10n.speakingReportMonthlyPlanMonthLabel(i + 1),
          title: focusAreas[i],
          fraction: ((focusAreas.length - i) / focusAreas.length).clamp(
            0.25,
            1.0,
          ),
          color: _palette[i % _palette.length],
        ),
    ];

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
            Text(
              l10n.speakingReportMonthlyPlanTitle,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.speakingReportMonthlyPlanSubtitle(
                currentLevel,
                targetLevel,
                entries.length,
              ),
              style: const TextStyle(
                color: Color(0xFF6B6860),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _EntryRow(entry: entries[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final _MonthEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              entry.month,
              style: const TextStyle(
                color: Color(0xFF6B6860),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 4,
                color: const Color(0xFFE8E5DE),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: entry.fraction,
                  child: Container(color: entry.color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
