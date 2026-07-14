class DictionaryEntry {
  const DictionaryEntry({required this.word, required this.definition});

  final String word;
  final String definition;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
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
