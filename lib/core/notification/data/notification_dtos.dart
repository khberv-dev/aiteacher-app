class UserNotification {
  const UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, String>? data;

  UserNotification copyWith({bool? isRead}) => UserNotification(
    id: id,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    data: data,
  );

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return UserNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      data: rawData is Map
          ? Map<String, String>.from(rawData.cast<String, String>())
          : null,
    );
  }
}
