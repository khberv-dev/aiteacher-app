import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/assignment/data/assignment_dtos.dart';
import 'package:ai_teacher/core/assignment/presentation/my_assignments_controller.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/chat/chat_list_data.dart';
import 'package:ai_teacher/ui/chat/widget/chat_list_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(myAssignmentsProvider);
    final currentUserId = ref.watch(currentUserProvider).valueOrNull?.id;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const _Header(),
          Expanded(
            child: assignments.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
              error: (_, _) =>
                  const _Empty(text: "Suhbatlarni yuklab bo'lmadi"),
              data: (items) {
                if (items.isEmpty || currentUserId == null) {
                  return const _Empty(text: "Hozircha suhbatlar yo'q");
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final chat = _toChatListItem(items[index], currentUserId);
                    return ChatListItemView(
                      item: chat,
                      onTap: () =>
                          context.pushNamed(AppRoute.chat.name, extra: chat),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

ChatListItem _toChatListItem(Assignment a, String currentUserId) {
  final peerId = a.peerUserId(currentUserId);
  final mentorName = a.mentor.fullName.isEmpty ? 'Mentor' : a.mentor.fullName;
  return ChatListItem(
    id: a.chatRoomId,
    peerId: peerId,
    name: mentorName,
    initials: a.mentor.initials,
    avatarColors: _avatarColorsFor(a.mentor.userId),
    lastMessage: '',
    time: _formatTime(a.updatedAt),
  );
}

List<Color> _avatarColorsFor(String id) {
  const palette = <List<Color>>[
    [Color(0xFF0D9488), Color(0xFF059669)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFF472B6), Color(0xFFEC4899)],
    [Color(0xFF64748B), Color(0xFF334155)],
  ];
  if (id.isEmpty) return palette.first;
  final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
  return palette[hash % palette.length];
}

String _formatTime(DateTime ts) {
  final now = DateTime.now();
  final sameDay =
      ts.year == now.year && ts.month == now.month && ts.day == now.day;
  if (sameDay) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday =
      ts.year == yesterday.year &&
      ts.month == yesterday.month &&
      ts.day == yesterday.day;
  if (isYesterday) return 'Kecha';
  return '${ts.day}-${_monthShort(ts.month)}';
}

const _monthsShort = [
  'yan',
  'fev',
  'mar',
  'apr',
  'may',
  'iyun',
  'iyul',
  'avg',
  'sen',
  'okt',
  'noy',
  'dek',
];

String _monthShort(int month) =>
    (month >= 1 && month <= 12) ? _monthsShort[month - 1] : '';

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x0F000000), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: const Text(
        'Chats',
        style: TextStyle(
          color: Color(0xFF111111),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8580),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}
