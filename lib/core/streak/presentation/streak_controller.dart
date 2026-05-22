import 'package:ai_teacher/core/streak/data/streak_dtos.dart';
import 'package:ai_teacher/core/streak/data/streak_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyStreakProvider = FutureProvider<WeeklyStreak>((ref) {
  return ref.watch(streakRepositoryProvider).getMine();
});
