import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/ui/shared/widget/primary_button.dart';
import 'package:ai_teacher/ui/survey/survey_data.dart';
import 'package:ai_teacher/ui/survey/widget/survey_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  late final List<String?> _answers;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _answers = [for (final step in kSurveySteps) step.defaultOptionId];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(String optionId) {
    setState(() => _answers[_currentStep] = optionId);
  }

  void _goToStep(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onContinue() {
    if (_currentStep < kSurveySteps.length - 1) {
      _goToStep(_currentStep + 1);
      return;
    }
    if (!mounted) return;
    final answers = SurveyAnswers(
      goal: _answers.isNotEmpty ? _answers[0] : null,
      level: _answers.length > 1 ? _answers[1] : null,
      dailyTime: _answers.length > 2 ? _answers[2] : null,
    );
    context.goNamed(AppRoute.register.name, extra: answers);
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return;
    }
    if (!mounted) return;
    context.goNamed(AppRoute.onboarding.name);
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _answers[_currentStep] != null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  itemCount: kSurveySteps.length,
                  itemBuilder: (context, index) {
                    return SurveyStepView(
                      step: kSurveySteps[index],
                      stepIndex: index,
                      totalSteps: kSurveySteps.length,
                      selectedOptionId: _answers[index],
                      onSelect: _selectOption,
                      onBack: _onBack,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: PrimaryButton(
                  label: 'Davom etish  →',
                  enabled: canContinue,
                  onPressed: _onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
