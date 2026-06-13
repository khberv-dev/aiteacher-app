import 'dart:async';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/core/course/data/course_repository.dart';
import 'package:ai_teacher/core/course/presentation/courses_controller.dart';
import 'package:ai_teacher/core/payment/data/payment_dtos.dart';
import 'package:ai_teacher/core/payment/data/payment_repository.dart';
import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:ai_teacher/core/plan/presentation/available_plans_controller.dart';
import 'package:ai_teacher/core/user/data/user_dtos.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/courses/widget/course_info_sheet.dart';
import 'package:ai_teacher/ui/main/main_screen.dart';
import 'package:ai_teacher/ui/profile/payment_types_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coursesControllerProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final plans =
        ref.watch(availablePlansProvider).valueOrNull ?? const <Plan>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kurslarni yuklashda xatolik',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(coursesControllerProvider.notifier).refresh(),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () =>
              ref.read(coursesControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'Kurslar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              if (state.mine.isNotEmpty) ...[
                _SectionHeader(title: 'Mening kurslarim'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: state.mine.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _EnrolledCourseCard(course: state.mine[i]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
              if (state.available.isNotEmpty) ...[
                _SectionHeader(title: "Mavjud kurslar"),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: state.available.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _AvailableCourseCard(course: state.available[i]),
                  ),
                ),
              ],
              if (state.mine.isEmpty && state.available.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "Hozircha kurslar yo'q",
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _SubscriptionSection(
                  subscription: user?.activeSubscription,
                  plans: plans,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

// ─── Enrolled course card ─────────────────────────────────────────────────────

class _EnrolledCourseCard extends StatelessWidget {
  const _EnrolledCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => CourseInfoSheet.showEnrolled(
            context,
            course: course,
            onNavigate: () =>
                context.pushNamed(AppRoute.courseWeb.name, extra: course),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CourseCover(coverUrl: course.coverUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                    if ((course.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        course.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Available course card ────────────────────────────────────────────────────

class _AvailableCourseCard extends ConsumerStatefulWidget {
  const _AvailableCourseCard({required this.course});

  final Course course;

  @override
  ConsumerState<_AvailableCourseCard> createState() =>
      _AvailableCourseCardState();
}

class _AvailableCourseCardState extends ConsumerState<_AvailableCourseCard>
    with WidgetsBindingObserver {
  bool _loading = false;
  bool _checkingPayment = false;
  String? _pendingPaymentId;
  Timer? _pollTimer;
  int _pollAttempts = 0;

  static const _pollInterval = Duration(seconds: 2);
  static const _maxAttempts = 30; // 60 s total

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingPaymentId != null) {
      _ensurePolling();
    }
  }

  void _ensurePolling() {
    if (_pollTimer?.isActive ?? false) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkPayment());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkPayment() async {
    final paymentId = _pendingPaymentId;
    if (paymentId == null) {
      _stopPolling();
      return;
    }

    _pollAttempts++;
    if (_pollAttempts > _maxAttempts) {
      _stopPolling();
      if (!mounted) return;
      setState(() {
        _checkingPayment = false;
        _pendingPaymentId = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("To'lov tasdiqlanmadi. Qayta urinib ko'ring"),
          ),
        );
      return;
    }

    try {
      final payment = await ref
          .read(paymentRepositoryProvider)
          .findById(paymentId);
      if (payment == null) return;

      switch (payment.status) {
        case PaymentStatus.success:
          _stopPolling();
          await _activateDemo(paymentId);
        case PaymentStatus.failed:
        case PaymentStatus.declined:
          _stopPolling();
          if (!mounted) return;
          setState(() {
            _checkingPayment = false;
            _pendingPaymentId = null;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text("To'lov amalga oshmadi")),
            );
        case PaymentStatus.created:
          break;
      }
    } catch (_) {
      // Network error — keep polling
    }
  }

  Future<void> _activateDemo(String paymentId) async {
    if (!mounted) return;
    setState(() {
      _checkingPayment = false;
      _loading = true;
      _pendingPaymentId = null;
    });
    try {
      final enrollment = await ref
          .read(courseRepositoryProvider)
          .requestDemo(paymentId: paymentId, courseId: widget.course.id);
      if (!mounted) return;
      context.pushNamed(
        AppRoute.courseWeb.name,
        extra: widget.course.copyWith(
          login: enrollment.login,
          password: enrollment.password,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Demo faollashtirish amalga oshmadi")),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onDemo() async {
    if (_loading || _checkingPayment) return;
    final demoPrice = widget.course.demoPrice;
    if (demoPrice == null) return;

    final paymentId = await PaymentTypesSheet.show(
      context,
      amount: demoPrice,
      title: '${widget.course.title} · Demo (24 soat)',
    );
    if (paymentId == null || !mounted) return;

    setState(() {
      _pendingPaymentId = paymentId;
      _checkingPayment = true;
      _pollAttempts = 0;
    });
    _ensurePolling();
  }

  Future<void> _openInfoSheet() {
    return CourseInfoSheet.showAvailable(
      context,
      course: widget.course,
      onDemo: _onDemo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openInfoSheet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CourseCover(coverUrl: course.coverUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    if ((course.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        course.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Subscription section ─────────────────────────────────────────────────────

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({required this.subscription, required this.plans});

  final ActiveSubscription? subscription;
  final List<Plan> plans;

  @override
  Widget build(BuildContext context) {
    if (subscription != null) {
      return _ActiveSubscriptionBanner(subscription: subscription!);
    }
    if (plans.isEmpty) return const SizedBox.shrink();
    return _PlanOfferList(plans: plans);
  }
}

class _ActiveSubscriptionBanner extends StatelessWidget {
  const _ActiveSubscriptionBanner({required this.subscription});

  final ActiveSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysLeft(subscription.endDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.tintTeal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Obuna faol',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(subscription.endDate)} gacha · $daysLeft kun qoldi',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOfferList extends StatelessWidget {
  const _PlanOfferList({required this.plans});

  final List<Plan> plans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final plan in plans) _PlanOfferCard(plan: plan)],
      ),
    );
  }
}

class _PlanOfferCard extends StatelessWidget {
  const _PlanOfferCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final firstPrice = plan.prices.isNotEmpty ? plan.prices.first : null;
    final color = _planColor(plan.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: plan.color != null
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      plan.hasMentor
                          ? Icons.person_rounded
                          : Icons.star_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.name.isEmpty ? 'Tarif' : plan.name,
                      style: const TextStyle(
                        color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Mentor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              // ── Prices ──────────────────────────────────────────────────
              if (plan.prices.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'MUDDAT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                for (final p in plan.prices) _PlanPriceRow(price: p),
              ],
              // ── Features ────────────────────────────────────────────────
              if (plan.availableFeatures.isNotEmpty) ...[
                const SizedBox(height: 14),
                for (final f in plan.availableFeatures)
                  _PlanFeatureRow(text: f, available: true),
              ],
              if (plan.notAvailableFeatures.isNotEmpty)
                for (final f in plan.notAvailableFeatures)
                  _PlanFeatureRow(text: f, available: false),
              // ── Buy button ──────────────────────────────────────────────
              if (firstPrice != null) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 14),
                _AnimatedBuyButton(
                  label: "Obuna bo'lish · ${_formatPrice(firstPrice.price)}",
                  color: color,
                  onPressed: () async {
                    final paymentId = await PaymentTypesSheet.show(
                      context,
                      amount: firstPrice.price,
                      title:
                          '${plan.name.isEmpty ? "Tarif" : plan.name} · ${firstPrice.month} oy',
                    );
                    if (paymentId != null && context.mounted) {
                      context.goNamed(
                        AppRoute.main.name,
                        extra: MainScreen.coursesTab,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanPriceRow extends StatelessWidget {
  const _PlanPriceRow({required this.price});

  final PlanPrice price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '${price.month} oy',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (price.hasDiscount) ...[
            Text(
              _formatPrice(price.actualPrice),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _formatPrice(price.price),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanFeatureRow extends StatelessWidget {
  const _PlanFeatureRow({required this.text, required this.available});

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
            size: 16,
            color: available
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: available
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _CourseCover extends StatelessWidget {
  const _CourseCover({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final fullUrl = coverUrl != null
        ? '${NetworkConfig.hostUrl}/public/$coverUrl'
        : null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: fullUrl != null
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primary.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: Icon(
      Icons.school_rounded,
      size: 48,
      color: AppColors.primary.withValues(alpha: 0.4),
    ),
  );
}

// ─── Animated buy button ─────────────────────────────────────────────────────

class _AnimatedBuyButton extends StatefulWidget {
  const _AnimatedBuyButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_AnimatedBuyButton> createState() => _AnimatedBuyButtonState();
}

class _AnimatedBuyButtonState extends State<_AnimatedBuyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.white),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => CustomPaint(
                painter: _BuyButtonPainter(
                  progress: _ctrl.value,
                  color: widget.color,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                splashColor: widget.color.withValues(alpha: 0.12),
                highlightColor: widget.color.withValues(alpha: 0.06),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
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

class _BuyButtonPainter extends CustomPainter {
  const _BuyButtonPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOut.transform(progress);
    final cx = -size.width * 0.4 + size.width * 1.8 * t;
    final hw = size.width * 0.32;
    final tilt = size.height * 0.7;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(cx - hw, 0, hw * 2, size.height));

    final path = Path()
      ..moveTo(cx - hw + tilt, 0)
      ..lineTo(cx + hw + tilt, 0)
      ..lineTo(cx + hw - tilt, size.height)
      ..lineTo(cx - hw - tilt, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BuyButtonPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

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

Color _planColor(String? hex) {
  if (hex == null || hex.isEmpty) return AppColors.primary;
  final clean = hex.startsWith('#') ? hex.substring(1) : hex;
  final value = int.tryParse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
  return value != null ? Color(value) : AppColors.primary;
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
