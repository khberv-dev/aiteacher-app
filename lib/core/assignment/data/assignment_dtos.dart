class Assignment {
  const Assignment({
    required this.id,
    required this.chatRoomId,
    required this.mentor,
    required this.student,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String chatRoomId;
  final AssignmentParticipant mentor;
  final AssignmentParticipant student;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Returns the user id of the other party (the one that isn't the caller).
  String peerUserId(String currentUserId) =>
      mentor.userId == currentUserId ? student.userId : mentor.userId;

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String? ?? '',
      chatRoomId: json['chatRoomId'] as String? ?? '',
      mentor: AssignmentParticipant.fromJson(
        (json['mentor'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      student: AssignmentParticipant.fromJson(
        (json['student'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// A mentor or student record nested inside an [Assignment]. Carries the
/// participant record id plus its embedded user.
class AssignmentParticipant {
  const AssignmentParticipant({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.phoneNumber,
    this.email,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? phoneNumber;
  final String? email;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }

  factory AssignmentParticipant.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AssignmentParticipant(
      id: json['id'] as String? ?? '',
      userId: user['id'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      avatar: user['avatar'] as String?,
      phoneNumber: user['phoneNumber'] as String?,
      email: user['email'] as String?,
    );
  }
}

/// The student's currently assigned mentor, as returned by
/// `GET assignments/my-mentor`. `null` means no mentor is assigned yet.
class MyMentor {
  const MyMentor({
    required this.assignmentId,
    required this.chatRoomId,
    required this.status,
    required this.startDate,
    required this.isOnline,
    required this.mentor,
    this.endDate,
    this.progress,
  });

  final String assignmentId;
  final String? chatRoomId;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final double? progress;
  final bool isOnline;
  final MentorProfile mentor;

  factory MyMentor.fromJson(Map<String, dynamic> json) {
    return MyMentor(
      assignmentId: json['assignmentId'] as String? ?? '',
      chatRoomId: json['chatRoomId'] as String?,
      status: json['status'] as String? ?? '',
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: json['endDate'] is String
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble(),
      isOnline: json['isOnline'] as bool? ?? false,
      mentor: MentorProfile.fromJson(
        (json['mentor'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

/// Flat mentor profile shape used by `GET assignments/my-mentor` — distinct
/// from [AssignmentParticipant], which is nested under a `user` object in
/// the general assignment-list endpoint.
class MentorProfile {
  const MentorProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.avatar,
    this.phoneNumber,
    this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? avatar;
  final String? phoneNumber;
  final String? email;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }

  factory MentorProfile.fromJson(Map<String, dynamic> json) {
    return MentorProfile(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );
  }
}
