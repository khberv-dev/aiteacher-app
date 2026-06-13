enum PromoType { screen, sheet, modal }

class PromoEvent {
  const PromoEvent({
    required this.id,
    required this.url,
    required this.type,
    required this.trigger,
  });

  final String id;
  final String url;
  final PromoType type;
  final String trigger;

  factory PromoEvent.fromJson(Map<String, dynamic> json) {
    return PromoEvent(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? ''),
      trigger: json['trigger'] as String? ?? '',
    );
  }

  static PromoType _parseType(String value) {
    return switch (value) {
      'screen' => PromoType.screen,
      'sheet' => PromoType.sheet,
      _ => PromoType.modal,
    };
  }
}
