import 'package:ai_teacher/core/writing_task/data/writing_task_dtos.dart';
import 'package:ai_teacher/core/writing_task/presentation/writing_task_controller.dart';
import 'package:ai_teacher/core/writing_task/presentation/writing_task_list_controller.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_task_completed_view.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_task_feedback_view.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_task_step1_view.dart';
import 'package:ai_teacher/ui/writing_task/widget/writing_task_step2_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritingTaskScreen extends ConsumerWidget {
  const WritingTaskScreen({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(writingTaskControllerProvider(taskId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(
                step: async.valueOrNull != null
                    ? _stepIndex(async.value!)
                    : null,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Vazifa yuklanmadi',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => ref.invalidate(
                              writingTaskControllerProvider(taskId),
                            ),
                            child: const Text('Qayta urinish'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (state) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _body(context, ref, state),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _stepIndex(WritingTaskState state) {
    if (state.task.status == WritingTaskStatus.completed) return 3;
    if (state.task.status == WritingTaskStatus.pendingBackTranslation) {
      return state.showingTranslationFeedback ? 2 : 3;
    }
    return 1;
  }

  Widget _body(BuildContext context, WidgetRef ref, WritingTaskState state) {
    final ctrl = ref.read(writingTaskControllerProvider(taskId).notifier);
    final task = state.task;

    if (task.status == WritingTaskStatus.pendingTranslation) {
      return WritingTaskStep1View(
        key: const ValueKey('step1'),
        theme: task.theme,
        originText: task.originText,
        isSubmitting: state.isSubmitting,
        onSubmit: ctrl.submitTranslation,
      );
    }

    if (task.status == WritingTaskStatus.pendingBackTranslation &&
        state.showingTranslationFeedback) {
      return WritingTaskFeedbackView(
        key: const ValueKey('feedback1'),
        score: task.translationScore ?? 0,
        feedback: task.translationFeedback ?? '',
        onContinue: ctrl.continueToBackTranslation,
      );
    }

    if (task.status == WritingTaskStatus.pendingBackTranslation) {
      return WritingTaskStep2View(
        key: const ValueKey('step2'),
        uzbekTranslation: task.uzbekTranslation ?? '',
        isSubmitting: state.isSubmitting,
        onSubmit: ctrl.submitBackTranslation,
      );
    }

    return WritingTaskCompletedView(
      key: const ValueKey('completed'),
      translationScore: task.translationScore ?? 0,
      backTranslationScore: task.backTranslationScore ?? 0,
      backTranslationFeedback: task.backTranslationFeedback ?? '',
      onDone: () {
        ref.invalidate(writingTaskListControllerProvider);
        Navigator.of(context).pop();
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.step});

  final int? step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: const Color(0xFF64748B),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Yozish Vazifasi',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (step != null) ...[
                    const SizedBox(height: 4),
                    _StepDots(current: step!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i + 1 <= current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
