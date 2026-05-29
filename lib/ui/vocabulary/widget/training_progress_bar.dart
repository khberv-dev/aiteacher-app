import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TrainingProgressBar extends StatelessWidget {
  const TrainingProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
    this.statsSummary,
  });

  final int currentIndex;
  final int total;

  /// Optional one-line summary of per-status totals shown beneath the bar.
  /// Null while the stats request is in-flight.
  final String? statsSummary;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : currentIndex / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              "${currentIndex + 1}/$total",
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (statsSummary != null)
              Text(
                statsSummary!,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.black.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
