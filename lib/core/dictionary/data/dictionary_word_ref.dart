import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';

/// A dictionary entry paired with the direction it was looked up in, since
/// the same word text can exist independently in both bundled dictionaries.
class DictionaryWordRef {
  const DictionaryWordRef({required this.entry, required this.direction});

  final DictionaryEntry entry;
  final DictionaryDirection direction;
}
