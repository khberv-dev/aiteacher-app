/// Lifecycle a vocabulary word goes through as the learner practises it.
/// Mirrors the API's lowercase enum strings.
enum WordStatus {
  newWord('new'),
  learning('learning'),
  mastered('mastered');

  const WordStatus(this.api);

  /// Wire value used by the API.
  final String api;

  static WordStatus fromApi(String? raw) {
    switch (raw) {
      case 'learning':
        return WordStatus.learning;
      case 'mastered':
        return WordStatus.mastered;
      case 'new':
      default:
        return WordStatus.newWord;
    }
  }

  String get labelUz => switch (this) {
    WordStatus.newWord => 'Yangi',
    WordStatus.learning => "O'rganilmoqda",
    WordStatus.mastered => "O'rganilgan",
  };
}
