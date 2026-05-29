class CanPostResult {
  const CanPostResult({
    required this.canPost,
    required this.hasPayment,
    required this.canPostByDate,
    this.nextAllowedAt,
  });

  final bool canPost;
  final bool hasPayment;
  final bool canPostByDate;
  final DateTime? nextAllowedAt;

  factory CanPostResult.fromJson(Map<String, dynamic> json) {
    return CanPostResult(
      canPost: json['canPost'] as bool? ?? false,
      hasPayment: json['hasPayment'] as bool? ?? false,
      canPostByDate: json['canPostByDate'] as bool? ?? false,
      nextAllowedAt: DateTime.tryParse(json['nextAllowedAt'] as String? ?? ''),
    );
  }
}

class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.isStatic,
    required this.isActive,
    required this.createdAt,
    this.userId,
    this.reply,
    this.repliedAt,
  });

  final String id;
  final String? userId;
  final String author;
  final String text;
  final bool isStatic;
  final bool isActive;
  final String? reply;
  final DateTime? repliedAt;
  final DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      author: json['author'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isStatic: json['isStatic'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      reply: json['reply'] as String?,
      repliedAt: DateTime.tryParse(json['repliedAt'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
