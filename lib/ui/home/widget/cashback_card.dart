import 'package:flutter/material.dart';

class CashbackCard extends StatelessWidget {
  const CashbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _CashbackTopRow(),
            SizedBox(height: 8),
            _ProgressBar(progress: 0.87),
            SizedBox(height: 8),
            _CashbackMeta(),
          ],
        ),
      ),
    );
  }
}

class _CashbackTopRow extends StatelessWidget {
  const _CashbackTopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Mavjud balans',
                style: TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "51 760 so'm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5B700).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.arrow_upward_rounded,
                size: 12,
                color: Color(0xFFB98900),
              ),
              SizedBox(width: 4),
              Text(
                '87%',
                style: TextStyle(
                  color: Color(0xFFF5B700),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 5,
        color: Colors.white.withValues(alpha: 0.1),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5B700), Color(0xFFFCD34D)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashbackMeta extends StatelessWidget {
  const _CashbackMeta();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Oy oxirigacha: 13 kun',
          style: TextStyle(
            color: Color(0x59FFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '87 / 100%',
          style: TextStyle(
            color: Color(0x59FFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
