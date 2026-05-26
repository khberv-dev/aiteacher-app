import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:ai_teacher/core/cashback/presentation/cashback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashbackCard extends ConsumerWidget {
  const CashbackCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(cashbackSummaryProvider);
    final summary = summaryAsync.valueOrNull ?? CashbackSummary.zero;
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
          children: [
            _CashbackTopRow(summary: summary),
            const SizedBox(height: 10),
            _CashbackMeta(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _CashbackTopRow extends StatelessWidget {
  const _CashbackTopRow({required this.summary});

  final CashbackSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jami cashback',
                style: TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatPrice(summary.total),
                style: const TextStyle(
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
              Text('🪙', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Text(
                'Cashback',
                style: TextStyle(
                  color: Color(0xFFF5B700),
                  fontSize: 12,
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

class _CashbackMeta extends StatelessWidget {
  const _CashbackMeta({required this.summary});

  final CashbackSummary summary;

  @override
  Widget build(BuildContext context) {
    final hasUnclaimed = summary.unclaimed > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            hasUnclaimed
                ? "Olishga tayyor: ${_formatPrice(summary.unclaimed)}"
                : "Yangi cashback'larni do'st referal qilib oling",
            style: const TextStyle(
              color: Color(0x59FFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatPrice(num value) {
  final whole = value.toInt();
  final s = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
