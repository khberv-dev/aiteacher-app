class UserCard {
  const UserCard({
    required this.id,
    required this.cardNumber,
    required this.expireDate,
    required this.createdAt,
  });

  final String id;
  final String cardNumber; // 16 digits
  final String expireDate; // YYMM
  final DateTime createdAt;

  String get lastFour =>
      cardNumber.length >= 4
          ? cardNumber.substring(cardNumber.length - 4)
          : cardNumber;

  String get maskedNumber => '**** **** **** $lastFour';

  /// Converts YYMM → MM/YY for display.
  String get displayExpiry {
    if (expireDate.length != 4) return expireDate;
    return '${expireDate.substring(2)}/${expireDate.substring(0, 2)}';
  }

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'] as String,
      cardNumber: json['cardNumber'] as String? ?? '',
      expireDate: json['expireDate'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class AddCardResult {
  const AddCardResult({required this.session, required this.otpSentPhone});

  final int session;
  final String otpSentPhone;

  factory AddCardResult.fromJson(Map<String, dynamic> json) {
    return AddCardResult(
      session: (json['session'] as num).toInt(),
      otpSentPhone: json['otpSentPhone'] as String? ?? '',
    );
  }
}
