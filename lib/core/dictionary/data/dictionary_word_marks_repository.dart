import 'dart:convert';

import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dictionaryWordMarksRepositoryProvider =
    Provider.family<DictionaryWordMarksRepository, DictionaryMarkKind>((
      ref,
      kind,
    ) {
      return DictionaryWordMarksRepository(
        ref.watch(cacheServiceProvider),
        kind.storageKey,
      );
    });

class DictionaryWordMarksRepository {
  DictionaryWordMarksRepository(this._cache, this._storageKey);

  final CacheService _cache;
  final String _storageKey;

  List<DictionaryWordMark> load() {
    final raw = _cache.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((e) => DictionaryWordMark.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<DictionaryWordMark>> add(DictionaryWordMark mark) async {
    final current = load();
    if (current.any((m) => m.key == mark.key)) return current;
    final updated = [...current, mark];
    await _save(updated);
    return updated;
  }

  Future<List<DictionaryWordMark>> remove(String key) async {
    final updated = load().where((m) => m.key != key).toList();
    await _save(updated);
    return updated;
  }

  Future<void> _save(List<DictionaryWordMark> marks) {
    final raw = jsonEncode(marks.map((m) => m.toJson()).toList());
    return _cache.setString(_storageKey, raw);
  }
}
