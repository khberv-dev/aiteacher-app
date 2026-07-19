import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

class ReportResponseChart extends StatelessWidget {
  const ReportResponseChart({super.key});

  static const _bars = <_BarData>[
    _BarData('S1', 65, Color(0xFF22C55E)),
    _BarData('S2', 45, Color(0xFFEF4444)),
    _BarData('S3', 57, Color(0xFFF5B700)),
    _BarData('S4', 73, Color(0xFF22C55E)),
    _BarData('S5', 37, Color(0xFFEF4444)),
    _BarData('S6', 61, Color(0xFFF5B700)),
    _BarData('S7', 49, Color(0xFFF5B700)),
    _BarData('S8', 69, Color(0xFF22C55E)),
    _BarData('S9', 41, Color(0xFFEF4444)),
    _BarData('S10', 59, Color(0xFFF5B700)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              text: l10n.speakingReportResponseChartSectionLabel,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < _bars.length; i++) ...[
                    Expanded(child: _Bar(bar: _bars[i])),
                    if (i < _bars.length - 1) const SizedBox(width: 5),
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

class _BarData {
  const _BarData(this.label, this.height, this.color);

  final String label;
  final double height;
  final Color color;
}

class _Bar extends StatelessWidget {
  const _Bar({required this.bar});

  final _BarData bar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: bar.height / 80,
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: bar.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bar.label,
          style: const TextStyle(
            color: Color(0xFF6B6860),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
