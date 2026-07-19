import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/notification/data/notification_dtos.dart';
import 'package:ai_teacher/core/notification/presentation/notifications_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/notifications/widget/notification_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationsProvider);
    final hasUnread = async.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text(
                l10n.notificationsMarkAllRead,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.notificationsLoadError,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: Color(0xFFCBD5E1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.notificationsEmptyState,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _NotificationItem(
                notification: items[i],
                onTap: () {
                  if (!items[i].isRead) {
                    ref
                        .read(notificationsProvider.notifier)
                        .markRead(items[i].id);
                  }
                  NotificationDetailSheet.show(context, items[i]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});

  final UserNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unread = !notification.isRead;
    final bgColor = unread ? const Color(0xFFFFFBEB) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: unread
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: unread
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    unread
                        ? Icons.notifications_rounded
                        : Icons.notifications_outlined,
                    size: 18,
                    color: unread ? AppColors.accent : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(notification.createdAt, l10n),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRect(
                        child: SizedBox(
                          height: 38,
                          child: AbsorbPointer(
                            child: MarkdownBody(
                              data: notification.body,
                              softLineBreak: true,
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                                strong: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _timeAgo(DateTime date, AppLocalizations l10n) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return l10n.notificationsTimeAgoNow;
  if (diff.inMinutes < 60) {
    return l10n.notificationsTimeAgoMinutes(diff.inMinutes);
  }
  if (diff.inHours < 24) return l10n.notificationsTimeAgoHours(diff.inHours);
  if (diff.inDays < 7) return l10n.notificationsTimeAgoDays(diff.inDays);
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return l10n.notificationsTimeAgoWeeks(weeks);
  final months = (diff.inDays / 30).floor();
  return l10n.notificationsTimeAgoMonths(months);
}
