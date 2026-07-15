class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.definition,
    this.phonetic = '',
  });

  final String word;
  final String definition;
  final String phonetic;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
    );
  }
}

enum DictionaryDirection {
  enToUz('assets/dictionary/en-uz.json', 'EN → UZ'),
  uzToEn('assets/dictionary/uz-en.json', 'UZ → EN');

  const DictionaryDirection(this.assetPath, this.label);

  final String assetPath;
  final String label;
}
