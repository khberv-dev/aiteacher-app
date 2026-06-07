import 'package:ai_teacher/core/notification/data/notification_dtos.dart';
import 'package:ai_teacher/core/notification/data/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final unreadCountProvider = FutureProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).unreadCount();
});

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsNotifier,
      List<UserNotification>
    >(NotificationsNotifier.new);

class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<UserNotification>> {
  @override
  Future<List<UserNotification>> build() {
    return ref.watch(notificationRepositoryProvider).list();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull ?? [];
    // Optimistic update
    state = AsyncData(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
    } catch (_) {
      // Revert on failure
      state = AsyncData(current);
      rethrow;
    } finally {
      ref.invalidate(unreadCountProvider);
    }
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    } finally {
      ref.invalidate(unreadCountProvider);
    }
  }
}
