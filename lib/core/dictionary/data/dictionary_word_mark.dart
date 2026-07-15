import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';

/// The two kinds of local, user-generated marks a dictionary word can carry.
/// Each is persisted under its own storage key so a word can be saved and
/// learned independently.
enum DictionaryMarkKind { saved, learned }

extension DictionaryMarkKindX on DictionaryMarkKind {
  String get storageKey => switch (this) {
    DictionaryMarkKind.saved => 'dictionary_favorites',
    DictionaryMarkKind.learned => 'dictionary_learned',
  };
}

String markKeyFor(
  DictionaryDirection direction,
  String word,
  String definition,
) => '${direction.name}|$word|$definition';

class DictionaryWordMark {
  const DictionaryWordMark({
    required this.direction,
    required this.word,
    required this.definition,
    required this.markedAt,
  });

  final DictionaryDirection direction;
  final String word;
  final String definition;
  final DateTime markedAt;

  String get key => markKeyFor(direction, word, definition);

  Map<String, dynamic> toJson() => {
    'direction': direction.name,
    'word': word,
    'definition': definition,
    'markedAt': markedAt.toIso8601String(),
  };

  factory DictionaryWordMark.fromJson(Map<String, dynamic> json) {
    return DictionaryWordMark(
      direction: DictionaryDirection.values.firstWhere(
        (d) => d.name == json['direction'],
        orElse: () => DictionaryDirection.enToUz,
      ),
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      markedAt:
          DateTime.tryParse(json['markedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
