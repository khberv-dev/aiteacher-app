import 'dart:math' as math;

import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ReportHeroCard extends StatelessWidget {
  const ReportHeroCard({super.key, required this.assessment});

  final Assessment assessment;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();
    final months = [
      l10n.speakingReportHeroCardMonthJanuary,
      l10n.speakingReportHeroCardMonthFebruary,
      l10n.speakingReportHeroCardMonthMarch,
      l10n.speakingReportHeroCardMonthApril,
      l10n.speakingReportHeroCardMonthMay,
      l10n.speakingReportHeroCardMonthJune,
      l10n.speakingReportHeroCardMonthJuly,
      l10n.speakingReportHeroCardMonthAugust,
      l10n.speakingReportHeroCardMonthSeptember,
      l10n.speakingReportHeroCardMonthOctober,
      l10n.speakingReportHeroCardMonthNovember,
      l10n.speakingReportHeroCardMonthDecember,
    ];
    final dateLabel = l10n.speakingReportHeroCardDateLabel(
      today.day,
      months[today.month - 1],
      today.year,
      _formatDuration(assessment.durationSeconds),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroTopRow(dateLabel: dateLabel),
            const SizedBox(height: 16),
            _HeroMain(assessment: assessment),
            const SizedBox(height: 16),
            _HeroStats(assessment: assessment),
            const SizedBox(height: 16),
            _HeroProgressBar(
              cefrLevel: assessment.cefrLevel,
              targetLevel: assessment.roadmap.targetLevel,
              score: assessment.overallScore,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTopRow extends StatelessWidget {
  const _HeroTopRow({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF5B700).withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: const Color(0xFFF5B700).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            l10n.speakingReportHeroCardAnalysisCompleteLabel,
            style: const TextStyle(
              color: Color(0xFFF5B700),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Flexible(
          child: Text(
            dateLabel,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0x4DFFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroMain extends StatelessWidget {
  const _HeroMain({required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = (assessment.overallScore / 100).clamp(0.0, 1.0);
    final levelLabel =
        '${assessment.cefrLevel} — ${_levelTitle(l10n, assessment.cefrLevel)}';
    final remaining = (100 - assessment.overallScore).clamp(0, 100);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ScoreRing(score: assessment.overallScore, fraction: progress),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                levelLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _levelSubtitle(l10n, assessment.cefrLevel),
                style: const TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.speakingReportHeroCardTargetRemainingLabel(
                  assessment.roadmap.targetLevel,
                  remaining,
                ),
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _levelTitle(AppLocalizations l10n, String level) {
    return switch (level.toUpperCase()) {
      'A1' => l10n.speakingReportHeroCardLevelTitleBeginner,
      'A2' => l10n.speakingReportHeroCardLevelTitleElementary,
      'B1' => l10n.speakingReportHeroCardLevelTitleIntermediate,
      'B2' => l10n.speakingReportHeroCardLevelTitleUpperIntermediate,
      'C1' => l10n.speakingReportHeroCardLevelTitleAdvanced,
      'C2' => l10n.speakingReportHeroCardLevelTitleProficient,
      _ => l10n.speakingReportHeroCardLevelTitleDefault,
    };
  }

  String _levelSubtitle(AppLocalizations l10n, String level) {
    return switch (level.toUpperCase()) {
      'B1' => l10n.speakingReportHeroCardLevelSubtitleThreshold,
      'B2' => l10n.speakingReportHeroCardLevelSubtitleVantage,
      'A2' => l10n.speakingReportHeroCardLevelSubtitleWaystage,
      'A1' => l10n.speakingReportHeroCardLevelSubtitleBreakthrough,
      'C1' => l10n.speakingReportHeroCardLevelSubtitleEffectiveOperational,
      'C2' => l10n.speakingReportHeroCardLevelSubtitleMastery,
      _ => l10n.speakingReportHeroCardLevelSubtitleDefault,
    };
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.fraction});

  final int score;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(76, 76),
            painter: _RingPainter(fraction: fraction),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFFF5B700),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.1);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFF5B700);
    canvas.drawCircle(center, radius, track);
    final start = -math.pi / 2;
    final sweep = fraction * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.assessment});

  final Assessment assessment;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _StatItem(
        value: _formatDuration(assessment.durationSeconds),
        label: l10n.speakingReportHeroCardStatConversationLabel,
      ),
      _StatItem(
        value: '${assessment.skills.fluency}',
        label: l10n.speakingReportHeroCardStatFluencyLabel,
      ),
      _StatItem(
        value: '${assessment.fluencyDetail.speechRateWpm}',
        label: l10n.speakingReportHeroCardStatSpeedLabel,
      ),
      _StatItem(
        value: '${assessment.skills.pronunciation}%',
        label: l10n.speakingReportHeroCardStatPronunciationLabel,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0x4DFFFFFF),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroProgressBar extends StatelessWidget {
  const _HeroProgressBar({
    required this.cefrLevel,
    required this.targetLevel,
    required this.score,
  });

  final String cefrLevel;
  final String targetLevel;
  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fraction = (score / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.speakingReportHeroCardProgressLabel(cefrLevel, targetLevel),
              style: const TextStyle(
                color: Color(0x4DFFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.speakingReportHeroCardScoreOutOfLabel(score),
              style: const TextStyle(
                color: Color(0xFFF5B700),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 5,
            color: Colors.white.withValues(alpha: 0.07),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFF5B700), Color(0xFFFCD34D)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
