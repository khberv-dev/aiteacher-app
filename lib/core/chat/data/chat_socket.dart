import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:ai_teacher/core/chat/data/chat_dtos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final chatSocketProvider = Provider<ChatSocket>((ref) {
  final socket = ChatSocket(ref.watch(authSessionProvider));
  ref.onDispose(socket.dispose);
  return socket;
});

class ChatSocketException implements Exception {
  ChatSocketException(this.code, [this.details]);

  final String code;
  final Object? details;

  @override
  String toString() => 'ChatSocketException($code)';
}

class ChatSocket {
  ChatSocket(this._session);

  final AuthSession _session;
  io.Socket? _socket;
  final StreamController<ChatMessage> _incoming =
      StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get incoming => _incoming.stream;

  bool get connected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    final token = _session.accessToken;
    if (token == null || token.isEmpty) {
      throw ChatSocketException('no_token');
    }

    final socket = io.io(
      '${NetworkConfig.hostUrl}/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket.on('connect', (_) => debugPrint('chat socket connected'));
    socket.on(
      'disconnect',
      (reason) => debugPrint('chat socket disconnected: $reason'),
    );
    socket.on('connect_error', (err) {
      debugPrint('chat socket connect_error: $err');
    });
    socket.on('message', (data) {
      try {
        if (data is Map) {
          _incoming.add(ChatMessage.fromJson(data.cast<String, dynamic>()));
        }
      } catch (e, st) {
        debugPrint('chat socket parse error: $e\n$st');
      }
    });

    socket.connect();
    _socket = socket;
  }

  Future<ChatMessage> sendMessage({
    required String text,
    required String roomId,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw ChatSocketException('not_connected');
    }
    final completer = Completer<ChatMessage>();
    socket.emitWithAck(
      'message',
      {'text': text, 'roomId': roomId},
      ack: (response) {
        if (response is Map &&
            response.containsKey('error') &&
            response['error'] is String) {
          completer.completeError(
            ChatSocketException(response['error'] as String, response),
          );
          return;
        }
        if (response is Map) {
          try {
            completer.complete(
              ChatMessage.fromJson(response.cast<String, dynamic>()),
            );
          } catch (e) {
            completer.completeError(ChatSocketException('parse_failed', e));
          }
        } else {
          completer.completeError(ChatSocketException('unknown_ack'));
        }
      },
    );
    return completer.future;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    if (!_incoming.isClosed) _incoming.close();
  }
}
