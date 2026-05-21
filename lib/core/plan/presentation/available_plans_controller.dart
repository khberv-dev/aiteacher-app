import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:ai_teacher/core/plan/data/plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final availablePlansProvider = FutureProvider<List<Plan>>((ref) {
  return ref.watch(planRepositoryProvider).listActive();
});
