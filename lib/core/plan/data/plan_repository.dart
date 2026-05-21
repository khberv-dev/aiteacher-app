import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(ref.watch(dioProvider));
});

class PlanRepository {
  PlanRepository(this._dio);

  final Dio _dio;

  Future<List<Plan>> listActive() async {
    final response = await _dio.get<List<dynamic>>(
      'plans',
      queryParameters: {'activeOnly': 'true'},
    );
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => Plan.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }
}
