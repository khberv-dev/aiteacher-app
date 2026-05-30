import 'package:ai_teacher/core/chatbot/data/chatbot_dtos.dart';
import 'package:ai_teacher/core/chatbot/data/chatbot_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatbotState {
  const ChatbotState({
    required this.sessionId,
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final String sessionId;
  final List<ChatbotMessage> messages;
  final bool isSending;
  final String? error;

  ChatbotState copyWith({
    List<ChatbotMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatbotState(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatbotController extends AutoDisposeAsyncNotifier<ChatbotState> {
  @override
  Future<ChatbotState> build() async {
    final session =
        await ref.watch(chatbotRepositoryProvider).createSession();
    return ChatbotState(sessionId: session.id);
  }

  Future<void> sendMessage(String content) async {
    final current = state.valueOrNull;
    if (current == null || current.isSending) return;

    final tempId = 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatbotMessage(
      id: tempId,
      sessionId: current.sessionId,
      role: ChatbotRole.user,
      content: content,
    );

    state = AsyncData(current.copyWith(
      messages: [...current.messages, tempMsg],
      isSending: true,
      clearError: true,
    ));

    try {
      final result = await ref
          .read(chatbotRepositoryProvider)
          .sendMessage(current.sessionId, content);
      final now = state.valueOrNull;
      if (now == null) return;
      final msgs = now.messages.where((m) => m.id != tempId).toList()
        ..add(result.userMessage)
        ..add(result.reply);
      state = AsyncData(now.copyWith(messages: msgs, isSending: false));
    } catch (e) {
      final now = state.valueOrNull;
      if (now == null) return;
      state = AsyncData(now.copyWith(
        messages: now.messages.where((m) => m.id != tempId).toList(),
        isSending: false,
        error: 'Xatolik yuz berdi. Qayta urinib ko\'ring.',
      ));
    }
  }
}

final chatbotControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChatbotController, ChatbotState>(
  ChatbotController.new,
);
