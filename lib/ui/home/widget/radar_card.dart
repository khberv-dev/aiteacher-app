import 'dart:math' as math;

import 'package:ai_teacher/core/user/data/user_dtos.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadarCard extends ConsumerWidget {
  const RadarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentUserProvider).valueOrNull?.student;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C1D2E), Color(0xD90F172A), Color(0x8C0F172A)],
            stops: [0, 0.5, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BILIM XARITAM',
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Zo'r ketayapsiz!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    "Har kun o'sib",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    'bormoqdasiz 🚀',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 132,
              height: 132,
              child: _RadarChart(student: student),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarAxis {
  const _RadarAxis({
    required this.label,
    required this.angle,
    required this.color,
  });

  /// Single-letter label drawn just outside the vertex (S/L/R/W).
  final String label;

  /// Radians, measured from +x clockwise as in the painter math.
  final double angle;
  final Color color;
}

class _RadarChart extends StatelessWidget {
  const _RadarChart({this.student});

  final StudentProfile? student;

  static const _axes = [
    // Top / right / bottom / left (-pi/2, 0, pi/2, pi)
    _RadarAxis(label: 'S', angle: -math.pi / 2, color: Color(0xFF60A5FA)),
    _RadarAxis(label: 'L', angle: 0, color: Color(0xFF2DD4BF)),
    _RadarAxis(label: 'R', angle: math.pi / 2, color: Color(0xFFFCD34D)),
    _RadarAxis(label: 'W', angle: math.pi, color: Color(0xFFF9A8D4)),
  ];

  @override
  Widget build(BuildContext context) {
    final levels = student == null
        ? const <double>[0, 0, 0, 0]
        : [
            student!.speaking.fraction,
            student!.listening.fraction,
            student!.reading.fraction,
            student!.writing.fraction,
          ];
    final overall = student?.overall.label ?? 'A0';
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _RadarPainter(levels: levels, axes: _axes),
          ),
        ),
        Text(
          overall,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.levels, required this.axes});

  final List<double> levels;
  final List<_RadarAxis> axes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background rings.
    const rings = [1.0, 0.66, 0.33];
    final ringStrokes = [
      const Color(0x80FFFFFF),
      const Color(0x33FFFFFF),
      const Color(0x14FFFFFF),
    ];
    final ringWidths = [1.5, 1.0, 1.0];

    for (var i = 0; i < rings.length; i++) {
      canvas.drawPath(
        _polyPath(center, radius * rings[i]),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = ringStrokes[i]
          ..strokeWidth = ringWidths[i],
      );
    }
    // Fill the outer ring softly so the body still has the teal wash.
    canvas.drawPath(
      _polyPath(center, radius),
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0x1F2DD4BF),
    );

    // Axis spokes.
    final spokePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1;
    for (final axis in axes) {
      final p = _pointAt(center, radius, axis.angle, 1);
      canvas.drawLine(center, p, spokePaint);
    }

    // Data polygon.
    if (levels.any((l) => l > 0)) {
      final dataPath = Path();
      for (var i = 0; i < axes.length; i++) {
        final p = _pointAt(center, radius, axes[i].angle, levels[i]);
        if (i == 0) {
          dataPath.moveTo(p.dx, p.dy);
        } else {
          dataPath.lineTo(p.dx, p.dy);
        }
      }
      dataPath.close();

      canvas.drawPath(
        dataPath,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0x4D2DD4BF),
      );
      canvas.drawPath(
        dataPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF2DD4BF)
          ..strokeWidth = 1.6,
      );
    }

    // Vertex dots + axis letters.
    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      final level = levels[i];
      final dot = _pointAt(center, radius, axis.angle, level);
      canvas.drawCircle(
        dot,
        4.5,
        Paint()
          ..color = axis.color
          ..style = PaintingStyle.fill,
      );

      final labelOffset = _pointAt(center, radius + 10, axis.angle, 1);
      final tp = TextPainter(
        text: TextSpan(
          text: axis.label,
          style: TextStyle(
            color: axis.color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelOffset.dx - tp.width / 2, labelOffset.dy - tp.height / 2),
      );
    }
  }

  Path _polyPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < axes.length; i++) {
      final p = _pointAt(center, radius, axes[i].angle, 1);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  Offset _pointAt(Offset center, double radius, double angle, double fraction) {
    final r = radius * fraction;
    return Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.levels != levels || old.axes != axes;
}
