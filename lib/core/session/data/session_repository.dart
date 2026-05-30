import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/session/data/session_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    publicDio: ref.watch(unauthDioProvider),
    authDio: ref.watch(dioProvider),
  );
});

class SessionRepository {
  SessionRepository({required this.publicDio, required this.authDio});

  final Dio publicDio;
  final Dio authDio;

  /// Public — called on first launch (or whenever no session id is cached).
  Future<Session> create({String? fcmToken}) async {
    final os = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    final response = await publicDio.post<Map<String, dynamic>>(
      'sessions',
      data: {
        'os': os,
        'fcmToken': ?fcmToken,
      },
    );
    return Session.fromJson(response.data ?? const {});
  }

  /// Auth required — claims the session for the current user and refreshes
  /// the FCM token / server-side IP. Call once right after login/register.
  Future<Session> attachUser({
    required String sessionId,
    String? fcmToken,
  }) async {
    final response = await authDio.patch<Map<String, dynamic>>(
      'sessions/$sessionId',
      data: {'fcmToken': ?fcmToken},
    );
    return Session.fromJson(response.data ?? const {});
  }

  /// Auth required — refreshes `os` and `fcmToken` on a session that already
  /// belongs to the current user. Call on every app launch after login.
  Future<Session> update({
    required String sessionId,
    String? fcmToken,
  }) async {
    final os = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    final response = await authDio.put<Map<String, dynamic>>(
      'sessions/$sessionId',
      data: {'os': os, 'fcmToken': ?fcmToken},
    );
    return Session.fromJson(response.data ?? const {});
  }
}
