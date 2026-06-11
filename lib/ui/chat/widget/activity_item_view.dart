import 'package:ai_teacher/ui/chat/chat_data.dart';
import 'package:ai_teacher/ui/chat/widget/activity_avatar.dart';
import 'package:flutter/material.dart';

class ActivityItemView extends StatelessWidget {
  const ActivityItemView({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return item.mine ? _MineBubble(item: item) : _TheirBubble(item: item);
  }
}

class _TheirBubble extends StatelessWidget {
  const _TheirBubble({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActivityAvatar(initials: item.initials, colors: item.avatarColors),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.authorName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _RoleChip(label: item.role),
                ],
              ),
              const SizedBox(height: 5),
              _Bubble(body: item.body, time: item.time, mine: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _MineBubble extends StatelessWidget {
  const _MineBubble({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: _Bubble(body: item.body, time: item.time, mine: true),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.body, required this.time, required this.mine});

  final String body;
  final String time;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
      decoration: BoxDecoration(
        color: mine ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: Radius.circular(mine ? 4 : 14),
          bottomLeft: const Radius.circular(14),
          bottomRight: const Radius.circular(14),
        ),
        border: mine
            ? null
            : Border.all(color: const Color(0x0D000000), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: TextStyle(
                color: mine ? Colors.white : const Color(0xFF333333),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: mine
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFFBBBBBB),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (label) {
      'Mentor' => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      'Admin' => (const Color(0xFFEDE9FE), const Color(0xFF6D28D9)),
      _ => (const Color(0xFFF1F5F9), const Color(0xFF64748B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
