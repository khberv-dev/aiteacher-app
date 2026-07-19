import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/battle/data/battle_dtos.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BattleGameOverView extends StatelessWidget {
  const BattleGameOverView({
    super.key,
    required this.state,
    required this.onPlayAgain,
    required this.onExit,
  });

  final BattleState state;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scoreboard = state.scoreboard;
    final myEntry =
        scoreboard.where((e) => e.userId == state.myUserId).firstOrNull ??
        scoreboard.lastOrNull;
    final myRank = myEntry?.rank ?? scoreboard.length;
    final isWin = myRank == 1;

    final emoji = isWin ? '🏆' : '💔';
    final headline = isWin ? l10n.battleVictory : l10n.battleDefeat;
    final headlineColor = isWin
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(emoji, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                Text(
                  headline,
                  style: TextStyle(
                    color: headlineColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.battleRankScore(myRank, myEntry?.score ?? 0),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _Scoreboard(entries: scoreboard, myUserId: state.myUserId),
                if (myEntry != null && myEntry.answers.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.battleMyAnswersLabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...myEntry.answers.map((a) => _AnswerRow(answer: a)),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: onExit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.battleExit,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: onPlayAgain,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.battlePlayAgain,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.entries, required this.myUserId});

  final List<ScoreboardEntry> entries;
  final String? myUserId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final isMe = e.userId == myUserId;
          final isLast = i == entries.length - 1;

          const rankColors = [
            Color(0xFFF59E0B),
            Color(0xFF94A3B8),
            Color(0xFFCD7F32),
            Color(0xFF64748B),
          ];
          final rankColor = e.rank <= 4
              ? rankColors[e.rank - 1]
              : const Color(0xFF64748B);

          return Container(
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(18) : Radius.zero,
                bottom: isLast ? const Radius.circular(18) : Radius.zero,
              ),
              border: isMe
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${e.rank}',
                          style: TextStyle(
                            color: rankColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isMe ? l10n.battleYou : e.firstName,
                          style: TextStyle(
                            color: isMe
                                ? AppColors.primary
                                : const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${e.score}',
                        style: TextStyle(
                          color: isMe
                              ? AppColors.primary
                              : const Color(0xFF64748B),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.answer});

  final BattleRoundAnswer answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: answer.correct
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              answer.correct ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: answer.correct
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              answer.word,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (answer.delayMs != null)
            Text(
              '${(answer.delayMs! / 1000).toStringAsFixed(1)}s',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
