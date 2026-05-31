import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final studentActivitySocketProvider = Provider<StudentActivitySocket>((ref) {
  final socket = StudentActivitySocket(ref.watch(authSessionProvider));
  ref.onDispose(socket.dispose);
  return socket;
});

class StudentActivitySocket {
  StudentActivitySocket(this._session);

  final AuthSession _session;
  io.Socket? _socket;

  bool get _connected => _socket?.connected ?? false;

  void _ensureConnected() {
    if (_connected) return;
    final token = _session.accessToken;
    if (token == null || token.isEmpty) return;

    final socket = io.io(
      '${NetworkConfig.hostUrl}/student-activity',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket.on('connect', (_) => debugPrint('activity socket connected'));
    socket.on(
      'disconnect',
      (reason) => debugPrint('activity socket disconnected: $reason'),
    );
    socket.on(
      'connect_error',
      (err) => debugPrint('activity socket connect_error: $err'),
    );

    socket.connect();
    _socket = socket;
  }

  void emitCourseStart() {
    _ensureConnected();
    _socket?.emit('action', {'type': 'course'});
    debugPrint('activity: course start emitted');
  }

  void emitCourseEnd() {
    if (!_connected) return;
    _socket?.emit('action', {'type': 'end-course'});
    debugPrint('activity: course end emitted');
  }

  void emitBattleGameStart() {
    _ensureConnected();
    _socket?.emit('action', {'type': 'battle-game'});
    debugPrint('activity: battle-game start emitted');
  }

  void emitBattleGameEnd() {
    if (!_connected) return;
    _socket?.emit('action', {'type': 'end-battle-game'});
    debugPrint('activity: battle-game end emitted');
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
