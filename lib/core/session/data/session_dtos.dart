class Session {
  const Session({
    required this.id,
    this.userId,
    this.os,
    this.fcmToken,
    this.ip,
  });

  final String id;
  final String? userId;
  final String? os;
  final String? fcmToken;
  final String? ip;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      os: json['os'] as String?,
      fcmToken: json['fcmToken'] as String?,
      ip: json['ip'] as String?,
    );
  }
}
