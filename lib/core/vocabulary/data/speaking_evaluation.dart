/// AI-judged result of a learner pronouncing/using a vocabulary word.
/// Mirrors `POST /vocabulary/train/speaking` response shape.
class SpeakingEvaluation {
  const SpeakingEvaluation({
    required this.transcription,
    required this.correct,
    required this.score,
    required this.pronunciationFeedback,
    required this.usageFeedback,
    required this.suggestion,
  });

  final String transcription;
  final bool correct;
  final int score;
  final String pronunciationFeedback;
  final String usageFeedback;
  final String suggestion;

  factory SpeakingEvaluation.fromJson(Map<String, dynamic> json) {
    return SpeakingEvaluation(
      transcription: json['transcription'] as String? ?? '',
      correct: json['correct'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt() ?? 0,
      pronunciationFeedback: json['pronunciationFeedback'] as String? ?? '',
      usageFeedback: json['usageFeedback'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
    );
  }
}
