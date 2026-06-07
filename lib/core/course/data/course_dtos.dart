class Course {
  const Course({
    required this.id,
    required this.title,
    required this.url,
    required this.isActive,
    this.coverUrl,
    this.description,
    this.demoPrice,
    this.login,
    this.password,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final String url;
  final bool isActive;

  /// Relative path served under `/public/`, e.g. `courses/uuid.jpg`.
  final String? coverUrl;
  final String? description;

  /// Price for a 24-hour demo enrollment. Null = no demo available.
  final int? demoPrice;

  /// Per-enrollment credentials (from listMyCourses or requestDemo response).
  final String? login;
  final String? password;

  /// True when this enrollment is a demo (has demoPaymentId and short endDate).
  final bool isDemo;

  Course copyWith({String? login, String? password}) => Course(
    id: id,
    title: title,
    url: url,
    isActive: isActive,
    coverUrl: coverUrl,
    description: description,
    demoPrice: demoPrice,
    login: login ?? this.login,
    password: password ?? this.password,
    isDemo: isDemo,
  );

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      demoPrice: (json['demoPrice'] as num?)?.toInt(),
      login: json['login'] as String?,
      password: json['password'] as String?,
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }
}

class DemoEnrollment {
  const DemoEnrollment({required this.login, required this.password});

  final String? login;
  final String? password;

  factory DemoEnrollment.fromJson(Map<String, dynamic> json) {
    return DemoEnrollment(
      login: json['login'] as String?,
      password: json['password'] as String?,
    );
  }
}
