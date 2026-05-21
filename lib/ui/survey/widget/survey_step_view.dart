import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/ui/survey/survey_data.dart';
import 'package:ai_teacher/ui/survey/widget/survey_option_card.dart';
import 'package:ai_teacher/ui/survey/widget/survey_top_bar.dart';
import 'package:flutter/material.dart';

class SurveyStepView extends StatelessWidget {
  const SurveyStepView({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.selectedOptionId,
    required this.onSelect,
    required this.onBack,
  });

  final SurveyStep step;
  final int stepIndex;
  final int totalSteps;
  final String? selectedOptionId;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SurveyTopBar(
                stepIndex: stepIndex,
                totalSteps: totalSteps,
                onBack: onBack,
              ),
              const SizedBox(height: 8),
              for (final line in step.titleLines)
                Text(
                  line,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                step.subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: step.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = step.options[index];
              return SurveyOptionCard(
                option: option,
                selected: option.id == selectedOptionId,
                onTap: () => onSelect(option.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
