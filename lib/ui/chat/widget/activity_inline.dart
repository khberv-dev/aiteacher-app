import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/ui/chat/chat_data.dart';
import 'package:flutter/material.dart';

class CallResultRow extends StatelessWidget {
  const CallResultRow({super.key, required this.result});

  final CallResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          result.label,
          style: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          result.note,
          style: const TextStyle(
            color: Color(0xFFBBBBBB),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class TaskCheckRow extends StatelessWidget {
  const TaskCheckRow({super.key, required this.task});

  final TaskAction task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0F000000), width: 1)),
      ),
      child: Row(
        children: [
          _Checkbox(checked: task.completed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.label,
              style: TextStyle(
                color: task.completed
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFF555555),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: checked ? null : Border.all(color: AppColors.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: checked
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
          : null,
    );
  }
}
