enum PaymentStatus {
  created,
  success,
  failed,
  declined;

  static PaymentStatus fromApi(String? raw) {
    switch (raw) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'declined':
        return PaymentStatus.declined;
      default:
        return PaymentStatus.created;
    }
  }
}

class PaymentType {
  const PaymentType({
    required this.id,
    required this.title,
    this.icon,
    this.url,
  });

  final String id;
  final String title;
  final String? icon;
  final String? url;

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String?,
      url: json['url'] as String?,
    );
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.userId,
    required this.paymentTypeId,
    required this.amount,
    required this.status,
    this.type,
    this.payUrl,
  });

  final String id;
  final String userId;
  final String paymentTypeId;
  final num amount;
  final PaymentStatus status;
  final PaymentType? type;

  /// Provider checkout URL, returned only on the create response. The
  /// app should launch this to send the user to checkout.
  final String? payUrl;

  factory Payment.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'];
    return Payment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      paymentTypeId: json['paymentTypeId'] as String? ?? '',
      amount: (json['amount'] as num?) ?? 0,
      status: PaymentStatus.fromApi(json['status'] as String?),
      type: typeRaw is Map
          ? PaymentType.fromJson(typeRaw.cast<String, dynamic>())
          : null,
      payUrl: json['payUrl'] as String?,
    );
  }
}
