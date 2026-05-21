import 'package:flutter/material.dart';

enum _DayState { past, today, future }

class _DayInfo {
  const _DayInfo(this.label, this.state);

  final String label;
  final _DayState state;
}

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  static const _days = [
    _DayInfo('Du', _DayState.past),
    _DayInfo('Se', _DayState.past),
    _DayInfo('Cho', _DayState.today),
    _DayInfo('Pa', _DayState.future),
    _DayInfo('Ju', _DayState.future),
    _DayInfo('Sha', _DayState.future),
    _DayInfo('Ya', _DayState.future),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
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
              children: const [
                Text(
                  '🔥 3 kunlik seria!',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '4 kun qoldi',
                  style: TextStyle(
                    color: Color(0xB3000000),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final day in _days) _DayCell(day: day)],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final _DayInfo day;

  @override
  Widget build(BuildContext context) {
    final isFuture = day.state == _DayState.future;
    final isToday = day.state == _DayState.today;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isFuture
                ? const Color(0xFFF5F5F5)
                : isToday
                ? const Color(0xFFFDE68A)
                : const Color(0xFFFEF3C7),
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
          child: isFuture
              ? null
              : const Text('🔥', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(
          day.label,
          style: TextStyle(
            color: isToday ? const Color(0xFF1A1A1A) : const Color(0xB3000000),
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
