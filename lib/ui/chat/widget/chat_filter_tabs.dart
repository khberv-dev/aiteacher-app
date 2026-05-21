import 'package:ai_teacher/ui/chat/chat_data.dart';
import 'package:flutter/material.dart';

class ChatFilterTabs extends StatelessWidget {
  const ChatFilterTabs({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          for (var i = 0; i < kFilterTabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _FilterChip(
              tab: kFilterTabs[i],
              active: i == activeIndex,
              onTap: () => onTap(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final FilterTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F172A) : const Color(0xFFEDEAE4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tab.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tab.label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
