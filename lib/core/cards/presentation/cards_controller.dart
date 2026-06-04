import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:ai_teacher/core/cards/data/card_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardsController extends AutoDisposeAsyncNotifier<List<UserCard>> {
  @override
  Future<List<UserCard>> build() {
    return ref.read(cardRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cardRepositoryProvider).list(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(cardRepositoryProvider).remove(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((c) => c.id != id).toList());
  }
}

final cardsControllerProvider =
    AutoDisposeAsyncNotifierProvider<CardsController, List<UserCard>>(
      CardsController.new,
    );
