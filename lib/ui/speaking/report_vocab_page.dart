import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_coach_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_locked_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_priority_words.dart';
import 'package:ai_teacher/ui/speaking/widget/report_vocab_chart.dart';
import 'package:ai_teacher/ui/speaking/widget/report_vocab_hero.dart';
import 'package:flutter/material.dart';

class ReportVocabPage extends StatelessWidget {
  const ReportVocabPage({super.key, required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final tips = assessment.coachTips.take(2).toList(growable: false);
    final locked = !assessment.isFullReportAvailable;
    Widget gate(Widget child) =>
        locked ? ReportLockedCard(child: child) : child;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ReportVocabHero(detail: assessment.vocabularyDetail),
        gate(
          ReportPriorityWords(words: assessment.vocabularyDetail.priorityWords),
        ),
        gate(ReportVocabChart(detail: assessment.vocabularyDetail)),
        gate(ReportCoachCard(tips: tips, subtitle: "Vocabulary bo'yicha")),
      ],
    );
  }
}
