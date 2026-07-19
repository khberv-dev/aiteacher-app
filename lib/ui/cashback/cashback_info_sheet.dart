import 'package:ai_teacher/core/cashback/data/cashback_dtos.dart';
import 'package:ai_teacher/core/cashback/presentation/cashback_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

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
                  _SectionTitle(title: l10n.cashbackHowItWorksTitle),
                  const SizedBox(height: 12),
                  const _CriteriaList(),
                  const SizedBox(height: 28),
                  _SectionTitle(title: l10n.cashbackHistoryTitle),
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
    final l10n = AppLocalizations.of(context);
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
              Text(
                l10n.cashbackSectionLabel,
                style: const TextStyle(
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
            _fmt(summary.total, l10n),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.cashbackTotalBalanceLabel,
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
                    l10n.cashbackReadyToClaim(_fmt(summary.unclaimed, l10n)),
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
    final l10n = AppLocalizations.of(context);
    final items = [
      _CriterionData(
        emoji: '🎉',
        title: l10n.cashbackCriterionRegisterTitle,
        subtitle: l10n.cashbackCriterionRegisterSubtitle,
        reward: '25 000 ${l10n.cashbackCurrencySuffix}',
        rewardIsPercent: false,
      ),
      _CriterionData(
        emoji: '👥',
        title: l10n.cashbackCriterionReferralTitle,
        subtitle: l10n.cashbackCriterionReferralSubtitle,
        reward: '1 000 ${l10n.cashbackCurrencySuffix}',
        rewardIsPercent: false,
      ),
      _CriterionData(
        emoji: '💳',
        title: l10n.cashbackCriterionPaymentTitle,
        subtitle: l10n.cashbackCriterionPaymentSubtitle,
        reward: '1.5%',
        rewardIsPercent: true,
      ),
      _CriterionData(
        emoji: '🤝',
        title: l10n.cashbackCriterionReferralPaymentTitle,
        subtitle: l10n.cashbackCriterionReferralPaymentSubtitle,
        reward: '1%',
        rewardIsPercent: true,
      ),
      _CriterionData(
        emoji: '🔥',
        title: l10n.cashbackCriterionStreakTitle,
        subtitle: l10n.cashbackCriterionStreakSubtitle,
        reward: '3 000 ${l10n.cashbackCurrencySuffix}',
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
    final l10n = AppLocalizations.of(context);
    return async.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.cashbackHistoryLoadError,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.cashbackHistoryEmpty,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
    final l10n = AppLocalizations.of(context);
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
                  _formatDate(item.createdAt, l10n),
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
            '+ ${_fmt(item.amount, l10n)}',
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

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final months = [
      l10n.cashbackMonthJan,
      l10n.cashbackMonthFeb,
      l10n.cashbackMonthMar,
      l10n.cashbackMonthApr,
      l10n.cashbackMonthMay,
      l10n.cashbackMonthJun,
      l10n.cashbackMonthJul,
      l10n.cashbackMonthAug,
      l10n.cashbackMonthSep,
      l10n.cashbackMonthOct,
      l10n.cashbackMonthNov,
      l10n.cashbackMonthDec,
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

String _fmt(num value, AppLocalizations l10n) {
  final whole = value.toInt();
  final s = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} ${l10n.cashbackCurrencySuffix}';
}
