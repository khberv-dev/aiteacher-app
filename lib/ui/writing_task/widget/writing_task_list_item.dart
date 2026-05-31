import 'package:ai_teacher/core/writing_task/data/writing_task_dtos.dart';
import 'package:flutter/material.dart';

class WritingTaskListItem extends StatelessWidget {
  const WritingTaskListItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  final WritingTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _StatusDot(status: task.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.theme.isEmpty ? 'Yozish vazifasi' : task.theme,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusChip(status: task.status),
                          if (task.status == WritingTaskStatus.completed) ...[
                            const SizedBox(width: 6),
                            _ScoreRow(
                              translationScore: task.translationScore,
                              backTranslationScore: task.backTranslationScore,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(task.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Bugun';
    if (diff.inDays == 1) return 'Kecha';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final WritingTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      WritingTaskStatus.completed => const Color(0xFF059669),
      WritingTaskStatus.pendingBackTranslation => const Color(0xFFD97706),
      WritingTaskStatus.pendingTranslation => const Color(0xFF3B82F6),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        switch (status) {
          WritingTaskStatus.completed => Icons.check_rounded,
          _ => Icons.edit_note_rounded,
        },
        size: 20,
        color: color,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final WritingTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WritingTaskStatus.completed => ('Bajarildi', const Color(0xFF059669)),
      WritingTaskStatus.pendingBackTranslation =>
        ('2-bosqich', const Color(0xFFD97706)),
      WritingTaskStatus.pendingTranslation =>
        ('1-bosqich', const Color(0xFF3B82F6)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.translationScore,
    required this.backTranslationScore,
  });

  final int? translationScore;
  final int? backTranslationScore;

  @override
  Widget build(BuildContext context) {
    if (translationScore == null && backTranslationScore == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        if (translationScore != null)
          Text(
            'T: $translationScore',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (translationScore != null && backTranslationScore != null)
          const Text(
            ' · ',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
          ),
        if (backTranslationScore != null)
          Text(
            'Q: $backTranslationScore',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
