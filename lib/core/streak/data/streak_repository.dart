import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/streak/data/streak_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(dioProvider));
});

class StreakRepository {
  StreakRepository(this._dio);

  final Dio _dio;

  Future<WeeklyStreak> getMine() async {
    final response = await _dio.get<Map<String, dynamic>>('streak/me');
    return WeeklyStreak.fromJson(response.data ?? const {});
  }

  Future<WeeklyStreak> checkIn() async {
    final response = await _dio.post<Map<String, dynamic>>('streak/check-in');
    return WeeklyStreak.fromJson(response.data ?? const {});
  }
}
