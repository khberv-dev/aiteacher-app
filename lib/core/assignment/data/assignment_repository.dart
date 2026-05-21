import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/assignment/data/assignment_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(ref.watch(dioProvider));
});

class AssignmentRepository {
  AssignmentRepository(this._dio);

  final Dio _dio;

  Future<List<Assignment>> listMine() async {
    final response = await _dio.get<List<dynamic>>('assignments');
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => Assignment.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }
}
