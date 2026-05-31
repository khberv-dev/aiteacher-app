import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/writing_task/data/writing_task_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final writingTaskRepositoryProvider = Provider<WritingTaskRepository>((ref) {
  return WritingTaskRepository(ref.watch(dioProvider));
});

class WritingTaskRepository {
  WritingTaskRepository(this._dio);

  final Dio _dio;

  Future<WritingTask> create() async {
    final response = await _dio.post<Map<String, dynamic>>('writing-tasks');
    return WritingTask.fromJson(response.data!);
  }

  Future<List<WritingTask>> list() async {
    final response = await _dio.get<List<dynamic>>('writing-tasks');
    return (response.data ?? [])
        .whereType<Map>()
        .map((e) => WritingTask.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<WritingTask> findOne(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('writing-tasks/$id');
    return WritingTask.fromJson(response.data!);
  }

  Future<WritingTask> submitTranslation(
    String id,
    String uzbekTranslation,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'writing-tasks/$id/translation',
      data: {'uzbekTranslation': uzbekTranslation},
    );
    return WritingTask.fromJson(response.data!);
  }

  Future<WritingTask> submitBackTranslation(
    String id,
    String backTranslation,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'writing-tasks/$id/back-translation',
      data: {'backTranslation': backTranslation},
    );
    return WritingTask.fromJson(response.data!);
  }
}
