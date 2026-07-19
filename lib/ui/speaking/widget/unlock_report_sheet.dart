import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/speaking/presentation/report_unlock_price.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/profile/payment_types_sheet.dart';
import 'package:ai_teacher/ui/profile/subscription_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnlockReportSheet extends ConsumerWidget {
  const UnlockReportSheet({super.key, this.conversationId});

  /// The conversation whose report is being unlocked. Forwarded into
  /// the payment sheet so the created payment can be linked back to it
  /// (and the report screen can show a wait state on return).
  final String? conversationId;

  static Future<void> show(BuildContext context, {String? conversationId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UnlockReportSheet(conversationId: conversationId),
    );
  }

  Future<void> _onPay(BuildContext context, int price) async {
    final l10n = AppLocalizations.of(context);
    Navigator.of(context).pop();
    await PaymentTypesSheet.show(
      context,
      amount: price,
      title: l10n.speakingReportUnlockPaymentTitle,
      callbackUrl: 'https://ai.myteacher.uz/app/report',
      conversationId: conversationId,
    );
  }

  Future<void> _onSubscribe(BuildContext context) async {
    Navigator.of(context).pop();
    await SubscriptionDetailsSheet.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final priceAsync = ref.watch(reportUnlockPriceProvider);
    final price = priceAsync.valueOrNull;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 18),
            const Center(child: _Hero()),
            const SizedBox(height: 18),
            Text(
              l10n.speakingReportUnlockTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.speakingReportUnlockDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            _PriceCard(amount: price),
            const SizedBox(height: 16),
            _PayButton(
              enabled: price != null,
              onTap: price == null ? null : () => _onPay(context, price),
            ),
            const SizedBox(height: 10),
            _UnlimitedButton(onTap: () => _onSubscribe(context)),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                ),
                child: Text(
                  l10n.sharedUpdateDialogLater,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5B700).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_open_rounded,
        size: 38,
        color: Color(0xFFB45309),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.amount});

  /// `null` means the price is still loading from the API — shows a
  /// small spinner in place of the figure.
  final int? amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.speakingReportUnlockPriceCardLabel,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.speakingReportUnlockOneTimePayment,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (amount == null)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF0F172A)),
              ),
            )
          else
            Text(
              _formatPrice(l10n, amount!),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.onTap, this.enabled = true});

  final VoidCallback? onTap;

  /// When `false` the button renders dimmed and ignores taps — used while
  /// the unlock price is still being fetched.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.speakingReportUnlockPayButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlimitedButton extends StatelessWidget {
  const _UnlimitedButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.speakingReportUnlockUnlimitedButton,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(AppLocalizations l10n, num value) {
  final whole = value.toInt();
  final s = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} ${l10n.speakingReportUnlockCurrencySom}';
}
