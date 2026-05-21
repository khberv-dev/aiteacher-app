import 'package:ai_teacher/ui/chat/chat_data.dart';
import 'package:ai_teacher/ui/chat/widget/activity_avatar.dart';
import 'package:ai_teacher/ui/chat/widget/activity_badge.dart';
import 'package:ai_teacher/ui/chat/widget/activity_inline.dart';
import 'package:flutter/material.dart';

class ActivityItemView extends StatelessWidget {
  const ActivityItemView({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final style = kActivityTypeStyles[item.type]!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActivityAvatar(initials: item.initials, colors: item.avatarColors),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ActivityBadge(type: item.type),
                  const Spacer(),
                  Text(
                    item.time,
                    style: const TextStyle(
                      color: Color(0xFFBBBBBB),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: style.bubbleBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(color: style.bubbleBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.body,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                      ),
                    ),
                    if (item.callResult != null) ...[
                      const SizedBox(height: 6),
                      CallResultRow(result: item.callResult!),
                    ],
                    if (item.task != null) ...[
                      const SizedBox(height: 8),
                      TaskCheckRow(task: item.task!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
