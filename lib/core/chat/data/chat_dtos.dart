class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.studentId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
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
    required this.authorUserId,
    required this.authorFullName,
    required this.authorRole,
    required this.sentAt,
  });

  final String id;
  final String text;
  final String chatRoomId;
  final String authorUserId;
  final String authorFullName;
  final String authorRole;
  final DateTime sentAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      chatRoomId: json['chatRoomId'] as String? ?? '',
      authorUserId: json['authorUserId'] as String? ?? '',
      authorFullName: json['authorFullName'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      sentAt: _parseDate(json['sentAt']),
    );
  }
}

DateTime _parseDate(dynamic raw) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  return DateTime.now();
}
