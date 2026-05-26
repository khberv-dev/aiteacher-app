import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_feedback_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_fluency_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_locked_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_radar_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_response_chart.dart';
import 'package:ai_teacher/ui/speaking/widget/report_score_grid.dart';
import 'package:flutter/material.dart';

class ReportOverviewPage extends StatelessWidget {
  const ReportOverviewPage({super.key, required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final locked = !assessment.isFullReportAvailable;
    Widget gate(Widget child) => locked
        ? ReportLockedCard(
            conversationId: assessment.conversationId,
            child: child,
          )
        : child;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // The feedback card stays visible even on the paywalled report.
        ReportFeedbackCard(feedback: assessment.feedback),
        gate(ReportRadarCard(skills: assessment.skills)),
        gate(ReportScoreGrid(skills: assessment.skills)),
        gate(
          ReportFluencyCard(
            fluency: assessment.fluencyDetail,
            overall: assessment.skills.fluency,
          ),
        ),
        gate(const ReportResponseChart()),
      ],
    );
  }
}
