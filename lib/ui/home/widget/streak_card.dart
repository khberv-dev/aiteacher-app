import 'package:ai_teacher/core/streak/data/streak_dtos.dart';
import 'package:ai_teacher/core/streak/presentation/streak_controller.dart';
import 'package:ai_teacher/ui/streak/streak_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(weeklyStreakProvider);
    final streak = streakAsync.valueOrNull ?? WeeklyStreak.empty;
    final days = streak.week;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Material(
        color: const Color(0xFFF5B700),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => StreakSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFF5B700),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5B700).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🔥 ${streak.currentStreak} kunlik seriya!',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      streak.daysLeftThisWeek > 0
                          ? '${streak.daysLeftThisWeek} kun qoldi'
                          : 'Hafta yopildi',
                      style: const TextStyle(
                        color: Color(0xB3000000),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (days.isEmpty)
                  const _PlaceholderRow()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in days) _DayCell(day: day),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final StreakDay day;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(day.date.toLocal(), DateTime.now());
    final fg = day.active ? const Color(0xFFFEF3C7) : const Color(0xFFF5F5F5);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFFDE68A) : fg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: const Color(0xFFF5B700).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: day.active
              ? const Text('🔥', style: TextStyle(fontSize: 18))
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          day.weekday.shortLabelUz,
          style: TextStyle(
            color: isToday
                ? const Color(0xFF1A1A1A)
                : const Color(0xB3000000),
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '·',
                style: TextStyle(
                  color: Color(0xB3000000),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
