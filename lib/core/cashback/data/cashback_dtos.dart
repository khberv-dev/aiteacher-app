enum CashbackType {
  register,
  referral,
  payment,
  referralPayment,
  streak;

  static CashbackType fromApi(String? raw) => switch (raw) {
    'referral' => CashbackType.referral,
    'payment' => CashbackType.payment,
    'referral_payment' => CashbackType.referralPayment,
    'streak' => CashbackType.streak,
    _ => CashbackType.register,
  };

  String get sourceLabelUz => switch (this) {
    CashbackType.register => "Ro'yxatdan o'tganingiz uchun",
    CashbackType.referral => "Do'st referal kodi orqali keldi",
    CashbackType.payment => "Sizning to'lovingiz uchun",
    CashbackType.referralPayment => "Do'stingiz to'lovi uchun",
    CashbackType.streak => "Streak seriyasi uchun",
  };
}

class Cashback {
  const Cashback({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.claimed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final CashbackType type;
  final int amount;
  final bool claimed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Cashback.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic v) => v is String
        ? (DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);
    return Cashback(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: CashbackType.fromApi(json['type'] as String?),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      claimed: json['claimed'] as bool? ?? false,
      createdAt: parse(json['createdAt']),
      updatedAt: parse(json['updatedAt']),
    );
  }
}

class CashbackSummary {
  const CashbackSummary({required this.total, required this.unclaimed});

  final int total;
  final int unclaimed;

  static const CashbackSummary zero = CashbackSummary(total: 0, unclaimed: 0);

  factory CashbackSummary.fromJson(Map<String, dynamic> json) {
    return CashbackSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      unclaimed: (json['unclaimed'] as num?)?.toInt() ?? 0,
    );
  }
}
