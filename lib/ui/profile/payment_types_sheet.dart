import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/payment/data/payment_dtos.dart';
import 'package:ai_teacher/core/payment/data/payment_repository.dart';
import 'package:ai_teacher/core/payment/presentation/payment_types_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentTypesSheet extends ConsumerStatefulWidget {
  const PaymentTypesSheet({
    super.key,
    required this.planId,
    required this.planName,
    required this.planMonth,
    required this.amount,
  });

  final String planId;
  final String planName;
  final int planMonth;
  final num amount;

  static Future<bool?> show(
    BuildContext context, {
    required String planId,
    required String planName,
    required int planMonth,
    required num amount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PaymentTypesSheet(
        planId: planId,
        planName: planName,
        planMonth: planMonth,
        amount: amount,
      ),
    );
  }

  @override
  ConsumerState<PaymentTypesSheet> createState() => _PaymentTypesSheetState();
}

class _PaymentTypesSheetState extends ConsumerState<PaymentTypesSheet> {
  String? _creatingTypeId;

  Future<void> _onSelect(PaymentType type) async {
    if (_creatingTypeId != null) return;
    setState(() => _creatingTypeId = type.id);
    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .create(
            paymentTypeId: type.id,
            planId: widget.planId,
            planMonth: widget.planMonth,
            amount: widget.amount,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "${type.title} orqali to'lov yaratildi · ${_formatPrice(payment.amount)}",
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

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(paymentTypesProvider);
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
                '${widget.planName.isEmpty ? "Tarif" : widget.planName} · '
                '${widget.planMonth} oy · ${_formatPrice(widget.amount)}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: types.when(
                  loading: () => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                  error: (_, _) => const _EmptyText(
                    text: "To'lov usullarini yuklab bo'lmadi",
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const _EmptyText(text: "To'lov usullari yo'q");
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final type = items[i];
                        final isLoading = _creatingTypeId == type.id;
                        final anyLoading = _creatingTypeId != null;
                        return _PaymentTypeTile(
                          type: type,
                          loading: isLoading,
                          disabled: anyLoading && !isLoading,
                          onTap: () => _onSelect(type),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
