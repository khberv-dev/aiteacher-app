import 'package:ai_teacher/core/streak/data/streak_dtos.dart';
import 'package:ai_teacher/core/streak/presentation/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class StreakSheet extends ConsumerWidget {
  const StreakSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const StreakSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(weeklyStreakProvider);
    final streak = streakAsync.valueOrNull ?? WeeklyStreak.empty;
    final isLoading = streakAsync.isLoading && streakAsync.valueOrNull == null;
    final hasError = streakAsync.hasError && streakAsync.valueOrNull == null;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DED7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Streak',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _CloseButton(
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : hasError
                    ? const _ErrorState()
                    : _StreakBody(streak: streak),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakBody extends StatelessWidget {
  const _StreakBody({required this.streak});

  final WeeklyStreak streak;

  @override
  Widget build(BuildContext context) {
    final days = streak.week;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Lottie.asset(
              'assets/lottie/flame_streak_1.json',
              width: 240,
              height: 240,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${streak.currentStreak} kunlik seriya 🔥",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _motivation(streak),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _StatRow(streak: streak),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Hafta',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (days.isEmpty)
            const SizedBox.shrink()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in days) _DayCell(day: day),
              ],
            ),
        ],
      ),
    );
  }

  String _motivation(WeeklyStreak streak) {
    if (streak.currentStreak == 0) {
      return "Bugun mashq qiling — yangi seriyani boshlang!";
    }
    if (streak.daysLeftThisWeek == 0) {
      return "Bu hafta a'lo darajada! Keyingi haftaga davom etamiz.";
    }
    return "Bu hafta yana ${streak.daysLeftThisWeek} kun qoldi. Davom eting!";
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.streak});

  final WeeklyStreak streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Joriy seriya',
            value: '${streak.currentStreak}',
            emoji: '🔥',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Bu hafta',
            value: '${streak.activeDaysThisWeek}/7',
            emoji: '📅',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
  });

  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF3C7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A6D3B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    final bg = day.active
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFF5F5F5);
    final border = isToday ? const Color(0xFFF5B700) : Colors.transparent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 2),
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
                : const Color(0xFF666666),
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.close_rounded,
            color: Color(0xFF64748B),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "Streak ma'lumotlarini yuklab bo'lmadi",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A8580),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
