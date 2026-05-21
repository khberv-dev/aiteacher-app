import 'dart:async';

import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:ai_teacher/core/chat/data/chat_dtos.dart';
import 'package:ai_teacher/core/chat/data/chat_repository.dart';
import 'package:ai_teacher/core/chat/data/chat_socket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomState {
  const ChatRoomState({
    required this.loading,
    required this.sending,
    required this.messages,
    this.room,
    this.error,
  });

  final bool loading;
  final bool sending;
  final List<ChatMessage> messages;
  final ChatRoom? room;
  final String? error;

  static const ChatRoomState initial = ChatRoomState(
    loading: true,
    sending: false,
    messages: [],
  );

  ChatRoomState copyWith({
    bool? loading,
    bool? sending,
    List<ChatMessage>? messages,
    ChatRoom? room,
    Object? error = _sentinel,
  }) {
    return ChatRoomState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      messages: messages ?? this.messages,
      room: room ?? this.room,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

final chatRoomControllerProvider = NotifierProvider.autoDispose
    .family<ChatRoomController, ChatRoomState, String>(ChatRoomController.new);

class ChatRoomController
    extends AutoDisposeFamilyNotifier<ChatRoomState, String> {
  StreamSubscription<ChatMessage>? _sub;

  @override
  ChatRoomState build(String peerId) {
    ref.onDispose(() => _sub?.cancel());
    Future.microtask(_initialize);
    return ChatRoomState.initial;
  }

  String get peerId => arg;

  Future<void> _initialize() async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      final room = await repo.getOrCreateRoom(peerId);
      final history = await repo.listMessages(room.id);
      state = state.copyWith(
        loading: false,
        room: room,
        messages: history,
        error: null,
      );

      final socket = ref.read(chatSocketProvider);
      await socket.connect();
      _sub = socket.incoming.listen((msg) {
        if (msg.chatRoomId != room.id) return;
        if (state.messages.any((m) => m.id == msg.id)) return;
        state = state.copyWith(messages: [msg, ...state.messages]);
      });
    } catch (e, st) {
      debugPrint('chat room init failed: $e\n$st');
      state = state.copyWith(
        loading: false,
        error: 'Suhbatni yuklab bo\'lmadi',
      );
    }
  }

  Future<bool> send(String text, ChatMessageType type) async {
    final body = text.trim();
    final room = state.room;
    if (body.isEmpty || room == null) return false;
    state = state.copyWith(sending: true, error: null);
    try {
      final saved = await ref
          .read(chatRepositoryProvider)
          .sendMessage(room.id, text: body, type: type);
      // The server fans the message back over the socket; only optimistically
      // append if we don't already have it (covers slow echoes).
      if (!state.messages.any((m) => m.id == saved.id)) {
        state = state.copyWith(messages: [saved, ...state.messages]);
      }
      state = state.copyWith(sending: false);
      return true;
    } catch (e) {
      state = state.copyWith(sending: false, error: 'Yuborilmadi');
      return false;
    }
  }

  Future<void> retry() => _initialize();
}

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authSessionProvider).currentUserId;
});
