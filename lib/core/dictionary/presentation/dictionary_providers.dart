import 'dart:math';

import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_repository.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_marks_repository.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dictionaryEntriesProvider =
    FutureProvider.family<List<DictionaryEntry>, DictionaryDirection>((
      ref,
      direction,
    ) {
      return ref.watch(dictionaryRepositoryProvider).load(direction);
    });

/// Shared "current lookup direction" so the toggle sticks as the user moves
/// between the search and explanatory-dictionary screens.
final dictionaryDirectionProvider = StateProvider<DictionaryDirection>(
  (ref) => DictionaryDirection.enToUz,
);

/// A handful of words picked deterministically for the day so the list is
/// stable on every visit but changes tomorrow.
final dictionaryDailyWordsProvider = FutureProvider<List<DictionaryEntry>>((
  ref,
) async {
  final entries = await ref.watch(
    dictionaryEntriesProvider(DictionaryDirection.enToUz).future,
  );
  if (entries.isEmpty) return const [];

  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final rng = Random(seed);
  final count = entries.length < 3 ? entries.length : 3;
  final indices = <int>{};
  while (indices.length < count) {
    indices.add(rng.nextInt(entries.length));
  }
  return indices.map((i) => entries[i]).toList(growable: false);
});

class DictionaryMarksController
    extends
        AutoDisposeFamilyAsyncNotifier<
          List<DictionaryWordMark>,
          DictionaryMarkKind
        > {
  @override
  Future<List<DictionaryWordMark>> build(DictionaryMarkKind kind) async {
    return ref.read(dictionaryWordMarksRepositoryProvider(kind)).load();
  }

  bool isMarked(DictionaryWordRef wordRef) {
    final marks = state.valueOrNull ?? const [];
    final key = markKeyFor(
      wordRef.direction,
      wordRef.entry.word,
      wordRef.entry.definition,
    );
    return marks.any((m) => m.key == key);
  }

  Future<void> toggle(DictionaryWordRef wordRef) async {
    final repo = ref.read(dictionaryWordMarksRepositoryProvider(arg));
    final mark = DictionaryWordMark(
      direction: wordRef.direction,
      word: wordRef.entry.word,
      definition: wordRef.entry.definition,
      markedAt: DateTime.now(),
    );
    final current = state.valueOrNull ?? const [];
    final updated = current.any((m) => m.key == mark.key)
        ? await repo.remove(mark.key)
        : await repo.add(mark);
    state = AsyncData(updated);
  }
}

final dictionaryMarksControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      DictionaryMarksController,
      List<DictionaryWordMark>,
      DictionaryMarkKind
    >(DictionaryMarksController.new);
