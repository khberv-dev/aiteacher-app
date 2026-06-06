enum SupportMessageAuthor {
  user,
  system;

  factory SupportMessageAuthor.fromValue(String v) =>
      v == 'system' ? system : user;
}

class SupportRoom {
  const SupportRoom({required this.id, required this.userId});

  final String id;
  final String userId;

  factory SupportRoom.fromJson(Map<String, dynamic> json) => SupportRoom(
    id: json['id'] as String,
    userId: json['userId'] as String? ?? '',
  );
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.roomId,
    required this.text,
    required this.author,
    required this.sentAt,
  });

  final String id;
  final String roomId;
  final String text;
  final SupportMessageAuthor author;
  final DateTime sentAt;

  bool get isFromUser => author == SupportMessageAuthor.user;

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
    id: json['id'] as String,
    roomId: json['roomId'] as String? ?? '',
    text: json['text'] as String? ?? '',
    author: SupportMessageAuthor.fromValue(json['author'] as String? ?? ''),
    sentAt:
        DateTime.tryParse(json['sentAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
