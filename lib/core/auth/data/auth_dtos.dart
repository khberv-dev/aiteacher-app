class OtpRequestResult {
  const OtpRequestResult({required this.phoneNumber, required this.expiresAt});

  final String phoneNumber;
  final DateTime expiresAt;

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}

class OtpVerifyResult {
  const OtpVerifyResult({required this.verificationToken});

  final String verificationToken;

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResult(
      verificationToken: json['verificationToken'] as String? ?? '',
    );
  }
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}

class RegistrationDraft {
  const RegistrationDraft({
    required this.firstName,
    required this.lastName,
    required this.password,
    this.phoneNumber,
    this.email,
    this.goal,
    this.level,
    this.dailyTime,
  });

  final String firstName;
  final String lastName;
  final String password;
  final String? phoneNumber;
  final String? email;
  final String? goal;
  final String? level;
  final String? dailyTime;
}
