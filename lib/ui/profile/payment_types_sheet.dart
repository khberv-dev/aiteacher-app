import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:dio/dio.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/cards/data/card_dtos.dart';
import 'package:ai_teacher/core/cards/data/card_repository.dart';
import 'package:ai_teacher/core/cards/presentation/cards_controller.dart';
import 'package:ai_teacher/core/payment/data/payment_dtos.dart';
import 'package:ai_teacher/core/payment/data/payment_repository.dart';
import 'package:ai_teacher/core/payment/presentation/payment_types_controller.dart';
import 'package:ai_teacher/core/speaking/data/speaking_repository.dart';
import 'package:ai_teacher/core/speaking/presentation/pending_report_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentTypesSheet extends ConsumerStatefulWidget {
  const PaymentTypesSheet({
    super.key,
    required this.amount,
    this.title,
    this.callbackUrl,
    this.conversationId,
  });

  final String? title;
  final num amount;
  final String? callbackUrl;
  final String? conversationId;

  static Future<String?> show(
    BuildContext context, {
    required num amount,
    String? title,
    String? callbackUrl,
    String? conversationId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PaymentTypesSheet(
        amount: amount,
        title: title,
        callbackUrl: callbackUrl,
        conversationId: conversationId,
      ),
    );
  }

  @override
  ConsumerState<PaymentTypesSheet> createState() => _PaymentTypesSheetState();
}

class _PaymentTypesSheetState extends ConsumerState<PaymentTypesSheet> {
  String? _creatingTypeId;
  String? _payingCardId;
  String? _cardError;

  // ── Regular payment type ──────────────────────────────────────────────────

  Future<void> _onSelectType(PaymentType type) async {
    if (_isBusy) return;
    setState(() => _creatingTypeId = type.id);
    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .create(
            paymentTypeId: type.id,
            amount: widget.amount,
            callbackUrl: widget.callbackUrl,
          );

      final conversationId = widget.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        try {
          await ref
              .read(speakingRepositoryProvider)
              .assignPaymentToConversation(
                conversationId: conversationId,
                paymentId: payment.id,
              );
        } catch (e) {
          debugPrint('assignPaymentToConversation failed: $e');
        }
        ref
            .read(pendingReportPaymentProvider.notifier)
            .start(conversationId: conversationId, paymentId: payment.id);
      }

      if (!mounted) return;
      Navigator.of(context).pop(payment.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "${type.title} orqali to'lov yaratildi · ${_formatPrice(widget.amount)}",
            ),
          ),
        );
      final url = payment.payUrl;
      if (url != null && url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _creatingTypeId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("To'lovni yaratib bo'lmadi")),
        );
    }
  }

  // ── Card payment ──────────────────────────────────────────────────────────

  Future<void> _onPayWithCard(UserCard card) async {
    if (_isBusy) return;
    setState(() {
      _payingCardId = card.id;
      _cardError = null;
    });
    try {
      await ref.read(cardRepositoryProvider).payWithCard(
            cardId: card.id,
            amount: widget.amount.toInt(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(card.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "Karta orqali to'lov amalga oshirildi · ${_formatPrice(widget.amount)}",
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _payingCardId = null;
        _cardError = _parseCardError(e);
      });
    }
  }

  String _parseCardError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
    }
    return "Karta orqali to'lovda xatolik yuz berdi";
  }

  bool get _isBusy => _creatingTypeId != null || _payingCardId != null;

  Widget _buildList(ScrollController scrollController) {
    final types = ref.watch(paymentTypesProvider);
    final cardsAsync = ref.watch(cardsControllerProvider);

    final typeItems = types.valueOrNull ?? [];
    final cards = cardsAsync.valueOrNull ?? [];
    final cardsLoading = cardsAsync.isLoading;

    // Show a single spinner only when both are still loading
    if (types.isLoading && cardsLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    if (types.hasError && cards.isEmpty && !cardsLoading) {
      return const _EmptyText(text: "To'lov usullarini yuklab bo'lmadi");
    }

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        // ── Saved cards (always first) ───────────────────────────────────
        if (cardsLoading) ...[
          _SectionLabel(
            icon: Icons.credit_card_rounded,
            label: 'Saqlangan kartalar',
          ),
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (cards.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.credit_card_rounded,
            label: 'Saqlangan kartalar',
          ),
          const SizedBox(height: 8),
          if (_cardError != null) ...[
            _CardErrorBanner(_cardError!),
            const SizedBox(height: 10),
          ],
          ...cards.map((card) {
            final isLoading = _payingCardId == card.id;
            final disabled = _isBusy && !isLoading;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CardPayTile(
                card: card,
                loading: isLoading,
                disabled: disabled,
                onTap: () => _onPayWithCard(card),
              ),
            );
          }),
        ],
        // ── Payment types ────────────────────────────────────────────────
        if (typeItems.isNotEmpty) ...[
          if (cards.isNotEmpty || cardsLoading) ...[
            const SizedBox(height: 4),
            _SectionLabel(
              icon: Icons.account_balance_wallet_outlined,
              label: "Boshqa to'lov usullari",
            ),
            const SizedBox(height: 8),
          ],
          ...typeItems.map((type) {
            final isLoading = _creatingTypeId == type.id;
            final disabled = _isBusy && !isLoading;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentTypeTile(
                type: type,
                loading: isLoading,
                disabled: disabled,
                onTap: () => _onSelectType(type),
              ),
            );
          }),
        ] else if (types.isLoading) ...[
          if (cards.isNotEmpty || cardsLoading)
            const _SectionLabel(
              icon: Icons.account_balance_wallet_outlined,
              label: "Boshqa to'lov usullari",
            ),
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
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
              const SizedBox(height: 12),
              const Text(
                "To'lov usulini tanlang",
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title != null && widget.title!.isNotEmpty
                    ? '${widget.title} · ${_formatPrice(widget.amount)}'
                    : _formatPrice(widget.amount),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
}

class _CardPayTile extends StatelessWidget {
  const _CardPayTile({
    required this.card,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  final UserCard card;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  String get _bankLabel {
    final prefix = card.cardNumber.isNotEmpty ? card.cardNumber.substring(0, 4) : '';
    if (prefix == '8600') return 'UzCard';
    if (prefix == '9860') return 'Humo';
    return 'Karta';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.credit_card_rounded,
                  size: 22,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.maskedNumber,
                      style: TextStyle(
                        color: disabled
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${card.displayExpiry} · $_bankLabel',
                      style: TextStyle(
                        color: disabled
                            ? const Color(0xFFCCCCCC)
                            : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7BCC8),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTypeTile extends StatelessWidget {
  const _PaymentTypeTile({
    required this.type,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  final PaymentType type;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              _Logo(icon: type.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.title.isEmpty ? "To'lov" : type.title,
                  style: TextStyle(
                    color: disabled
                        ? const Color(0xFFAAAAAA)
                        : const Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7BCC8),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.icon});

  final String? icon;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.credit_card_outlined,
        color: Color(0xFF64748B),
        size: 22,
      ),
    );
    final value = icon;
    if (value == null || value.isEmpty) return placeholder;
    final url = NetworkConfig.resolveStatic(value);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8580),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CardErrorBanner extends StatelessWidget {
  const _CardErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
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
