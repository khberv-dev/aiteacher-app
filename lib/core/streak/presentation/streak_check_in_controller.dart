import 'package:ai_teacher/core/streak/data/streak_dtos.dart';
import 'package:ai_teacher/core/streak/data/streak_repository.dart';
import 'package:ai_teacher/core/streak/presentation/streak_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session-scoped flag that prevents the daily check-in from firing more
/// than once per app launch (or login). Invalidate the provider on logout
/// so the next sign-in re-triggers it.
final streakCheckInProvider = NotifierProvider<StreakCheckInController, bool>(
  StreakCheckInController.new,
);

class StreakCheckInController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Returns the freshly checked-in [WeeklyStreak] on success, or `null` if
  /// it was already run this session or the call failed.
  Future<WeeklyStreak?> runIfNeeded() async {
    if (state) return null;
    state = true;
    try {
      final updated = await ref.read(streakRepositoryProvider).checkIn();
      ref.invalidate(weeklyStreakProvider);
      return updated;
    } catch (e) {
      debugPrint('streak check-in failed: $e');
      state = false;
      return null;
    }
  }
}
