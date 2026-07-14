import 'dart:convert';

import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
});

class DictionaryRepository {
  final Map<DictionaryDirection, List<DictionaryEntry>> _cache = {};

  Future<List<DictionaryEntry>> load(DictionaryDirection direction) async {
    final cached = _cache[direction];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(direction.assetPath);
    final entries = await compute(_parseEntries, raw);
    _cache[direction] = entries;
    return entries;
  }
}

List<DictionaryEntry> _parseEntries(String raw) {
  final decoded = jsonDecode(raw) as List<dynamic>;
  final entries = decoded
      .whereType<Map>()
      .map((e) => DictionaryEntry.fromJson(e.cast<String, dynamic>()))
      .toList();
  entries.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
  return entries;
}
