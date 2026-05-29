import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/vocabulary/presentation/vocabulary_training_controller.dart';
import 'package:flutter/material.dart';

/// Big circular mic button — press and hold to record, release to send.
///
/// Press handling uses `Listener` (not `GestureDetector`) so the recorder
/// starts on the very first pointer-down event without waiting for the
/// gesture arena to disambiguate from competing recognisers.
class HoldMicButton extends StatelessWidget {
  const HoldMicButton({
    super.key,
    required this.phase,
    required this.elapsed,
    required this.onPressStart,
    required this.onPressEnd,
    required this.onPressCancel,
  });

  final SpeakingCheckPhase phase;
  final Duration elapsed;

  /// Pointer went down on the button — start recording.
  final VoidCallback onPressStart;

  /// Pointer lifted — stop and send audio to the server.
  final VoidCallback onPressEnd;

  /// Gesture was interrupted by the platform — discard recording.
  final VoidCallback onPressCancel;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = phase == SpeakingCheckPhase.recording;
    final isChecking = phase == SpeakingCheckPhase.checking;
    final enabled = phase == SpeakingCheckPhase.idle || isRecording;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: enabled && !isRecording ? (_) => onPressStart() : null,
          onPointerUp: isRecording ? (_) => onPressEnd() : null,
          onPointerCancel: isRecording ? (_) => onPressCancel() : null,
          child: _MicCircle(phase: phase),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: switch (phase) {
            SpeakingCheckPhase.recording => Text(
              _fmt(elapsed),
              key: ValueKey('timer-${elapsed.inSeconds}'),
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            _ => const SizedBox.shrink(key: ValueKey('no-timer')),
          },
        ),
        const SizedBox(height: 6),
        Text(
          switch (phase) {
            SpeakingCheckPhase.idle => "Tugmani bosib ushlab gapiring",
            SpeakingCheckPhase.recording => "Qo'yib yuboring — yuboriladi",
            SpeakingCheckPhase.checking => "Baholanmoqda…",
            SpeakingCheckPhase.showingResult => '',
          },
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isRecording
                ? const Color(0xFF7F1D1D)
                : isChecking
                ? const Color(0xFF475569)
                : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MicCircle extends StatefulWidget {
  const _MicCircle({required this.phase});

  final SpeakingCheckPhase phase;

  @override
  State<_MicCircle> createState() => _MicCircleState();
}

class _MicCircleState extends State<_MicCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _MicCircle old) {
    super.didUpdateWidget(old);
    if (widget.phase == SpeakingCheckPhase.recording) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = widget.phase == SpeakingCheckPhase.recording;
    final isChecking = widget.phase == SpeakingCheckPhase.checking;

    final base = isRecording
        ? const Color(0xFFDC2626)
        : isChecking
        ? const Color(0xFF94A3B8)
        : AppColors.primary;
    final darker = isRecording
        ? const Color(0xFFB91C1C)
        : isChecking
        ? const Color(0xFF64748B)
        : AppColors.primaryDark;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        final pulse = isRecording ? _pulse.value : 0.0;
        final ringSize = 132.0 + pulse * 22;
        final ringOpacity = isRecording ? (0.35 - pulse * 0.3) : 0.0;
        return SizedBox(
          width: 156,
          height: 156,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing halo while recording.
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFFDC2626,
                  ).withValues(alpha: ringOpacity.clamp(0.0, 1.0)),
                ),
              ),
              Container(
                width: 116,
                height: 116,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [base, darker],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: base.withValues(alpha: 0.45),
                      blurRadius: isRecording ? 28 : 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: isChecking
                    ? const SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
