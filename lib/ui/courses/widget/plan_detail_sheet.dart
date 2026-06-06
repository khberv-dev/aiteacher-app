import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:ai_teacher/ui/profile/payment_types_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanDetailSheet extends ConsumerStatefulWidget {
  const PlanDetailSheet({super.key, required this.plan});

  final Plan plan;

  static Future<void> show(BuildContext context, Plan plan) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PlanDetailSheet(plan: plan),
    );
  }

  @override
  ConsumerState<PlanDetailSheet> createState() => _PlanDetailSheetState();
}

class _PlanDetailSheetState extends ConsumerState<PlanDetailSheet> {
  late int? _selectedMonth =
      widget.plan.prices.isNotEmpty ? widget.plan.prices.first.month : null;

  Plan get plan => widget.plan;

  PlanPrice? get _selectedPrice {
    if (_selectedMonth == null) return null;
    for (final p in plan.prices) {
      if (p.month == _selectedMonth) return p;
    }
    return null;
  }

  Future<void> _onSubscribe() async {
    final price = _selectedPrice;
    if (price == null) return;
    final created = await PaymentTypesSheet.show(
      context,
      amount: price.price,
      title: '${plan.name.isEmpty ? "Tarif" : plan.name} · ${price.month} oy',
    );
    if (created == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            _Handle(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottom),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name.isEmpty ? 'Tarif' : plan.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (plan.hasMentor)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Mentor bilan',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (plan.prices.isNotEmpty) ...[
                    const Text(
                      'Muddat tanlang',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...plan.prices.map(
                      (p) => _PriceOption(
                        price: p,
                        selected: _selectedMonth == p.month,
                        onTap: () => setState(() => _selectedMonth = p.month),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (plan.availableFeatures.isNotEmpty) ...[
                    const Text(
                      "Nima kiradi",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...plan.availableFeatures.map(
                      (f) => _FeatureRow(text: f, available: true),
                    ),
                  ],
                  if (plan.notAvailableFeatures.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...plan.notAvailableFeatures.map(
                      (f) => _FeatureRow(text: f, available: false),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
              child: FilledButton(
                onPressed: _selectedPrice != null ? _onSubscribe : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _selectedPrice != null
                      ? "Obuna bo'lish · ${_formatPrice(_selectedPrice!.price)}"
                      : "Muddat tanlang",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final PlanPrice price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.05)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 10),
              Text(
                '${price.month} oy',
                style: TextStyle(
                  color: selected ? AppColors.primary : const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (price.hasDiscount) ...[
                Text(
                  _formatPrice(price.actualPrice),
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatPrice(price.price),
                style: TextStyle(
                  color: selected ? AppColors.primary : const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.available});

  final String text;
  final bool available;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          available ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: available
              ? const Color(0xFF22C55E)
              : const Color(0xFFCBD5E1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: available
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF94A3B8),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatPrice(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
