import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';

/// Exact matches first, then substring matches, both ordered by first
/// appearance in [entries].
List<DictionaryEntry> searchDictionaryEntries(
  List<DictionaryEntry> entries,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final exact = <DictionaryEntry>[];
  final partial = <DictionaryEntry>[];
  for (final entry in entries) {
    final word = entry.word.toLowerCase();
    if (word == q) {
      exact.add(entry);
    } else if (word.contains(q)) {
      partial.add(entry);
    }
  }
  return [...exact, ...partial];
}
