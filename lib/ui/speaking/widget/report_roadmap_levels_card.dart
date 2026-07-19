import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

enum _StepState { done, current, next, future }

class _RoadmapStep {
  const _RoadmapStep({
    required this.level,
    required this.description,
    required this.tagText,
    required this.state,
    this.tagBackground,
    this.tagColor,
  });

  final String level;
  final String description;
  final String tagText;
  final _StepState state;
  final Color? tagBackground;
  final Color? tagColor;
}

class ReportRoadmapLevelsCard extends StatelessWidget {
  const ReportRoadmapLevelsCard({
    super.key,
    required this.currentLevel,
    required this.targetLevel,
    required this.activeVocabSize,
    required this.estimatedDuration,
  });

  final String currentLevel;
  final String targetLevel;
  final int activeVocabSize;
  final String estimatedDuration;

  static const _allLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const _titles = {
    'A1': 'A1 — Beginner',
    'A2': 'A2 — Elementary',
    'B1': 'B1 — Intermediate',
    'B2': 'B2 — Upper Intermediate',
    'C1': 'C1 — Advanced',
    'C2': 'C2 — Proficient',
  };

  Map<String, String> _descriptions(AppLocalizations l10n) => {
    'A1': l10n.speakingReportRoadmapDescA1,
    'A2': l10n.speakingReportRoadmapDescA2,
    'B1': l10n.speakingReportRoadmapDescB1,
    'B2': l10n.speakingReportRoadmapDescB2,
    'C1': l10n.speakingReportRoadmapDescC1,
    'C2': l10n.speakingReportRoadmapDescC2,
  };

  String _formatThousands(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }

  List<_RoadmapStep> _buildSteps(AppLocalizations l10n) {
    final descriptions = _descriptions(l10n);
    final currentIndex = _allLevels.indexOf(currentLevel.toUpperCase());
    final targetIndex = _allLevels.indexOf(targetLevel.toUpperCase());
    final steps = <_RoadmapStep>[];
    final maxIndex = (targetIndex >= 0 ? targetIndex : currentIndex) + 1;
    for (var i = 0; i < _allLevels.length && i <= maxIndex; i++) {
      final level = _allLevels[i];
      final _StepState state;
      if (currentIndex < 0) {
        state = i == 0 ? _StepState.current : _StepState.future;
      } else if (i < currentIndex) {
        state = _StepState.done;
      } else if (i == currentIndex) {
        state = _StepState.current;
      } else if (i == targetIndex) {
        state = _StepState.next;
      } else {
        state = _StepState.future;
      }
      var description = descriptions[level] ?? '';
      if (state == _StepState.current && level == currentLevel) {
        description = l10n.speakingReportRoadmapCurrentSuffix(
          description,
          _formatThousands(activeVocabSize),
        );
      }
      final (tagText, tagBg, tagColor) = switch (state) {
        _StepState.done => (
          l10n.speakingReportRoadmapTagDone,
          const Color(0x1A0D9488),
          const Color(0xFF065F46),
        ),
        _StepState.current => (
          l10n.speakingReportRoadmapTagCurrent,
          const Color(0x1AF5B700),
          const Color(0xFF92400E),
        ),
        _StepState.next => (
          l10n.speakingReportRoadmapTagNext,
          const Color(0x143B82F6),
          const Color(0xFF1E40AF),
        ),
        _StepState.future => ('', null, null),
      };
      steps.add(
        _RoadmapStep(
          level: _titles[level] ?? level,
          description: description,
          tagText: tagText,
          state: state,
          tagBackground: tagBg,
          tagColor: tagColor,
        ),
      );
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _buildSteps(l10n);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.speakingReportRoadmapTitle(targetLevel),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              estimatedDuration.isEmpty
                  ? l10n.speakingReportRoadmapDefaultDuration
                  : estimatedDuration,
              style: const TextStyle(
                color: Color(0xFF6B6860),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final step in steps) _StepRow(step: step),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _RoadmapStep step;

  @override
  Widget build(BuildContext context) {
    final faded = step.state == _StepState.future;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Dot(state: step.state),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.level,
                    style: TextStyle(
                      color: faded
                          ? const Color(0xFF6B6860)
                          : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: Color(0xFF6B6860),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (step.tagText.isNotEmpty &&
                      step.tagBackground != null &&
                      step.tagColor != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: step.tagBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.tagText,
                        style: TextStyle(
                          color: step.tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.done:
        return _circle(
          background: const Color(0xFF0D9488),
          border: Border.all(color: const Color(0xFF0D9488)),
          shadow: const Color(0x1F0D9488),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        );
      case _StepState.current:
        return _circle(
          background: const Color(0xFFF5B700),
          shadow: const Color(0x26F5B700),
          child: const Text('📍', style: TextStyle(fontSize: 16)),
        );
      case _StepState.next:
        return _circle(
          background: Colors.white,
          border: Border.all(color: const Color(0xFFDDD9D1), width: 2),
          child: const Text(
            '→',
            style: TextStyle(
              color: Color(0xFF6B6860),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _StepState.future:
        return _circle(
          background: const Color(0xFFF5F3EE),
          border: Border.all(color: const Color(0xFFDDD9D1), width: 2),
          child: const Text(
            '○',
            style: TextStyle(
              color: Color(0xFFC0BCB5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
    }
  }

  Widget _circle({
    required Color background,
    required Widget child,
    BoxBorder? border,
    Color? shadow,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
        boxShadow: shadow != null
            ? [BoxShadow(color: shadow, blurRadius: 0, spreadRadius: 3)]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
