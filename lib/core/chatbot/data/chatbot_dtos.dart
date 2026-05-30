enum ChatbotRole { user, assistant }

class ChatbotSession {
  const ChatbotSession({required this.id, required this.userId});

  final String id;
  final String userId;

  factory ChatbotSession.fromJson(Map<String, dynamic> json) {
    return ChatbotSession(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }
}

class ChatbotMessage {
  const ChatbotMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
  });

  final String id;
  final String sessionId;
  final ChatbotRole role;
  final String content;

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      role: (json['role'] as String?) == 'assistant'
          ? ChatbotRole.assistant
          : ChatbotRole.user,
      content: json['content'] as String? ?? '',
    );
  }
}
