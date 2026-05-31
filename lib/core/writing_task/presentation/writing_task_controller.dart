import 'package:ai_teacher/core/writing_task/data/writing_task_dtos.dart';
import 'package:ai_teacher/core/writing_task/data/writing_task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritingTaskState {
  const WritingTaskState({
    required this.task,
    this.isSubmitting = false,
    this.showingTranslationFeedback = false,
  });

  final WritingTask task;
  final bool isSubmitting;
  final bool showingTranslationFeedback;

  WritingTaskState copyWith({
    WritingTask? task,
    bool? isSubmitting,
    bool? showingTranslationFeedback,
  }) {
    return WritingTaskState(
      task: task ?? this.task,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showingTranslationFeedback:
          showingTranslationFeedback ?? this.showingTranslationFeedback,
    );
  }
}

// ignore: lines_longer_than_80_chars
class WritingTaskController
    extends AutoDisposeFamilyAsyncNotifier<WritingTaskState, String?> {
  @override
  Future<WritingTaskState> build(String? taskId) async {
    final repo = ref.read(writingTaskRepositoryProvider);
    final task = taskId == null
        ? await repo.create()
        : await repo.findOne(taskId);
    return WritingTaskState(task: task);
  }

  Future<void> submitTranslation(String uzbekTranslation) async {
    final current = state.valueOrNull;
    if (current == null || current.isSubmitting) return;

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final updated = await ref
          .read(writingTaskRepositoryProvider)
          .submitTranslation(current.task.id, uzbekTranslation);
      state = AsyncData(
        WritingTaskState(task: updated, showingTranslationFeedback: true),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isSubmitting: false));
      rethrow;
    }
  }

  void continueToBackTranslation() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(showingTranslationFeedback: false));
  }

  Future<void> submitBackTranslation(String backTranslation) async {
    final current = state.valueOrNull;
    if (current == null || current.isSubmitting) return;

    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final updated = await ref
          .read(writingTaskRepositoryProvider)
          .submitBackTranslation(current.task.id, backTranslation);
      state = AsyncData(WritingTaskState(task: updated));
    } catch (_) {
      state = AsyncData(current.copyWith(isSubmitting: false));
      rethrow;
    }
  }
}

final writingTaskControllerProvider = AsyncNotifierProvider.autoDispose
    .family<WritingTaskController, WritingTaskState, String?>(
      WritingTaskController.new,
    );
