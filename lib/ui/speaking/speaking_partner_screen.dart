import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/speaking/presentation/speaking_controller.dart';
import 'package:ai_teacher/ui/speaking/limit_reached_sheet.dart';
import 'package:ai_teacher/ui/speaking/widget/partner_avatar.dart';
import 'package:ai_teacher/ui/speaking/widget/partner_controls.dart';
import 'package:ai_teacher/ui/speaking/widget/partner_dots.dart';
import 'package:ai_teacher/ui/speaking/widget/partner_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SpeakingPartnerScreen extends ConsumerStatefulWidget {
  const SpeakingPartnerScreen({super.key});

  @override
  ConsumerState<SpeakingPartnerScreen> createState() =>
      _SpeakingPartnerScreenState();
}

class _SpeakingPartnerScreenState extends ConsumerState<SpeakingPartnerScreen> {
  String? _lastErrorShown;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onBack() {
    ref.read(speakingControllerProvider.notifier).endConversation();
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.main.name);
    }
  }

  Future<void> _onMicTap() async {
    final controller = ref.read(speakingControllerProvider.notifier);
    final state = ref.read(speakingControllerProvider);
    if (state.phase == SpeakingPhase.recording) {
      await controller.stopAndSend();
    } else if (!state.isBusy) {
      await controller.startRecording();
    }
  }

  Future<void> _onAnalyzeTap() async {
    final state = ref.read(speakingControllerProvider);
    if (state.analyzingReport) return;
    if (!state.readyForAnalyze || state.conversationId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Hisobot uchun yana bir oz gaplashing")),
        );
      return;
    }
    final assessment = await ref
        .read(speakingControllerProvider.notifier)
        .requestReport();
    if (!mounted || assessment == null) return;
    context.pushNamed(AppRoute.speakingReport.name, extra: assessment);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SpeakingState>(speakingControllerProvider, (prev, next) {
      final wasLimited = prev?.limitReached ?? false;
      if (!wasLimited && next.limitReached) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await LimitReachedSheet.show(context);
          if (!mounted) return;
          ref.read(speakingControllerProvider.notifier).dismissLimit();
          ref.read(speakingControllerProvider.notifier).resetError();
        });
      }
    });

    final state = ref.watch(speakingControllerProvider);

    if (state.phase == SpeakingPhase.error &&
        !state.limitReached &&
        state.error != null &&
        state.error != _lastErrorShown) {
      _lastErrorShown = state.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.error!)));
        ref.read(speakingControllerProvider.notifier).resetError();
      });
    }

    final timerLabel = switch (state.phase) {
      SpeakingPhase.recording => _formatDuration(state.elapsed),
      _ => '00:00',
    };

    final statusText = _statusText(state);
    const fallback =
        "Hi! I'm ready to help you practice English. "
        "Just tap the button and let's talk!";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFF5F7FF),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: SafeArea(
          child: Column(
            children: [
              PartnerTopBar(timerLabel: timerLabel, onBack: _onBack),
              const SizedBox(height: 24),
              const PartnerAvatar(),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                  child: _ConversationCard(
                    turns: state.turns,
                    fallback: fallback,
                    statusText: statusText,
                  ),
                ),
              ),
              if (state.phase == SpeakingPhase.recording)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WaveVisualizer(amplitudes: state.amplitudes),
                )
              else if (state.phase == SpeakingPhase.processing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _TypingDots(),
                ),
              if (state.readyForAnalyze)
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 8),
                  child: _AnalyzeHint(loading: state.analyzingReport),
                ),
              const PartnerDots(),
              PartnerControls(
                onHistory: () =>
                    context.pushNamed(AppRoute.speakingHistory.name),
                onMic: state.isBusy ? () {} : _onMicTap,
                onMagic: state.analyzingReport ? () {} : _onAnalyzeTap,
                recording: state.phase == SpeakingPhase.recording,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _statusText(SpeakingState state) {
    switch (state.phase) {
      case SpeakingPhase.recording:
        return "🎙️ I'm listening — go ahead!";
      case SpeakingPhase.processing:
        return '💭 Bir lahza... javob tayyorlanmoqda.';
      default:
        return null;
    }
  }
}

class _ConversationCard extends StatefulWidget {
  const _ConversationCard({
    required this.turns,
    required this.fallback,
    this.statusText,
  });

  final List<SpeakingTurn> turns;
  final String fallback;
  final String? statusText;

  @override
  State<_ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<_ConversationCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _ConversationCard old) {
    super.didUpdateWidget(old);
    if (old.turns.length != widget.turns.length ||
        old.statusText != widget.statusText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B4B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: widget.turns.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  widget.statusText ?? widget.fallback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0D1B4B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final turn in widget.turns) _TurnBubble(turn: turn),
                  if (widget.statusText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.statusText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7A9F),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TurnBubble extends StatelessWidget {
  const _TurnBubble({required this.turn});

  final SpeakingTurn turn;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == 'user';
    final maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFE0E7FF) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
            ),
            child: Text(
              turn.transcript,
              style: TextStyle(
                color: isUser
                    ? const Color(0xFF1E1B4B)
                    : const Color(0xFF0D1B4B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              _Dot(progress: _phaseFor(i)),
              if (i < 2) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }

  /// Each dot is offset by 1/3 of the cycle, so they bounce sequentially.
  double _phaseFor(int index) {
    final t = (_controller.value + index * (1 / 3)) % 1.0;
    // Triangle wave: 0 → 1 → 0
    return t < 0.5 ? t * 2 : (1 - t) * 2;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.progress});

  /// 0..1, where 1 is the peak of the bounce.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scale = 0.6 + 0.6 * progress; // 0.6 → 1.2
    final opacity = 0.35 + 0.65 * progress; // 0.35 → 1.0
    return Transform.translate(
      offset: Offset(0, -4 * progress),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF1340C4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar-style mic visualizer: latest amplitudes scroll in from the right.
class _WaveVisualizer extends StatelessWidget {
  const _WaveVisualizer({required this.amplitudes});

  final List<double> amplitudes;

  static const int _barCount = 32;
  static const double _height = 48;
  static const double _minBar = 4;

  @override
  Widget build(BuildContext context) {
    final padded = _padded();
    return SizedBox(
      height: _height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < padded.length; i++) ...[
            _Bar(level: padded[i]),
            if (i < padded.length - 1) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }

  List<double> _padded() {
    if (amplitudes.length >= _barCount) {
      return amplitudes.sublist(amplitudes.length - _barCount);
    }
    return [
      ...List<double>.filled(_barCount - amplitudes.length, 0),
      ...amplitudes,
    ];
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.level});

  /// 0..1
  final double level;

  @override
  Widget build(BuildContext context) {
    final h =
        _WaveVisualizer._minBar +
        (_WaveVisualizer._height - _WaveVisualizer._minBar) * level;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      width: 4,
      height: h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1340C4), Color(0xFF0D2B8E)],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Hint shown above the analyze button when the server says there's enough
/// speech to generate a report.
class _AnalyzeHint extends StatelessWidget {
  const _AnalyzeHint({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 96;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth.clamp(160, 360)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D1B4B).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1340C4),
                ),
              )
            else
              const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFF1340C4),
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                loading
                    ? 'Hisobot tayyorlanmoqda...'
                    : "Hisobot uchun tayyor — ✨ tugmasini bosing",
                style: const TextStyle(
                  color: Color(0xFF1340C4),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
