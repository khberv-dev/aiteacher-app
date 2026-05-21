enum ChatMessageType {
  message,
  comment,
  task;

  String get apiName => switch (this) {
    ChatMessageType.message => 'message',
    ChatMessageType.comment => 'comment',
    ChatMessageType.task => 'task',
  };

  static ChatMessageType fromApi(String? raw) {
    switch (raw) {
      case 'comment':
        return ChatMessageType.comment;
      case 'task':
        return ChatMessageType.task;
      default:
        return ChatMessageType.message;
    }
  }
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.peerAId,
    required this.peerBId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String peerAId;
  final String peerBId;
  final DateTime createdAt;
  final DateTime updatedAt;

  String otherPeer(String currentUserId) =>
      peerAId == currentUserId ? peerBId : peerAId;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String? ?? '',
      peerAId: json['peerAId'] as String? ?? '',
      peerBId: json['peerBId'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.chatRoomId,
    required this.sentFromId,
    required this.sentAt,
    required this.type,
  });

  final String id;
  final String text;
  final String chatRoomId;
  final String sentFromId;
  final DateTime sentAt;
  final ChatMessageType type;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      chatRoomId: json['chatRoomId'] as String? ?? '',
      sentFromId: json['sentFromId'] as String? ?? '',
      sentAt: _parseDate(json['sentAt']),
      type: ChatMessageType.fromApi(json['type'] as String?),
    );
  }
}

DateTime _parseDate(dynamic raw) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime.now();
}
