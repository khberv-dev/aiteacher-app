import 'dart:math' as math;

import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

class ReportRadarCard extends StatelessWidget {
  const ReportRadarCard({super.key, required this.skills});

  final AssessmentSkills skills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <_RadarSkill>[
      _RadarSkill('Speaking', skills.speaking, const Color(0xFFF5B700)),
      _RadarSkill('Vocabulary', skills.vocabulary, const Color(0xFF3B82F6)),
      _RadarSkill('Grammar', skills.grammar, const Color(0xFF0D9488)),
      _RadarSkill('Listening', skills.listening, const Color(0xFFEC4899)),
      _RadarSkill('Reading', skills.reading, const Color(0xFF7C3AED)),
      _RadarSkill('Writing', skills.writing, const Color(0xFFF97316)),
    ];

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportSectionLabel(text: l10n.speakingReportRadarSkillsSectionLabel),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(painter: _RadarPainter(skills: entries)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final s in entries) _RadarRow(skill: s)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarSkill {
  const _RadarSkill(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _RadarRow extends StatelessWidget {
  const _RadarRow({required this.skill});

  final _RadarSkill skill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: skill.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              skill.label,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${skill.value}%',
            style: const TextStyle(
              color: Color(0xFF6B6860),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.skills});

  final List<_RadarSkill> skills;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final ringFractions = [1.0, 0.75, 0.5, 0.25];
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x0F000000)
      ..strokeWidth = 1;
    for (final f in ringFractions) {
      _drawHexagon(canvas, center, maxRadius * f, ringPaint, skills.length);
    }

    final shapePoints = <Offset>[];
    for (var i = 0; i < skills.length; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / skills.length);
      final r = maxRadius * (skills[i].value / 100);
      shapePoints.add(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
      );
    }
    final path = Path()..moveTo(shapePoints.first.dx, shapePoints.first.dy);
    for (final p in shapePoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFF5B700).withValues(alpha: 0.08),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFF5B700).withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );

    for (var i = 0; i < skills.length; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / skills.length);
      final dot = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawCircle(dot, 4, Paint()..color = skills[i].color);
    }
  }

  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    int sides,
  ) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / sides);
      final pt = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.skills != skills;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        child: child,
      ),
    );
  }
}
