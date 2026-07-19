import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

class ReportVocabChart extends StatelessWidget {
  const ReportVocabChart({super.key, required this.detail});

  final VocabularyDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeSize = detail.activeSizeEstimate.toDouble();
    final target = detail.nextLevel.targetSize.toDouble();
    final c1 = target * 1.6;
    final c2 = target * 2.5;
    final maxValue = c2.clamp(1, double.infinity);

    final bars = <_VocabBar>[
      _VocabBar('A1', 500, const Color(0xFF22C55E)),
      _VocabBar('A2', 1500, const Color(0xFF22C55E)),
      _VocabBar(
        l10n.speakingReportVocabChartYouLabel('B1'),
        activeSize,
        const Color(0xFFF5B700),
      ),
      _VocabBar(
        l10n.speakingReportVocabChartTargetLabel(detail.nextLevel.level),
        target,
        const Color(0x4D3B82F6),
      ),
      _VocabBar('C1', c1, const Color(0x263B82F6)),
      _VocabBar('C2', c2, const Color(0x143B82F6)),
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
            ReportSectionLabel(text: l10n.speakingReportVocabChartSectionLabel),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < bars.length; i++) ...[
                    Expanded(
                      child: _Bar(bar: bars[i], maxValue: maxValue.toDouble()),
                    ),
                    if (i < bars.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VocabBar {
  const _VocabBar(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar, required this.maxValue});

  final _VocabBar bar;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: (bar.value / maxValue).clamp(0.0, 1.0),
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: bar.color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          bar.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
