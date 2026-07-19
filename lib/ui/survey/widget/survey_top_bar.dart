import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/app/theme/app_radius.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SurveyTopBar extends StatelessWidget {
  const SurveyTopBar({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
  });

  final int stepIndex;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.surface,
          elevation: 0,
          borderRadius: BorderRadius.circular(AppRadius.md),
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textTertiary,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.surveyStepCounter(stepIndex + 1, totalSteps),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
