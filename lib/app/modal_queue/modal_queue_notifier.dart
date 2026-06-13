import 'package:ai_teacher/app/modal_queue/modal_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final modalQueueProvider =
    NotifierProvider<ModalQueueNotifier, List<ModalTask>>(
  ModalQueueNotifier.new,
);

class ModalQueueNotifier extends Notifier<List<ModalTask>> {
  @override
  List<ModalTask> build() => const [];

  void enqueue(ModalTask task) {
    state = [...state, task];
  }

  ModalTask? dequeue() {
    if (state.isEmpty) return null;
    final task = state.first;
    state = state.sublist(1);
    return task;
  }
}
