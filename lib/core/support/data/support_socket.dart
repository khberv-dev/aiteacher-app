import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:ai_teacher/core/support/data/support_dtos.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SupportSocket {
  SupportSocket(this._session);

  final AuthSession _session;
  io.Socket? _socket;

  final _incoming = StreamController<SupportMessage>.broadcast();

  Stream<SupportMessage> get incoming => _incoming.stream;

  bool get connected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    final token = _session.accessToken;
    if (token == null || token.isEmpty) return;

    final socket = io.io(
      '${NetworkConfig.hostUrl}/support',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket.on('connect', (_) => debugPrint('support socket connected'));
    socket.on(
      'disconnect',
      (r) => debugPrint('support socket disconnected: $r'),
    );
    socket.on('connect_error', (e) => debugPrint('support socket error: $e'));
    socket.on('message', (data) {
      try {
        if (data is Map) {
          _incoming.add(SupportMessage.fromJson(data.cast<String, dynamic>()));
        }
      } catch (e) {
        debugPrint('support socket parse error: $e');
      }
    });

    socket.connect();
    _socket = socket;
  }

  void sendMessage(String text) {
    _socket?.emit('message', {'text': text});
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    if (!_incoming.isClosed) _incoming.close();
  }
}
