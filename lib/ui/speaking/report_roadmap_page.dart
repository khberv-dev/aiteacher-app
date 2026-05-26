import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/speaking/widget/report_coach_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_locked_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_monthly_plan_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_next_session_cta.dart';
import 'package:ai_teacher/ui/speaking/widget/report_roadmap_levels_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportRoadmapPage extends StatelessWidget {
  const ReportRoadmapPage({super.key, required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final tips = assessment.coachTips;
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
        ReportRoadmapLevelsCard(
          currentLevel: assessment.cefrLevel,
          targetLevel: assessment.roadmap.targetLevel,
          activeVocabSize: assessment.vocabularyDetail.activeSizeEstimate,
          estimatedDuration: assessment.roadmap.estimatedDuration,
        ),
        gate(
          ReportMonthlyPlanCard(
            focusAreas: assessment.roadmap.focusAreas,
            targetLevel: assessment.roadmap.targetLevel,
            currentLevel: assessment.cefrLevel,
          ),
        ),
        gate(
          ReportCoachCard(
            tips: tips,
            subtitle: '${tips.length} ta ustuvor tavsiya',
          ),
        ),
        gate(
          ReportNextSessionCta(
            onStart: () => context.goNamed(AppRoute.speaking.name),
          ),
        ),
      ],
    );
  }
}
