import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.watch(dioProvider));
});

class CourseRepository {
  CourseRepository(this._dio);

  final Dio _dio;

  Future<List<Course>> listActive() async {
    final response = await _dio.get<List<dynamic>>('courses');
    return (response.data ?? [])
        .map((e) => Course.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<DemoEnrollment> requestDemo({
    required String paymentId,
    required String courseId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'courses/demo',
      data: {'paymentId': paymentId, 'courseId': courseId},
    );
    return DemoEnrollment.fromJson(response.data ?? const {});
  }

  Future<List<Course>> listMine() async {
    final response = await _dio.get<List<dynamic>>('courses/mine');
    return (response.data ?? [])
        .map((e) => Course.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
