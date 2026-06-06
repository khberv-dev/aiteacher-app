import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/support/data/support_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.watch(dioProvider));
});

class SupportRepository {
  SupportRepository(this._dio);

  final Dio _dio;

  Future<SupportRoom?> getRoom() async {
    final response = await _dio.get<dynamic>('support/room');
    final data = response.data;
    if (data == null || data is! Map) return null;
    return SupportRoom.fromJson(data.cast<String, dynamic>());
  }

  Future<List<SupportMessage>> getMessages({
    int? limit,
    DateTime? before,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      'support/room/messages',
      queryParameters: {'limit': ?limit, 'before': ?before?.toIso8601String()},
    );
    return (response.data ?? [])
        .whereType<Map>()
        .map((e) => SupportMessage.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }
}
