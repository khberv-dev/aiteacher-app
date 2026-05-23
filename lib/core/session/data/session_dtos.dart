class Session {
  const Session({
    required this.id,
    this.userId,
    this.fcmToken,
    this.ip,
  });

  final String id;
  final String? userId;
  final String? fcmToken;
  final String? ip;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      fcmToken: json['fcmToken'] as String?,
      ip: json['ip'] as String?,
    );
  }
}
