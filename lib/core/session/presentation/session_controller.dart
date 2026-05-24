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

  /// Creates a session if none exists; attaches the logged-in user when an
  /// access token is present. Idempotent — safe to call repeatedly.
  Future<void> syncSession() async {
    final cache = ref.read(cacheServiceProvider);
    final fcmToken = cache.fcmToken;
    final accessToken = cache.accessToken;
    final existing = state ?? cache.sessionId;

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
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        await ref
            .read(sessionRepositoryProvider)
            .attachUser(sessionId: id, fcmToken: fcmToken);
      }
    } catch (e, st) {
      debugPrint('session sync failed: $e\n$st');
    }
  }
}
