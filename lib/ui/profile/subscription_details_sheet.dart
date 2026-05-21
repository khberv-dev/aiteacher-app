import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:ai_teacher/core/plan/presentation/available_plans_controller.dart';
import 'package:ai_teacher/core/user/data/user_dtos.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionDetailsSheet extends ConsumerStatefulWidget {
  const SubscriptionDetailsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SubscriptionDetailsSheet(),
    );
  }

  @override
  ConsumerState<SubscriptionDetailsSheet> createState() =>
      _SubscriptionDetailsSheetState();
}

class _SubscriptionDetailsSheetState
    extends ConsumerState<SubscriptionDetailsSheet> {
  String? _selectedPlanId;
  int? _selectedMonth;

  void _select(String planId, int month) {
    setState(() {
      _selectedPlanId = planId;
      _selectedMonth = month;
    });
  }

  Plan? _findSelectedPlan(List<Plan> plans) {
    if (_selectedPlanId == null) return null;
    for (final p in plans) {
      if (p.id == _selectedPlanId) return p;
    }
    return null;
  }

  PlanPrice? _findSelectedPrice(Plan? plan) {
    if (plan == null || _selectedMonth == null) return null;
    for (final p in plan.prices) {
      if (p.month == _selectedMonth) return p;
    }
    return null;
  }

  void _onPurchase() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text("To'lov sahifasi tez orada qo'shiladi")),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final plansAsync = ref.watch(availablePlansProvider);
    final plans = plansAsync.valueOrNull ?? const <Plan>[];
    final selectedPlan = _findSelectedPlan(plans);
    final selectedPrice = _findSelectedPrice(selectedPlan);
    final canPurchase = selectedPlan != null && selectedPrice != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Grabber(),
              const SizedBox(height: 12),
              const Text(
                'Obuna',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _CurrentSubscriptionCard(
                      subscription: user?.activeSubscription,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mavjud tariflar',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    plansAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      ),
                      error: (_, _) =>
                          const _ErrorRow(text: "Tariflarni yuklab bo'lmadi"),
                      data: (items) {
                        if (items.isEmpty) {
                          return const _ErrorRow(text: 'Tariflar topilmadi');
                        }
                        return Column(
                          children: [
                            for (final plan in items)
                              _PlanCard(
                                plan: plan,
                                selectedMonth: _selectedPlanId == plan.id
                                    ? _selectedMonth
                                    : null,
                                onSelectPrice: (price) =>
                                    _select(plan.id, price.month),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (canPurchase)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _PurchaseButton(
                    planName: selectedPlan.name,
                    price: selectedPrice,
                    onPressed: _onPurchase,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.planName,
    required this.price,
    required this.onPressed,
  });

  final String planName;
  final PlanPrice price;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${planName.isEmpty ? 'Tarif' : planName} · ${price.month} oy',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatPrice(price.price),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE2DED7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CurrentSubscriptionCard extends StatelessWidget {
  const _CurrentSubscriptionCard({required this.subscription});

  final ActiveSubscription? subscription;

  @override
  Widget build(BuildContext context) {
    final hasSub = subscription != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x33F5B700),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF5B700),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pro paket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(active: hasSub),
            ],
          ),
          const SizedBox(height: 14),
          if (hasSub) ...[
            _Detail(
              label: 'Boshlangan',
              value: _formatDate(subscription!.startDate),
            ),
            const SizedBox(height: 8),
            _Detail(
              label: 'Tugaydi',
              value: _formatDate(subscription!.endDate),
            ),
            const SizedBox(height: 8),
            _Detail(
              label: 'Qolgan',
              value: '${_daysLeft(subscription!.endDate)} kun',
            ),
          ] else
            const Text(
              "Hozircha faol obunangiz yo'q. Quyidagi tariflardan birini tanlang.",
              style: TextStyle(
                color: Color(0xFFB7BCC8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Faol' : "Yo'q",
        style: TextStyle(
          color: active ? const Color(0xFF15803D) : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB7BCC8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selectedMonth,
    required this.onSelectPrice,
  });

  final Plan plan;
  final int? selectedMonth;
  final ValueChanged<PlanPrice> onSelectPrice;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedMonth != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name.isEmpty ? 'Tarif' : plan.name,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (plan.hasMentor)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x330D9488),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Mentor',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (plan.prices.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              children: [
                for (final p in plan.prices)
                  _PriceRow(
                    price: p,
                    selected: selectedMonth == p.month,
                    onTap: () => onSelectPrice(p),
                  ),
              ],
            ),
          ],
          if (plan.availableFeatures.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final f in plan.availableFeatures)
              _FeatureRow(text: f, available: true),
          ],
          if (plan.notAvailableFeatures.isNotEmpty)
            for (final f in plan.notAvailableFeatures)
              _FeatureRow(text: f, available: false),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFFF0FDFA) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFEDEAE4),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : const Color(0xFFCFCFCF),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '${price.month} oy',
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFF555555),
                    fontSize: 13,
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
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            available ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: available
                ? const Color(0xFF22C55E)
                : const Color(0xFFE2DED7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: available
                    ? const Color(0xFF333333)
                    : const Color(0xFF999999),
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
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8A8580),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

const _uzMonths = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

String _formatDate(DateTime d) {
  final local = d.toLocal();
  final month = (local.month >= 1 && local.month <= 12)
      ? _uzMonths[local.month - 1]
      : '';
  return '${local.day}-$month ${local.year}';
}

int _daysLeft(DateTime endDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final delta = endDate.toLocal().difference(today).inDays;
  return delta < 0 ? 0 : delta;
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
