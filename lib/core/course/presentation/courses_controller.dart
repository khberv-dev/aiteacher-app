import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/core/course/data/course_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoursesState {
  const CoursesState({this.mine = const [], this.active = const []});

  final List<Course> mine;
  final List<Course> active;
}

class CoursesController extends AutoDisposeAsyncNotifier<CoursesState> {
  @override
  Future<CoursesState> build() async {
    final repo = ref.watch(courseRepositoryProvider);
    final results = await Future.wait([repo.listMine(), repo.listActive()]);
    return CoursesState(mine: results[0], active: results[1]);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final coursesControllerProvider =
    AutoDisposeAsyncNotifierProvider<CoursesController, CoursesState>(
      CoursesController.new,
    );
