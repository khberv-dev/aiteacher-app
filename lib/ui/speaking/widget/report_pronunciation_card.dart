import 'dart:math' as math;

import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

enum _PronunStatus { good, medium, weak }

class _DetailRow {
  const _DetailRow({required this.label, required this.status});

  final String label;
  final _PronunStatus status;
}

class ReportPronunciationCard extends StatelessWidget {
  const ReportPronunciationCard({
    super.key,
    required this.detail,
    required this.score,
  });

  final PronunciationDetail detail;
  final int score;

  @override
  Widget build(BuildContext context) {
    final strong = detail.strongAreas.map((s) => s.toLowerCase()).toSet();
    _PronunStatus status(String key) {
      if (strong.contains(key)) return _PronunStatus.good;
      if (score >= 65) return _PronunStatus.medium;
      return _PronunStatus.weak;
    }

    final details = <_DetailRow>[
      _DetailRow(label: 'Unli tovushlar', status: status('vowels')),
      _DetailRow(label: 'Undosh tovushlar', status: status('consonants')),
      _DetailRow(label: "Urg'u (stress)", status: status('stress placement')),
      _DetailRow(label: 'Intonatsiya', status: status('intonation')),
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
            const ReportSectionLabel(text: 'TALAFFUZ TAHLILI'),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: _DonutPainter(progress: score / 100),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score%',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'BALL',
                            style: TextStyle(
                              color: Color(0xFF6B6860),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < details.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _Detail(detail: details[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (detail.soundsToPractice.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                "Mashq qilish kerak bo'lgan tovushlar",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in detail.soundsToPractice) _SoundChip(label: s),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.detail});

  final _DetailRow detail;

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg, chipText) = switch (detail.status) {
      _PronunStatus.good => (
        const Color(0x1A0D9488),
        const Color(0xFF065F46),
        '✓ Yaxshi',
      ),
      _PronunStatus.medium => (
        const Color(0x1FF5B700),
        const Color(0xFF92400E),
        "~ O'rta",
      ),
      _PronunStatus.weak => (
        const Color(0x14EF4444),
        const Color(0xFF991B1B),
        '✗ Zaif',
      ),
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            detail.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(7),
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
    );
  }
}

class _SoundChip extends StatelessWidget {
  const _SoundChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x0FEF4444),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0x26EF4444)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..color = const Color(0xFFF0EDE6);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF22C55E);
    canvas.drawCircle(center, radius, track);
    final start = -math.pi / 2;
    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
