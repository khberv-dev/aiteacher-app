import 'dart:convert';

import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/core/dictionary/data/favorite_word.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dictionaryFavoritesRepositoryProvider =
    Provider<DictionaryFavoritesRepository>((ref) {
      return DictionaryFavoritesRepository(ref.watch(cacheServiceProvider));
    });

class DictionaryFavoritesRepository {
  DictionaryFavoritesRepository(this._cache);

  final CacheService _cache;

  static const _key = 'dictionary_favorites';

  List<FavoriteWord> load() {
    final raw = _cache.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((e) => FavoriteWord.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<FavoriteWord>> add(FavoriteWord favorite) async {
    final current = load();
    if (current.any((f) => f.key == favorite.key)) return current;
    final updated = [...current, favorite];
    await _save(updated);
    return updated;
  }

  Future<List<FavoriteWord>> remove(String key) async {
    final updated = load().where((f) => f.key != key).toList();
    await _save(updated);
    return updated;
  }

  Future<void> _save(List<FavoriteWord> favorites) {
    final raw = jsonEncode(favorites.map((f) => f.toJson()).toList());
    return _cache.setString(_key, raw);
  }
}
