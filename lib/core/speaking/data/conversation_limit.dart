class ConversationLimit {
  const ConversationLimit({
    required this.used,
    required this.baseLimit,
    required this.addonExtra,
    required this.effectiveLimit,
    required this.remaining,
    required this.isUnlimited,
    required this.addonPrice,
    required this.addonGrant,
  });

  final int used;
  final int baseLimit;
  final int addonExtra;
  final int effectiveLimit;
  final int remaining;
  final bool isUnlimited;
  final int addonPrice;
  final int addonGrant;

  factory ConversationLimit.fromJson(Map<String, dynamic> json) {
    return ConversationLimit(
      used: (json['used'] as num?)?.toInt() ?? 0,
      baseLimit: (json['baseLimit'] as num?)?.toInt() ?? 3,
      addonExtra: (json['addonExtra'] as num?)?.toInt() ?? 0,
      effectiveLimit: (json['effectiveLimit'] as num?)?.toInt() ?? 3,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      isUnlimited: json['isUnlimited'] as bool? ?? false,
      addonPrice: (json['addonPrice'] as num?)?.toInt() ?? 5000,
      addonGrant: (json['addonGrant'] as num?)?.toInt() ?? 3,
    );
  }
}
