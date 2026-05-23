import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/session/data/session_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(dioProvider));
});

class SessionRepository {
  SessionRepository(this._dio);

  final Dio _dio;

  /// Public — called on first launch (or whenever no session id is cached).
  Future<Session> create({String? fcmToken}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'sessions',
      data: {'fcmToken': ?fcmToken},
    );
    return Session.fromJson(response.data ?? const {});
  }

  /// Auth required — claims the session for the current user and refreshes
  /// the FCM token / server-side IP.
  Future<Session> attachUser({
    required String sessionId,
    String? fcmToken,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'sessions/$sessionId',
      data: {'fcmToken': ?fcmToken},
    );
    return Session.fromJson(response.data ?? const {});
  }
}
