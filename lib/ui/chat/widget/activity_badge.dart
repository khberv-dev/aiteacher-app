import 'package:ai_teacher/ui/chat/chat_data.dart';
import 'package:flutter/material.dart';

class ActivityBadge extends StatelessWidget {
  const ActivityBadge({super.key, required this.type});

  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    final style = kActivityTypeStyles[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.badgeBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.badgeForeground, size: 9),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: style.badgeForeground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
