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
