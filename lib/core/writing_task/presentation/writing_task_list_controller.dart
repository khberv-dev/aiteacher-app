import 'package:ai_teacher/core/writing_task/data/writing_task_dtos.dart';
import 'package:ai_teacher/core/writing_task/data/writing_task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WritingTaskListController
    extends AutoDisposeAsyncNotifier<List<WritingTask>> {
  @override
  Future<List<WritingTask>> build() {
    return ref.read(writingTaskRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(writingTaskRepositoryProvider).list(),
    );
  }
}

final writingTaskListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      WritingTaskListController,
      List<WritingTask>
    >(WritingTaskListController.new);
