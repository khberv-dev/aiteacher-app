import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/chat/data/chat_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<List<ChatRoom>> listRooms() async {
    final response = await _dio.get<List<dynamic>>('chat/rooms');
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => ChatRoom.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<ChatRoom> getOrCreateRoom(String peerId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'chat/rooms',
      data: {'peerId': peerId},
    );
    return ChatRoom.fromJson(response.data ?? const {});
  }

  Future<List<ChatMessage>> listMessages(
    String roomId, {
    int limit = 50,
    DateTime? before,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (before != null) query['before'] = before.toUtc().toIso8601String();
    final response = await _dio.get<List<dynamic>>(
      'chat/rooms/$roomId/messages',
      queryParameters: query,
    );
    final items = response.data ?? const [];
    return items
        .whereType<Map>()
        .map((e) => ChatMessage.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<ChatMessage> sendMessage(
    String roomId, {
    required String text,
    required ChatMessageType type,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'chat/rooms/$roomId/messages',
      data: {'text': text, 'type': type.apiName},
    );
    return ChatMessage.fromJson(response.data ?? const {});
  }
}
