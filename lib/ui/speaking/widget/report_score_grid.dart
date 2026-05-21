import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

class ReportScoreGrid extends StatelessWidget {
  const ReportScoreGrid({super.key, required this.skills});

  final AssessmentSkills skills;

  @override
  Widget build(BuildContext context) {
    final scores = <_ScoreData>[
      _ScoreData(
        'Speaking',
        skills.speaking,
        _labelFor(skills.speaking),
        const Color(0xFF92400E),
        const Color(0xFFB45309),
      ),
      _ScoreData(
        'Vocabulary',
        skills.vocabulary,
        _labelFor(skills.vocabulary),
        const Color(0xFF1E40AF),
        const Color(0xFF1D4ED8),
      ),
      _ScoreData(
        'Grammar',
        skills.grammar,
        _labelFor(skills.grammar),
        const Color(0xFF065F46),
        const Color(0xFF0F766E),
      ),
      _ScoreData(
        'Listening',
        skills.listening,
        _labelFor(skills.listening),
        const Color(0xFF831843),
        const Color(0xFFBE185D),
      ),
      _ScoreData(
        'Reading',
        skills.reading,
        _labelFor(skills.reading),
        const Color(0xFF4C1D95),
        const Color(0xFF6D28D9),
      ),
      _ScoreData(
        'Writing',
        skills.writing,
        _labelFor(skills.writing),
        const Color(0xFF9A3412),
        const Color(0xFFC2410C),
      ),
    ];

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
            const ReportSectionLabel(text: 'BALL KARTOCHKALARI'),
            const SizedBox(height: 12),
            for (var row = 0; row < scores.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _ScoreTile(data: scores[row])),
                  const SizedBox(width: 8),
                  Expanded(child: _ScoreTile(data: scores[row + 1])),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _labelFor(int score) {
    if (score >= 75) return 'Kuchli';
    if (score >= 65) return 'Yaxshi';
    if (score >= 55) return "O'rta";
    if (score >= 45) return 'Kuchayish kerak';
    return 'Zaif tomon';
  }
}

class _ScoreData {
  const _ScoreData(
    this.label,
    this.score,
    this.note,
    this.scoreColor,
    this.noteColor,
  );

  final String label;
  final int score;
  final String note;
  final Color scoreColor;
  final Color noteColor;
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.data});

  final _ScoreData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  data.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${data.score}',
            style: TextStyle(
              color: data.scoreColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.note,
            style: TextStyle(
              color: data.noteColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              color: const Color(0xFFE8E5DE),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: data.score / 100,
                child: Container(color: data.noteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
