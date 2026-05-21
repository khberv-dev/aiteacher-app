class PlanPrice {
  const PlanPrice({
    required this.month,
    required this.price,
    required this.actualPrice,
  });

  final int month;
  final num price;
  final num actualPrice;

  bool get hasDiscount => actualPrice > price;

  factory PlanPrice.fromJson(Map<String, dynamic> json) {
    return PlanPrice(
      month: (json['month'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?) ?? 0,
      actualPrice: (json['actualPrice'] as num?) ?? 0,
    );
  }
}

class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.isActive,
    required this.hasMentor,
    required this.prices,
    required this.availableFeatures,
    required this.notAvailableFeatures,
  });

  final String id;
  final String name;
  final bool isActive;
  final bool hasMentor;
  final List<PlanPrice> prices;
  final List<String> availableFeatures;
  final List<String> notAvailableFeatures;

  factory Plan.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'];
    final rawAvailable = json['availableFeatures'];
    final rawUnavailable = json['notAvailableFeatures'];
    return Plan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      hasMentor: json['hasMentor'] as bool? ?? false,
      prices: rawPrices is List
          ? rawPrices
                .whereType<Map>()
                .map((e) => PlanPrice.fromJson(e.cast<String, dynamic>()))
                .toList(growable: false)
          : const [],
      availableFeatures: rawAvailable is List
          ? rawAvailable.whereType<String>().toList(growable: false)
          : const [],
      notAvailableFeatures: rawUnavailable is List
          ? rawUnavailable.whereType<String>().toList(growable: false)
          : const [],
    );
  }
}
