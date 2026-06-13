import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:ai_teacher/core/promo/data/promo_dtos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// ref.read — provider is never rebuilt when authSessionProvider changes,
// keeping the socket alive for the entire app lifetime.
final promoSocketProvider = Provider<PromoSocket>((ref) {
  final socket = PromoSocket(ref.read(authSessionProvider));
  ref.onDispose(socket.dispose);
  return socket;
});

class PromoSocket {
  PromoSocket(this._session);

  final AuthSession _session;
  io.Socket? _socket;

  // Set at the start of connect() — before the handshake completes — so that
  // reconnect() can detect an in-progress connection and not disrupt it.
  // Cleared when a disconnect event fires so the next reconnect() actually runs.
  String? _activeUserId;

  final StreamController<PromoEvent> _events =
      StreamController<PromoEvent>.broadcast();

  Stream<PromoEvent> get events => _events.stream;

  bool get connected => _socket?.connected ?? false;

  /// No-op when a socket for the current userId is already connecting or
  /// connected. Only disconnects and reconnects when the userId changed.
  Future<void> reconnect() async {
    final userId = _session.currentUserId ?? '';
    if (_socket != null && _activeUserId == userId) {
      debugPrint('promo socket already active userId=$userId, skipping reconnect');
      return;
    }
    _socket?.dispose();
    _socket = null;
    _activeUserId = null;
    await connect();
  }

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    final userId = _session.currentUserId ?? '';

    // Track the intended userId NOW, before the async handshake, so that a
    // concurrent reconnect() call for the same userId becomes a no-op.
    _activeUserId = userId;

    final socket = io.io(
      '${NetworkConfig.hostUrl}/promo',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'userId': userId})
          .disableAutoConnect()
          .build(),
    );

    socket.on('connect', (_) {
      debugPrint('promo socket connected userId=$userId');
    });
    socket.on('disconnect', (reason) {
      // Clear so the next reconnect() call actually re-establishes the socket.
      _activeUserId = null;
      debugPrint('promo socket disconnected: $reason');
    });
    socket.on('connect_error', (err) {
      debugPrint('promo socket connect_error: $err');
    });
    socket.on('promo', (data) {
      debugPrint(
        'promo socket message — type: ${data.runtimeType}, data: $data',
      );
      try {
        // socket_io_client wraps payloads in a List when the server emits
        // with an ack callback: [actualPayload, ackFn]. Unwrap if needed.
        final payload = data is List ? data.first : data;
        if (payload is Map) {
          _events.add(PromoEvent.fromJson(payload.cast<String, dynamic>()));
        } else {
          debugPrint('promo socket ignored unexpected payload type: ${payload.runtimeType}');
        }
      } catch (e, st) {
        debugPrint('promo socket parse error: $e\n$st');
      }
    });

    socket.connect();
    _socket = socket;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _activeUserId = null;
    if (!_events.isClosed) _events.close();
  }
}
