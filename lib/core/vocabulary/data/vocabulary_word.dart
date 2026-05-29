import 'package:ai_teacher/core/vocabulary/data/word_status.dart';

/// A vocabulary item the learner is collecting from their assessments.
/// `definition` and `exampleSentence` are populated lazily on the server
/// (the first time the word lands in a training batch).
class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.cefrLevel,
    required this.status,
    required this.correctCount,
    required this.incorrectCount,
    this.definition,
    this.exampleSentence,
    this.lastTrainedAt,
  });

  final String id;
  final String word;
  final String cefrLevel;
  final String? definition;
  final String? exampleSentence;
  final WordStatus status;
  final int correctCount;
  final int incorrectCount;
  final DateTime? lastTrainedAt;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
    return VocabularyWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      cefrLevel: json['cefrLevel'] as String? ?? '',
      definition: json['definition'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      status: WordStatus.fromApi(json['status'] as String?),
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      incorrectCount: (json['incorrectCount'] as num?)?.toInt() ?? 0,
      lastTrainedAt: parseDate(json['lastTrainedAt']),
    );
  }
}
