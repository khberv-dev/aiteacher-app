import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:flutter/material.dart';

class ReportVocabHero extends StatelessWidget {
  const ReportVocabHero({super.key, required this.detail});

  final VocabularyDetail detail;

  String _formatThousands(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final progress = detail.nextLevel.targetSize == 0
        ? 0.0
        : (detail.activeSizeEstimate / detail.nextLevel.targetSize).clamp(
            0.0,
            1.0,
          );
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LUG'AT HAJMI",
              style: TextStyle(
                color: Color(0x4DFFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatThousands(detail.activeSizeEstimate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    "so'z",
                    style: TextStyle(
                      color: Color(0x4DFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Faol lug'at hajmingiz (taxminiy)",
              style: TextStyle(
                color: Color(0x59FFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _CompareTile(
                    label: 'A2 DARAJA',
                    value: '1,500 ✓',
                    valueColor: Color(0xFF4ADE80),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _CompareTile(
                    label: 'B1 DARAJA',
                    value: '3,000 ✓',
                    valueColor: Color(0xFFF5B700),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _CompareTile(
                    label: 'B2 MAQSAD',
                    value: '6,000 ↑',
                    valueColor: Color(0xFF93C5FD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${detail.nextLevel.level} GA: '
                  '${_formatThousands(detail.activeSizeEstimate)} / '
                  "${_formatThousands(detail.nextLevel.targetSize)} SO'Z",
                  style: const TextStyle(
                    color: Color(0x4DFFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 5,
                color: Colors.white.withValues(alpha: 0.06),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF7C3AED), Color(0xFFC084FC)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareTile extends StatelessWidget {
  const _CompareTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x4DFFFFFF),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
