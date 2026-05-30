import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/chatbot/data/chatbot_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotRepository(ref.watch(dioProvider));
});

class ChatbotRepository {
  ChatbotRepository(this._dio);

  final Dio _dio;

  Future<ChatbotSession> createSession() async {
    final response = await _dio.post<Map<String, dynamic>>('chatbot/sessions');
    return ChatbotSession.fromJson(response.data ?? const {});
  }

  Future<({ChatbotMessage userMessage, ChatbotMessage reply})> sendMessage(
    String sessionId,
    String content,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'chatbot/sessions/$sessionId/messages',
      data: {'content': content},
    );
    final data = response.data ?? const {};
    return (
      userMessage: ChatbotMessage.fromJson(
        Map<String, dynamic>.from(data['userMessage'] as Map),
      ),
      reply: ChatbotMessage.fromJson(
        Map<String, dynamic>.from(data['reply'] as Map),
      ),
    );
  }
}
