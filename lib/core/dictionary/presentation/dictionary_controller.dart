import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_favorites_repository.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_repository.dart';
import 'package:ai_teacher/core/dictionary/data/favorite_word.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DictionaryTab {
  enToUz(DictionaryDirection.enToUz, 'EN → UZ'),
  uzToEn(DictionaryDirection.uzToEn, 'UZ → EN'),
  favorites(null, 'Sevimlilar');

  const DictionaryTab(this.direction, this.label);

  final DictionaryDirection? direction;
  final String label;
}

class DictionaryListItem {
  const DictionaryListItem({required this.entry, required this.direction});

  final DictionaryEntry entry;
  final DictionaryDirection direction;

  String get favoriteKey =>
      favoriteKeyFor(direction, entry.word, entry.definition);
}

class DictionaryState {
  const DictionaryState({
    required this.tab,
    required this.enToUzEntries,
    required this.uzToEnEntries,
    required this.favorites,
    this.query = '',
  });

  final DictionaryTab tab;
  final List<DictionaryEntry> enToUzEntries;
  final List<DictionaryEntry> uzToEnEntries;
  final List<FavoriteWord> favorites;
  final String query;

  Set<String> get favoriteKeys => favorites.map((f) => f.key).toSet();

  bool isFavorite(DictionaryListItem item) =>
      favoriteKeys.contains(item.favoriteKey);

  bool hasEntries(DictionaryTab tab) => switch (tab) {
    DictionaryTab.enToUz => enToUzEntries.isNotEmpty,
    DictionaryTab.uzToEn => uzToEnEntries.isNotEmpty,
    DictionaryTab.favorites => favorites.isNotEmpty,
  };

  List<DictionaryListItem> itemsFor(DictionaryTab tab) {
    final q = query.toLowerCase();
    switch (tab) {
      case DictionaryTab.enToUz:
        return _filterEntries(enToUzEntries, DictionaryDirection.enToUz, q);
      case DictionaryTab.uzToEn:
        return _filterEntries(uzToEnEntries, DictionaryDirection.uzToEn, q);
      case DictionaryTab.favorites:
        return _filterFavorites(favorites, q);
    }
  }

  static List<DictionaryListItem> _filterEntries(
    List<DictionaryEntry> entries,
    DictionaryDirection direction,
    String query,
  ) {
    final matches = query.isEmpty
        ? entries
        : entries.where((e) => e.word.toLowerCase().contains(query));
    return matches
        .map((e) => DictionaryListItem(entry: e, direction: direction))
        .toList(growable: false);
  }

  static List<DictionaryListItem> _filterFavorites(
    List<FavoriteWord> favorites,
    String query,
  ) {
    final matches = query.isEmpty
        ? favorites
        : favorites.where((f) => f.word.toLowerCase().contains(query));
    return matches
        .map(
          (f) => DictionaryListItem(
            entry: DictionaryEntry(word: f.word, definition: f.definition),
            direction: f.direction,
          ),
        )
        .toList(growable: false);
  }

  DictionaryState copyWith({
    DictionaryTab? tab,
    List<DictionaryEntry>? enToUzEntries,
    List<DictionaryEntry>? uzToEnEntries,
    List<FavoriteWord>? favorites,
    String? query,
  }) {
    return DictionaryState(
      tab: tab ?? this.tab,
      enToUzEntries: enToUzEntries ?? this.enToUzEntries,
      uzToEnEntries: uzToEnEntries ?? this.uzToEnEntries,
      favorites: favorites ?? this.favorites,
      query: query ?? this.query,
    );
  }
}

class DictionaryController extends AutoDisposeAsyncNotifier<DictionaryState> {
  @override
  Future<DictionaryState> build() async {
    final entries = await ref
        .read(dictionaryRepositoryProvider)
        .load(DictionaryDirection.enToUz);
    final favorites = ref.read(dictionaryFavoritesRepositoryProvider).load();
    return DictionaryState(
      tab: DictionaryTab.enToUz,
      enToUzEntries: entries,
      uzToEnEntries: const [],
      favorites: favorites,
    );
  }

  Future<void> switchTab(DictionaryTab tab) async {
    final current = state.valueOrNull;
    if (current == null || current.tab == tab) return;

    final alreadyLoaded =
        tab != DictionaryTab.uzToEn || current.uzToEnEntries.isNotEmpty;
    if (alreadyLoaded) {
      state = AsyncData(current.copyWith(tab: tab, query: ''));
      return;
    }

    state = const AsyncLoading<DictionaryState>().copyWithPrevious(state);
    final entries = await ref
        .read(dictionaryRepositoryProvider)
        .load(DictionaryDirection.uzToEn);
    state = AsyncData(
      current.copyWith(tab: tab, uzToEnEntries: entries, query: ''),
    );
  }

  void search(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: query));
  }

  Future<void> toggleFavorite(DictionaryListItem item) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repo = ref.read(dictionaryFavoritesRepositoryProvider);
    final favorite = FavoriteWord(
      direction: item.direction,
      word: item.entry.word,
      definition: item.entry.definition,
    );
    final updated = current.isFavorite(item)
        ? await repo.remove(favorite.key)
        : await repo.add(favorite);
    state = AsyncData(current.copyWith(favorites: updated));
  }
}

final dictionaryControllerProvider =
    AutoDisposeAsyncNotifierProvider<DictionaryController, DictionaryState>(
      DictionaryController.new,
    );
