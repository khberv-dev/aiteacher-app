import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/core/course/data/course_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoursesController extends AutoDisposeAsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() {
    return ref.watch(courseRepositoryProvider).listMine();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final coursesControllerProvider =
    AutoDisposeAsyncNotifierProvider<CoursesController, List<Course>>(
      CoursesController.new,
    );
