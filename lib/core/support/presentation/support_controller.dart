import 'package:ai_teacher/core/auth/data/auth_session.dart';
import 'package:ai_teacher/core/support/data/support_dtos.dart';
import 'package:ai_teacher/core/support/data/support_repository.dart';
import 'package:ai_teacher/core/support/data/support_socket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportState {
  const SupportState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final List<SupportMessage> messages;
  final bool isSending;
  final String? error;

  SupportState copyWith({
    List<SupportMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) => SupportState(
    messages: messages ?? this.messages,
    isSending: isSending ?? this.isSending,
    error: clearError ? null : (error ?? this.error),
  );
}

class SupportController extends AutoDisposeAsyncNotifier<SupportState> {
  SupportSocket? _socket;

  @override
  Future<SupportState> build() async {
    final session = ref.read(authSessionProvider);
    _socket = SupportSocket(session);
    ref.onDispose(_socket!.dispose);

    // Connect socket first so sendMessage works immediately
    await _socket!.connect();
    final sub = _socket!.incoming.listen((msg) {
      final current = state.valueOrNull;
      if (current == null) return;
      if (current.messages.any((m) => m.id == msg.id)) return;
      state = AsyncData(current.copyWith(messages: [...current.messages, msg]));
    });
    ref.onDispose(sub.cancel);

    // Load history (newest first from API → reverse for display)
    List<SupportMessage> history = [];
    try {
      final repo = ref.read(supportRepositoryProvider);
      final room = await repo.getRoom();
      if (room != null) {
        final msgs = await repo.getMessages(limit: 50);
        history = msgs.reversed.toList();
      }
    } catch (_) {}

    return SupportState(messages: history);
  }

  void send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _socket?.sendMessage(trimmed);
  }
}

final supportControllerProvider =
    AutoDisposeAsyncNotifierProvider<SupportController, SupportState>(
      SupportController.new,
    );
