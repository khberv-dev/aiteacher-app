import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  static const _bars = <_BarData>[
    _BarData('Du', 0.45, false),
    _BarData('Se', 0.35, false),
    _BarData('Ch', 0.55, false),
    _BarData('Pa', 1.0, true),
    _BarData('Ju', 0.5, false),
    _BarData('Sh', 0.4, false),
    _BarData('Ya', 0.6, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.translate,
                        size: 16,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Yangi so'zlar",
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Jami: 312',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ajoyib hafta!',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < _bars.length; i++) ...[
                    Expanded(child: _Bar(data: _bars[i])),
                    if (i < _bars.length - 1) const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  const _BarData(this.label, this.heightFactor, this.highlighted);

  final String label;
  final double heightFactor;
  final bool highlighted;
}

class _Bar extends StatelessWidget {
  const _Bar({required this.data});

  final _BarData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: data.heightFactor,
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: data.highlighted
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                        ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.label,
          style: TextStyle(
            color: data.highlighted
                ? const Color(0xFF3B82F6)
                : const Color(0xFFBBBBBB),
            fontSize: 9,
            fontWeight: data.highlighted ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
