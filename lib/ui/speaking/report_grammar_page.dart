import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/speaking/widget/report_coach_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_grammar_errors_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_locked_card.dart';
import 'package:ai_teacher/ui/speaking/widget/report_pronunciation_card.dart';
import 'package:flutter/material.dart';

class ReportGrammarPage extends StatelessWidget {
  const ReportGrammarPage({super.key, required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tips = assessment.coachTips.length > 2
        ? assessment.coachTips.skip(2).take(2).toList(growable: false)
        : assessment.coachTips.take(2).toList(growable: false);
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
        ReportGrammarErrorsCard(detail: assessment.grammarDetail),
        gate(
          ReportPronunciationCard(
            detail: assessment.pronunciationDetail,
            score: assessment.skills.pronunciation,
          ),
        ),
        gate(
          ReportCoachCard(
            tips: tips,
            subtitle: l10n.speakingScreenGrammarCoachSubtitle,
          ),
        ),
      ],
    );
  }
}
