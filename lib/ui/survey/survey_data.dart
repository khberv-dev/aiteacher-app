import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SurveyOption {
  const SurveyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBackground,
  });

  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBackground;
}

class SurveyStep {
  const SurveyStep({
    required this.titleLines,
    required this.subtitle,
    required this.options,
    this.defaultOptionId,
  });

  final List<String> titleLines;
  final String subtitle;
  final List<SurveyOption> options;
  final String? defaultOptionId;
}

/// Survey selections forwarded from [SurveyScreen] through register/OTP
/// into the sign-up request body. All fields are optional; the API accepts
/// any subset.
class SurveyAnswers {
  const SurveyAnswers({this.goal, this.level, this.dailyTime});

  final String? goal;
  final String? level;
  final String? dailyTime;
}

List<SurveyStep> surveySteps(AppLocalizations l10n) => [
  SurveyStep(
    titleLines: [l10n.surveyGoalTitleLine1, l10n.surveyGoalTitleLine2],
    subtitle: l10n.surveyGoalSubtitle,
    options: [
      SurveyOption(
        id: 'work',
        title: l10n.surveyGoalWorkTitle,
        subtitle: l10n.surveyGoalWorkSubtitle,
        badgeText: '🏢',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'travel',
        title: l10n.surveyGoalTravelTitle,
        subtitle: l10n.surveyGoalTravelSubtitle,
        badgeText: '✈️',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFF0FDF4),
      ),
      SurveyOption(
        id: 'study',
        title: l10n.surveyGoalStudyTitle,
        subtitle: l10n.surveyGoalStudySubtitle,
        badgeText: '🎓',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFFEF9C3),
      ),
      SurveyOption(
        id: 'personal',
        title: l10n.surveyGoalPersonalTitle,
        subtitle: l10n.surveyGoalPersonalSubtitle,
        badgeText: '💬',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFFDF4FF),
      ),
    ],
  ),
  SurveyStep(
    titleLines: [l10n.surveyLevelTitleLine1, l10n.surveyLevelTitleLine2],
    subtitle: l10n.surveyLevelSubtitle,
    options: [
      SurveyOption(
        id: 'a0',
        title: l10n.surveyLevelA0Title,
        subtitle: l10n.surveyLevelA0Subtitle,
        badgeText: 'A0',
        badgeColor: const Color(0xFFA21CAF),
        badgeBackground: const Color(0xFFFDF4FF),
      ),
      SurveyOption(
        id: 'a1',
        title: l10n.surveyLevelA1Title,
        subtitle: l10n.surveyLevelA1Subtitle,
        badgeText: 'A1',
        badgeColor: const Color(0xFF64748B),
        badgeBackground: const Color(0xFFF1F5F9),
      ),
      SurveyOption(
        id: 'b1',
        title: l10n.surveyLevelB1Title,
        subtitle: l10n.surveyLevelB1Subtitle,
        badgeText: 'B1',
        badgeColor: const Color(0xFF2563EB),
        badgeBackground: const Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'b2',
        title: l10n.surveyLevelB2Title,
        subtitle: l10n.surveyLevelB2Subtitle,
        badgeText: 'B2',
        badgeColor: const Color(0xFF0D9488),
        badgeBackground: const Color(0xFFF0FDFA),
      ),
      SurveyOption(
        id: 'c1',
        title: l10n.surveyLevelC1Title,
        subtitle: l10n.surveyLevelC1Subtitle,
        badgeText: 'C1',
        badgeColor: const Color(0xFFD97706),
        badgeBackground: const Color(0xFFFEF9C3),
      ),
    ],
  ),
  SurveyStep(
    titleLines: [l10n.surveyTimeTitleLine1, l10n.surveyTimeTitleLine2],
    subtitle: l10n.surveyTimeSubtitle,
    options: [
      SurveyOption(
        id: 'short',
        title: l10n.surveyTimeShortTitle,
        subtitle: l10n.surveyTimeShortSubtitle,
        badgeText: '⚡',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFF0FDF4),
      ),
      SurveyOption(
        id: 'mid',
        title: l10n.surveyTimeMidTitle,
        subtitle: l10n.surveyTimeMidSubtitle,
        badgeText: '🎯',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'long',
        title: l10n.surveyTimeLongTitle,
        subtitle: l10n.surveyTimeLongSubtitle,
        badgeText: '🔥',
        badgeColor: const Color(0xFF000000),
        badgeBackground: const Color(0xFFFEF9C3),
      ),
    ],
  ),
];
