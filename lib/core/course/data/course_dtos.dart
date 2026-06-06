class Course {
  const Course({
    required this.id,
    required this.title,
    required this.url,
    required this.isActive,
    this.coverUrl,
    this.description,
    this.login,
    this.password,
  });

  final String id;
  final String title;
  final String url;
  final bool isActive;

  /// Relative path served under `/public/`, e.g. `courses/uuid.jpg`.
  final String? coverUrl;

  final String? description;

  /// Per-enrollment credentials set by admin. Null if not configured.
  final String? login;
  final String? password;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      login: json['login'] as String?,
      password: json['password'] as String?,
    );
  }
}
