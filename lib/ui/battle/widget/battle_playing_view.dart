import 'dart:math' as math;

import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/battle/data/battle_dtos.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BattlePlayingView extends StatelessWidget {
  const BattlePlayingView({
    super.key,
    required this.state,
    required this.onAnswer,
  });

  final BattleState state;
  final void Function(int optionIndex) onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = state.word ?? '';
    final options = state.options;
    final answered = state.selectedOptionIndex != null;
    final currentRound = state.currentRound ?? 1;
    final totalRounds = state.totalRounds ?? 10;

    // Reveal correct/wrong only after round_end so all players see the result
    // at the same moment. While waiting, the selected button shows a blue border.
    final correctOptionIndex = state.roundEnd?.correctOptionIndex;

    // Build a map: optionIndex → list of other players who chose it
    final choosersByOption = <int, List<String>>{};
    for (final p in state.roundPlayerAnswers) {
      if (p.userId == state.myUserId) continue;
      choosersByOption.putIfAbsent(p.optionIndex, () => []).add(p.firstName);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          _ScoreBar(players: state.lobbyPlayers, myUserId: state.myUserId),
          const SizedBox(height: 16),
          _ProgressBar(
            current: currentRound,
            total: totalRounds,
            remainingSeconds: state.roundTick,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.battlePlayingTranslatePrompt,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: options.length,
            itemBuilder: (_, i) => _OptionButton(
              label: options[i],
              index: i,
              selectedIndex: state.selectedOptionIndex,
              correctOptionIndex: correctOptionIndex,
              choosers: choosersByOption[i] ?? const [],
              onTap: answered ? null : () => onAnswer(i),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.players, required this.myUserId});

  final List<LobbyPlayer> players;
  final String? myUserId;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: players.map((p) {
          final isMe = p.userId == myUserId;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? l10n.battleYou : p.firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMe ? AppColors.primary : const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.score}',
                  style: TextStyle(
                    color: isMe ? AppColors.primary : const Color(0xFF64748B),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.current,
    required this.total,
    this.remainingSeconds,
  });

  final int current;
  final int total;
  final int? remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tick = remainingSeconds;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.battleQuestionProgress(current, total),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: current / total,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        if (tick != null) ...[
          const SizedBox(width: 12),
          _RoundTimerCircle(remaining: tick, total: 10),
        ],
      ],
    );
  }
}

class _RoundTimerCircle extends StatelessWidget {
  const _RoundTimerCircle({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isUrgent = remaining <= 3;
    final activeColor = isUrgent ? const Color(0xFFDC2626) : AppColors.primary;

    return TweenAnimationBuilder<double>(
      key: ValueKey(remaining),
      tween: Tween(
        begin: (remaining + 1) / total.toDouble(),
        end: remaining / total.toDouble(),
      ),
      duration: const Duration(milliseconds: 900),
      builder: (_, progress, child) {
        return SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(
            painter: _CircleTimerPainter(
              progress: progress,
              activeColor: activeColor,
            ),
            child: Center(
              child: Text(
                '$remaining',
                style: TextStyle(
                  color: isUrgent
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleTimerPainter extends CustomPainter {
  const _CircleTimerPainter({
    required this.progress,
    required this.activeColor,
  });

  final double progress;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleTimerPainter old) =>
      old.progress != progress || old.activeColor != activeColor;
}

enum _OptionState { normal, selected, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctOptionIndex,
    required this.choosers,
    required this.onTap,
  });

  final String label;
  final int index;
  final int? selectedIndex;
  final int? correctOptionIndex;

  /// First names of other players who chose this option.
  final List<String> choosers;
  final VoidCallback? onTap;

  _OptionState get _state {
    if (correctOptionIndex != null) {
      if (index == correctOptionIndex) return _OptionState.correct;
      if (index == selectedIndex) return _OptionState.wrong;
      return _OptionState.dimmed;
    }
    // Mark the user's choice immediately on tap (before server response).
    if (selectedIndex == index) return _OptionState.selected;
    if (selectedIndex != null) return _OptionState.dimmed;
    return _OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final st = _state;
    final Color bg;
    final Color border;
    final Color textColor;

    switch (st) {
      case _OptionState.correct:
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFF16A34A);
        textColor = const Color(0xFF15803D);
      case _OptionState.wrong:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFDC2626);
        textColor = const Color(0xFFB91C1C);
      case _OptionState.selected:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFF3B82F6);
        textColor = const Color(0xFF1D4ED8);
      case _OptionState.dimmed:
        bg = const Color(0xFFF8FAFC);
        border = const Color(0xFFE2E8F0);
        textColor = const Color(0xFFCBD5E1);
      case _OptionState.normal:
        bg = Colors.white;
        border = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF334155);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
          width: st == _OptionState.selected ? 2.5 : 1.5,
        ),
        boxShadow: st == _OptionState.normal
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Centered label — shifts down slightly when choosers are shown
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  choosers.isNotEmpty ? 20 : 8,
                  12,
                  8,
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              // Other players' choice indicators — top-left row
              if (choosers.isNotEmpty)
                Positioned(
                  top: 5,
                  left: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: choosers
                        .take(3)
                        .map((name) => _PlayerDot(name: name))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerDot extends StatelessWidget {
  const _PlayerDot({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Color(0xFF334155),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
