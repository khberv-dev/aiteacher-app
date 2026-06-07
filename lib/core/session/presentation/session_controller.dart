import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/core/session/data/session_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current session id (mirrored from [CacheService]) and runs the
/// create-or-attach sync. Call [syncSession] on every relevant trigger —
/// app launch, login/register success, and FCM token refresh.
final sessionControllerProvider = NotifierProvider<SessionController, String?>(
  SessionController.new,
);

class SessionController extends Notifier<String?> {
  @override
  String? build() {
    final cached = ref.read(cacheServiceProvider).sessionId;
    return cached == null || cached.isEmpty ? null : cached;
  }

  /// Persists [token] (or removes when null/empty) and re-syncs the session
  /// so the server sees the latest device token.
  Future<void> updateFcmToken(String? token) async {
    final cache = ref.read(cacheServiceProvider);
    if (token == null || token.isEmpty) {
      await cache.removeFcmToken();
    } else {
      await cache.setFcmToken(token);
    }
    await syncSession();
  }

  /// Called on every app launch (and FCM token refresh). Creates a session if
  /// none exists; if already logged in with no session it also claims it.
  /// For sessions that are already claimed, uses PUT to refresh os/fcmToken.
  Future<void> syncSession() async {
    final cache = ref.read(cacheServiceProvider);
    final fcmToken = cache.fcmToken;
    final accessToken = cache.accessToken;
    final existing = state ?? cache.sessionId;
    final isLoggedIn = accessToken != null && accessToken.isNotEmpty;

    try {
      String? id = existing;
      if (id == null || id.isEmpty) {
        final session = await ref
            .read(sessionRepositoryProvider)
            .create(fcmToken: fcmToken);
        if (session.id.isEmpty) return;
        await cache.setSessionId(session.id);
        id = session.id;
        state = session.id;
        // Reinstall while already logged in — claim the new session immediately.
        if (isLoggedIn) {
          await ref
              .read(sessionRepositoryProvider)
              .attachUser(sessionId: id, fcmToken: fcmToken);
        }
        return;
      }
      // Session already exists — update os/fcmToken if authenticated.
      if (isLoggedIn) {
        try {
          await ref
              .read(sessionRepositoryProvider)
              .update(sessionId: id, fcmToken: fcmToken);
        } catch (e) {
          debugPrint('session update failed, creating new session: $e');
          final session = await ref
              .read(sessionRepositoryProvider)
              .create(fcmToken: fcmToken);
          if (session.id.isEmpty) return;
          await cache.setSessionId(session.id);
          state = session.id;
          await ref
              .read(sessionRepositoryProvider)
              .attachUser(sessionId: session.id, fcmToken: fcmToken);
        }
      }
    } catch (e, st) {
      debugPrint('session sync failed: $e\n$st');
    }
  }

  /// Claims the current session for the logged-in user. Call once right after
  /// login or registration so the server links userId to this session.
  Future<void> claimSession() async {
    final cache = ref.read(cacheServiceProvider);
    final id = state ?? cache.sessionId;
    if (id == null || id.isEmpty) return;
    try {
      await ref
          .read(sessionRepositoryProvider)
          .attachUser(sessionId: id, fcmToken: cache.fcmToken);
    } catch (e, st) {
      debugPrint('session claim failed: $e\n$st');
    }
  }
}
