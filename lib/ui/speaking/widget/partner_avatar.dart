import 'dart:math' as math;

import 'package:flutter/material.dart';

class PartnerAvatar extends StatefulWidget {
  const PartnerAvatar({super.key, this.limitFraction});

  /// 0.0 = limit reached, 1.0 = full time remaining.
  /// Null = no limit (arc hidden).
  final double? limitFraction;

  @override
  State<PartnerAvatar> createState() => _PartnerAvatarState();
}

class _PartnerAvatarState extends State<PartnerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late Animation<double> _anim;
  double _target = 1.0;

  @override
  void initState() {
    super.initState();
    _target = widget.limitFraction ?? 1.0;
    // Start at current fraction — no initial animation.
    _anim = Tween<double>(begin: _target, end: _target).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant PartnerAvatar old) {
    super.didUpdateWidget(old);
    final next = widget.limitFraction ?? 1.0;
    if (next == _target) return;
    _anim = Tween<double>(begin: _anim.value, end: next).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _target = next;
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => CustomPaint(
        foregroundPainter: widget.limitFraction != null
            ? _LimitArcPainter(fraction: _anim.value.clamp(0.0, 1.0))
            : null,
        child: child,
      ),
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D1B4B).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: ClipOval(
          child: Image.asset(
            'assets/images/ai_girl.png',
            width: 228,
            height: 228,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _LimitArcPainter extends CustomPainter {
  const _LimitArcPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 5.0;
    final radius = size.width / 2 - strokeWidth / 2;
    const startAngle = -math.pi / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final color = _arcColor();

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF1340C4).withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (fraction <= 0) return;

    final sweepAngle = fraction * 2 * math.pi;

    // Glow
    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Main arc
    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  Color _arcColor() {
    if (fraction >= 0.5) return const Color(0xFF1340C4);
    final t = 1.0 - (fraction / 0.5);
    return Color.lerp(const Color(0xFF1340C4), const Color(0xFFEF4444), t)!;
  }

  @override
  bool shouldRepaint(_LimitArcPainter old) => old.fraction != fraction;
}
