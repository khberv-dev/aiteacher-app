import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';

String favoriteKeyFor(
  DictionaryDirection direction,
  String word,
  String definition,
) => '${direction.name}|$word|$definition';

class FavoriteWord {
  const FavoriteWord({
    required this.direction,
    required this.word,
    required this.definition,
  });

  final DictionaryDirection direction;
  final String word;
  final String definition;

  String get key => favoriteKeyFor(direction, word, definition);

  Map<String, dynamic> toJson() => {
    'direction': direction.name,
    'word': word,
    'definition': definition,
  };

  factory FavoriteWord.fromJson(Map<String, dynamic> json) {
    return FavoriteWord(
      direction: DictionaryDirection.values.firstWhere(
        (d) => d.name == json['direction'],
        orElse: () => DictionaryDirection.enToUz,
      ),
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
    );
  }
}
