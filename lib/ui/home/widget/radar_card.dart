import 'dart:math' as math;

import 'package:flutter/material.dart';

class RadarCard extends StatelessWidget {
  const RadarCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
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
            const SizedBox(
              width: 120,
              height: 120,
              child: _RadarChart(level: 'B1'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarChart extends StatelessWidget {
  const _RadarChart({required this.level});

  final String level;

  static const _vertexColors = [
    Color(0xFF60A5FA),
    Color(0xFF2DD4BF),
    Color(0xFFFCD34D),
    Color(0xFFF9A8D4),
    Color(0xFFC4B5FD),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox.expand(child: CustomPaint(painter: _PentagonPainter())),
        Text(
          level,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        ..._vertexDots(),
      ],
    );
  }

  List<Widget> _vertexDots() {
    const size = 120.0;
    const radius = size / 2;
    const dotSize = 8.0;
    return List.generate(5, (i) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final dx = radius + radius * math.cos(angle) - dotSize / 2;
      final dy = radius + radius * math.sin(angle) - dotSize / 2;
      return Positioned(
        left: dx,
        top: dy,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _vertexColors[i],
          ),
        ),
      );
    });
  }
}

class _PentagonPainter extends CustomPainter {
  const _PentagonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radii = [size.width / 2, size.width / 2 * 0.75, size.width / 2 * 0.5];
    final fills = [
      const Color(0x1F2DD4BF),
      const Color(0x00FFFFFF),
      const Color(0x00FFFFFF),
    ];
    final strokeColors = [
      const Color(0x80FFFFFF),
      const Color(0x14FFFFFF),
      const Color(0x14FFFFFF),
    ];
    final strokeWidths = [1.5, 1.0, 1.0];

    for (var i = 0; i < radii.length; i++) {
      final path = _pentagonPath(center, radii[i]);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = fills[i],
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = strokeColors[i]
          ..strokeWidth = strokeWidths[i],
      );
    }
  }

  Path _pentagonPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
