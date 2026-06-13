import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:ai_teacher/core/cashback/presentation/cashback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashbackInfoSheet extends ConsumerWidget {
  const CashbackInfoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CashbackInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(cashbackSummaryProvider);
    final historyAsync = ref.watch(cashbackHistoryProvider);
    final summary = summaryAsync.valueOrNull ?? CashbackSummary.zero;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const _SheetHandle(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  _BalanceHeader(summary: summary),
                  const SizedBox(height: 24),
                  _SectionTitle(title: "Qanday cashback yig'iladi?"),
                  const SizedBox(height: 12),
                  const _CriteriaList(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: 'Tarix'),
                  const SizedBox(height: 12),
                  _HistoryList(async: historyAsync),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.summary});

  final CashbackSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Cashback',
                style: TextStyle(
                  color: Color(0xFFF5B700),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _fmt(summary.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jami cashback balansi',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (summary.unclaimed > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5B700).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF5B700).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFF5B700),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Olishga tayyor: ${_fmt(summary.unclaimed)}',
                    style: const TextStyle(
                      color: Color(0xFFF5B700),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CriteriaList extends StatelessWidget {
  const _CriteriaList();

  @override
  Widget build(BuildContext context) {
    const items = [
      _CriterionData(
        emoji: '🎉',
        title: "Ro'yxatdan o'tganingiz uchun",
        subtitle: 'Bir martalik kirish bonusi',
        reward: '25 000 so\'m',
        rewardIsPercent: false,
      ),
      _CriterionData(
        emoji: '👥',
        title: "Har bir do'stingiz referal orqali ro'yxatdan o'tganda",
        subtitle: 'Referal kodingizni ulashing',
        reward: '1 000 so\'m',
        rewardIsPercent: false,
      ),
      _CriterionData(
        emoji: '💳',
        title: "Sizning har bir to'lovingizdan",
        subtitle: 'Obuna xarid qilganda avtomatik',
        reward: '1.5%',
        rewardIsPercent: true,
      ),
      _CriterionData(
        emoji: '🤝',
        title: "Do'stingiz har bir to'lov qilganda",
        subtitle: "Referal qilgan do'stingiz to'laganda",
        reward: '1%',
        rewardIsPercent: true,
      ),
      _CriterionData(
        emoji: '🔥',
        title: "Haftalik streak seriyasini yakunlaganingiz uchun",
        subtitle: "Har haftada maqsadni bajarsangiz",
        reward: '3 000 so\'m',
        rewardIsPercent: false,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _CriterionRow(data: items[i]),
          if (i < items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Divider(height: 1, color: Color(0xFFF3F4F6)),
            ),
        ],
      ],
    );
  }
}

class _CriterionData {
  const _CriterionData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.rewardIsPercent,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String reward;
  final bool rewardIsPercent;
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({required this.data});

  final _CriterionData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Text(data.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data.reward,
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.async});

  final AsyncValue<List<Cashback>> async;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Tarixni yuklab bo\'lmadi',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Hali cashback operatsiyalari yo\'q',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _HistoryRow(item: items[i]),
              if (i < items.length - 1)
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
          ],
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final Cashback item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _typeEmoji(item.type),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type.sourceLabelUz,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(item.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ${_fmt(item.amount)}',
            style: const TextStyle(
              color: Color(0xFFB45309),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _typeEmoji(CashbackType type) => switch (type) {
    CashbackType.register => '🎉',
    CashbackType.referral => '👥',
    CashbackType.payment => '💳',
    CashbackType.referralPayment => '🤝',
    CashbackType.streak => '🔥',
  };

  String _formatDate(DateTime dt) {
    const months = [
      'yan', 'fev', 'mar', 'apr', 'may', 'iyn',
      'iyl', 'avg', 'sen', 'okt', 'noy', 'dek',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

String _fmt(num value) {
  final whole = value.toInt();
  final s = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
