import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the feature introduction overlay is visible.
final introActiveProvider = StateProvider<bool>((ref) => false);

/// Incremented by MainScreen each time the modal queue fully drains and the
/// intro has not yet been shown this session. HomePage listens and shows the
/// overlay on the next increment.
final introTriggerProvider = StateProvider<int>((ref) => 0);

class IntroStep {
  const IntroStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.iconBackground,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
}

/// Full-screen feature introduction overlay. Insert via [OverlayEntry].
///
/// Dims the screen with a cutout around each [steps] target widget in sequence,
/// scrolls the target into view, and shows a description card.
class FeatureIntroOverlay extends StatefulWidget {
  const FeatureIntroOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  final List<IntroStep> steps;
  final VoidCallback onComplete;

  @override
  State<FeatureIntroOverlay> createState() => _FeatureIntroOverlayState();
}

class _FeatureIntroOverlayState extends State<FeatureIntroOverlay>
    with TickerProviderStateMixin {
  int _step = 0;
  Rect? _targetRect;
  bool _busy = false;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final Animation<double> _pulse = CurvedAnimation(
    parent: _pulseCtrl,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goToStep(0));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int index) async {
    if (_busy || !mounted) return;
    _busy = true;
    if (mounted) setState(() => _targetRect = null);

    final step = widget.steps[index];
    final ctx = step.targetKey.currentContext;

    if (ctx != null) {
      try {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        await Future<void>.delayed(const Duration(milliseconds: 120));
      } catch (_) {}
    }

    if (!mounted) {
      _busy = false;
      return;
    }

    final rb = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null && rb.hasSize) {
      final offset = rb.localToGlobal(Offset.zero);
      setState(() {
        _step = index;
        _targetRect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          rb.size.width,
          rb.size.height,
        );
      });
      await _fadeCtrl.forward(from: 0);
    }

    _busy = false;
  }

  Future<void> _advance() async {
    if (_busy) return;
    if (_step < widget.steps.length - 1) {
      await _fadeCtrl.reverse();
      await _goToStep(_step + 1);
    } else {
      await _fadeCtrl.reverse();
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final rect = _targetRect;

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // Scrim with animated cutout hole
            if (rect != null)
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, _) => CustomPaint(
                  size: screenSize,
                  painter: _ScrimPainter(rect: rect, pulse: _pulse.value),
                ),
              )
            else
              const ColoredBox(
                color: Color(0xCC000000),
                child: SizedBox.expand(),
              ),

            // Tap-anywhere-to-advance (below info card in hit-test order)
            GestureDetector(
              onTap: _advance,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),

            // Info card (receives its own taps; rendered above gesture layer)
            if (rect != null)
              _InfoCard(
                step: widget.steps[_step],
                stepIndex: _step,
                totalSteps: widget.steps.length,
                targetRect: rect,
                screenSize: screenSize,
                screenPadding: padding,
                onNext: _advance,
                isLast: _step == widget.steps.length - 1,
              ),

            // Skip button (always on top)
            Positioned(
              top: padding.top + 12,
              right: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    "O'tkazib yuborish",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.targetRect,
    required this.screenSize,
    required this.screenPadding,
    required this.onNext,
    required this.isLast,
  });

  final IntroStep step;
  final int stepIndex;
  final int totalSteps;
  final Rect targetRect;
  final Size screenSize;
  final EdgeInsets screenPadding;
  final VoidCallback onNext;
  final bool isLast;

  static const double _gap = 20;
  static const double _estimatedCardHeight = 210;

  @override
  Widget build(BuildContext context) {
    final spaceBelow =
        screenSize.height - targetRect.bottom - screenPadding.bottom;
    final showBelow = spaceBelow >= _estimatedCardHeight + _gap;

    final card = GestureDetector(
      // Absorb taps so they don't fall through to the advance layer.
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: step.iconBackground ?? AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    step.icon,
                    color: step.iconColor ?? AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A1628),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Step dots
                      Row(
                        children: [
                          for (int i = 0; i < totalSteps; i++) ...[
                            if (i > 0) const SizedBox(width: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: i == stepIndex ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == stepIndex
                                    ? AppColors.primary
                                    : const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              step.description,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  isLast ? 'Boshlash! 🚀' : 'Keyingisi →',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (showBelow) {
      return Positioned(
        top: targetRect.bottom + _gap,
        left: 0,
        right: 0,
        child: card,
      );
    } else {
      return Positioned(
        bottom: screenSize.height - targetRect.top + _gap,
        left: 0,
        right: 0,
        child: card,
      );
    }
  }
}

// ---------------------------------------------------------------------------

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({required this.rect, required this.pulse});

  final Rect rect;
  final double pulse;

  static const double _padding = 6;
  static const double _radius = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = rect.inflate(_padding);
    final scrim = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(_radius)));

    canvas.drawPath(
      Path.combine(PathOperation.difference, scrim, cutout),
      Paint()..color = const Color(0xCC000000),
    );

    // Pulsing glow border around the hole
    final glowAlpha = 0.3 + pulse * 0.35;
    final glowWidth = 1.5 + pulse * 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        hole.inflate(glowWidth / 2),
        Radius.circular(_radius + 2),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: glowAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowWidth,
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.rect != rect || old.pulse != pulse;
}
