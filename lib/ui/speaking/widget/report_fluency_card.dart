import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

class ReportFluencyCard extends StatelessWidget {
  const ReportFluencyCard({
    super.key,
    required this.fluency,
    required this.overall,
  });

  final FluencyDetail fluency;
  final int overall;

  @override
  Widget build(BuildContext context) {
    final metrics = <_FluencyMetric>[
      _FluencyMetric(
        '⚡',
        'Nutq tezligi',
        '${fluency.speechRateWpm}wpm',
        (fluency.speechRateWpm / 200).clamp(0.0, 1.0),
      ),
      _FluencyMetric(
        '⏸',
        'Kamroq pauza',
        '${fluency.pauseControl}%',
        fluency.pauseControl / 100,
      ),
      _FluencyMetric(
        '🎯',
        'Aniq ifoda',
        '${fluency.clarity}%',
        fluency.clarity / 100,
      ),
      _FluencyMetric(
        '🌊',
        'Intonatsiya',
        '${fluency.intonation}%',
        fluency.intonation / 100,
      ),
      _FluencyMetric(
        '🔄',
        "So'z xilma-xilligi",
        '${fluency.lexicalDiversity}%',
        fluency.lexicalDiversity / 100,
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
            const ReportSectionLabel(text: 'RAVONLIK (FLUENCY)'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Umumiy ball',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$overall',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '/100',
                      style: TextStyle(
                        color: Color(0xFF6B6860),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MetricRow(metric: metrics[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _FluencyMetric {
  const _FluencyMetric(this.emoji, this.label, this.value, this.fraction);

  final String emoji;
  final String label;
  final String value;
  final double fraction;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final _FluencyMetric metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(metric.emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(
            metric.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              color: const Color(0xFFF0EDE6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: metric.fraction,
                child: Container(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          metric.value,
          style: const TextStyle(
            color: Color(0xFF6B6860),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
