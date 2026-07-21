import 'package:ai_teacher/core/battle/data/battle_socket.dart';
import 'package:ai_teacher/core/call/data/call_socket.dart';
import 'package:ai_teacher/core/chat/data/chat_socket.dart';
import 'package:ai_teacher/core/promo/data/promo_socket.dart';
import 'package:ai_teacher/core/student_activity/data/student_activity_socket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socketReconnectCoordinatorProvider = Provider<SocketReconnectCoordinator>(
  (ref) {
    return SocketReconnectCoordinator(ref);
  },
);

/// Reconnects every long-lived socket after [AuthInterceptor] refreshes the
/// access token, so a socket that failed to connect on an expired token
/// doesn't stay dead until something unrelated (app restart, re-opening the
/// owning screen) happens to reconnect it.
///
/// Reading an autoDispose socket provider here (battle) when nobody's
/// currently watching it is harmless — Riverpod creates it, `connect()` runs
/// once, and the provider is torn back down since nothing retains it.
class SocketReconnectCoordinator {
  SocketReconnectCoordinator(this._ref);

  final Ref _ref;

  void reconnectAll() {
    _run('promo', () => _ref.read(promoSocketProvider).reconnect());
    _run('chat', () => _ref.read(chatSocketProvider).connect());
    _run('call', () => _ref.read(callSocketProvider).connect());
    _run('battle', () => _ref.read(battleSocketProvider).connect());
    _run(
      'student-activity',
      () => _ref.read(studentActivitySocketProvider).reconnect(),
    );
  }

  void _run(String label, Object? Function() action) {
    try {
      final result = action();
      if (result is Future) {
        result.catchError((Object e) {
          debugPrint('$label socket reconnect failed: $e');
        });
      }
    } catch (e) {
      debugPrint('$label socket reconnect failed: $e');
    }
  }
}
