enum WritingTaskStatus {
  pendingTranslation,
  pendingBackTranslation,
  completed;

  factory WritingTaskStatus.fromValue(String value) {
    return switch (value) {
      'pending_back_translation' => pendingBackTranslation,
      'completed' => completed,
      _ => pendingTranslation,
    };
  }
}

class WritingTask {
  const WritingTask({
    required this.id,
    required this.theme,
    required this.originText,
    required this.status,
    required this.createdAt,
    this.uzbekTranslation,
    this.translationFeedback,
    this.translationScore,
    this.backTranslation,
    this.backTranslationScore,
    this.backTranslationFeedback,
  });

  final String id;
  final String theme;
  final String originText;
  final WritingTaskStatus status;
  final DateTime createdAt;
  final String? uzbekTranslation;
  final String? translationFeedback;
  final int? translationScore;
  final String? backTranslation;
  final int? backTranslationScore;
  final String? backTranslationFeedback;

  factory WritingTask.fromJson(Map<String, dynamic> json) {
    return WritingTask(
      id: json['id'] as String,
      theme: json['theme'] as String? ?? '',
      originText: json['originText'] as String? ?? '',
      status: WritingTaskStatus.fromValue(json['status'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      uzbekTranslation: json['uzbekTranslation'] as String?,
      translationFeedback: json['translationFeedback'] as String?,
      translationScore: (json['translationScore'] as num?)?.toInt(),
      backTranslation: json['backTranslation'] as String?,
      backTranslationScore: (json['backTranslationScore'] as num?)?.toInt(),
      backTranslationFeedback: json['backTranslationFeedback'] as String?,
    );
  }
}
