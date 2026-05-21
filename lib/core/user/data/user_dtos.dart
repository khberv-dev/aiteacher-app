class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.avatar,
    this.activeSubscription,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? avatar;
  final ActiveSubscription? activeSubscription;

  String get fullName => '$firstName $lastName'.trim();

  String get initial =>
      firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : '?';

  factory User.fromJson(Map<String, dynamic> json) {
    final sub = json['activeSubscription'];
    return User(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      activeSubscription: sub is Map<String, dynamic>
          ? ActiveSubscription.fromJson(sub)
          : null,
    );
  }
}

class ActiveSubscription {
  const ActiveSubscription({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      id: json['id'] as String? ?? '',
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
