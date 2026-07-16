import 'dart:io';

import 'package:ai_teacher/app/data/network_config.dart';
import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/course/data/course_dtos.dart';
import 'package:ai_teacher/core/course/presentation/courses_controller.dart';
import 'package:ai_teacher/core/plan/data/plan_dtos.dart';
import 'package:ai_teacher/core/plan/presentation/available_plans_controller.dart';
import 'package:ai_teacher/core/user/data/user_dtos.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/courses/widget/course_info_sheet.dart';
import 'package:ai_teacher/ui/courses/widget/my_mentor_card.dart';
import 'package:ai_teacher/ui/main/main_screen.dart';
import 'package:ai_teacher/ui/profile/payment_types_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Static testimonial data ──────────────────────────────────────────────────

class _TData {
  const _TData({
    required this.name,
    required this.result,
    required this.duration,
    required this.text,
    required this.initial,
    required this.color,
  });

  final String name;
  final String result;
  final String duration;
  final String text;
  final String initial;
  final Color color;
}

const _kTestimonials = [
  _TData(
    name: 'Aziz T.',
    result: 'IELTS 6.5',
    duration: '3 oyda',
    text:
        "O'qituvchi bo'lmaganida bu natijaga yeta olmas edim. Har haftadagi sessiya — bu shunchaki dars emas, bu javobgarlik.",
    initial: 'A',
    color: Color(0xFF818CF8),
  ),
  _TData(
    name: 'Malika R.',
    result: 'IELTS 7.0',
    duration: '5 oyda',
    text:
        "Aniq zaif tomonlarimni topdi va ular ustida ishlash rejasini tuzdi. Shaxsiy yondashuv — boshqa kurslardan farqi shu.",
    initial: 'M',
    color: Color(0xFFF472B6),
  ),
  _TData(
    name: 'Jasur K.',
    result: 'B2 daraja',
    duration: '4 oyda',
    text:
        "Oldin yolg'iz o'qidim, progress sezilmasdi. O'qituvchi bilan — har hafta o'sish ko'rdim. Endi ishonch bilan gaplashaman.",
    initial: 'J',
    color: Color(0xFFFBBF24),
  ),
];

const _kPlatformTestimonials = [
  _TData(
    name: 'Dilnoza S.',
    result: 'B1 daraja',
    duration: '3 oyda',
    text:
        "Uydan chiqmasdan o'rgandim. AI Speaking bilan har kuni mashq qilgach, speaking kuchli tomonimga aylandi.",
    initial: 'D',
    color: Color(0xFF8B5CF6),
  ),
  _TData(
    name: 'Sardor M.',
    result: 'IELTS 6.0',
    duration: '4 oyda',
    text:
        "Ish bilan birga o'rganish uchun platforma juda qulay. Har kuni 30 daqiqa — natija o'zidan keldi.",
    initial: 'S',
    color: Color(0xFF6366F1),
  ),
  _TData(
    name: 'Feruza A.',
    result: 'C1 daraja',
    duration: '6 oyda',
    text:
        "Mock testlar va AI yordamchi bilan mustaqil tayyorlandim. O'qituvchisiz bu darajaga yetaman deb o'ylamagandim.",
    initial: 'F',
    color: Color(0xFFA78BFA),
  ),
];

// ─── Main page ────────────────────────────────────────────────────────────────

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coursesControllerProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final plans =
        ref.watch(availablePlansProvider).valueOrNull ?? const <Plan>[];
    final mentorPlans = plans.where((p) => p.hasMentor).toList();
    final platformPlans = plans.where((p) => !p.hasMentor).toList();
    final subscription = user?.activeSubscription;

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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    "O'qituvchi bilan yoki mustaqil — siz tanlaysiz",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // ── My enrolled courses ─────────────────────────────────────
              if (state.mine.isNotEmpty) ...[
                _SectionLabel(title: 'Mening kurslarim'),
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
              // ── Active subscription banner ──────────────────────────────
              if (subscription != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _ActiveSubscriptionBanner(
                      subscription: subscription,
                    ),
                  ),
                ),
              // ── My mentor ────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: MyMentorCard(),
                ),
              ),
              // ── Teacher mentoring hero ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TeacherHeroSection(
                    plans: mentorPlans,
                    isSubscribed: subscription != null,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // ── Platform section ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PlatformSection(
                    plans: platformPlans,
                    isSubscribed: subscription != null,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
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

// ─── Active subscription banner ───────────────────────────────────────────────

class _ActiveSubscriptionBanner extends StatelessWidget {
  const _ActiveSubscriptionBanner({required this.subscription});
  final ActiveSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysLeft(subscription.endDate);
    return Container(
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
    );
  }
}

// ─── Animated teacher avatar ──────────────────────────────────────────────────

class _TeacherAvatar extends StatefulWidget {
  const _TeacherAvatar();

  @override
  State<_TeacherAvatar> createState() => _TeacherAvatarState();
}

class _TeacherAvatarState extends State<_TeacherAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final Animation<double> _float = Tween<double>(
    begin: -5.0,
    end: 5.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.28),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('👨‍🏫', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}

// ─── Teacher hero section ─────────────────────────────────────────────────────

class _TeacherHeroSection extends StatelessWidget {
  const _TeacherHeroSection({required this.plans, required this.isSubscribed});
  final List<Plan> plans;
  final bool isSubscribed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: badge + avatar ───────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: AppColors.primaryLight,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'MENTORLIK DASTURI',
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Haqiqiy nazorat —\nhaqiqiy natija',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _TeacherAvatar(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Shaxsiy o'qituvchi bilan ingliz tilini 2x tezroq o'rganing. Har hafta nazorat, har kuni yo'nalish.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                // ── Features ─────────────────────────────────────────────
                const _DarkFeature(
                  icon: Icons.calendar_month_rounded,
                  text: "Haftada 3 marta individual dars",
                ),
                const SizedBox(height: 11),
                const _DarkFeature(
                  icon: Icons.route_rounded,
                  text: "Maqsadingizga mos individual o'quv rejasi",
                ),
                const SizedBox(height: 11),
                const _DarkFeature(
                  icon: Icons.mark_chat_read_rounded,
                  text: "Har bir mashqqa batafsil yozma feedback",
                ),
                const SizedBox(height: 11),
                const _DarkFeature(
                  icon: Icons.chat_bubble_rounded,
                  text: "Ilovada shaxsiy chat orqali qo'llab-quvvatlash",
                ),
                const SizedBox(height: 11),
                const _DarkFeature(
                  icon: Icons.laptop_rounded,
                  text: "To'liq platforma imkoniyatlari (video, AI, testlar)",
                ),
                const SizedBox(height: 26),
                // ── Testimonials ─────────────────────────────────────────
                _RowDivider(label: "O'QUVCHILAR AYTADI"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 152,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: _kTestimonials.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) =>
                        _TestimonialCard(data: _kTestimonials[i]),
                  ),
                ),
                // ── Pricing ──────────────────────────────────────────────
                if (!isSubscribed && plans.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  _RowDivider(label: 'NARXLAR'),
                  const SizedBox(height: 14),
                  for (final plan in plans)
                    _PlanPriceBlock(plan: plan, dark: true),
                ],
                // ── Subscribed badge ──────────────────────────────────────
                if (isSubscribed) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryLight,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Siz o'qituvchi dasturiga ulanganisiz",
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkFeature extends StatelessWidget {
  const _DarkFeature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        ),
      ],
    );
  }
}

// ─── Testimonial card ─────────────────────────────────────────────────────────

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.data});
  final _TData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(
                Icons.star_rounded,
                size: 13,
                color: Color(0xFFFBBF24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              '"${data.text}"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 12,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: data.color.withValues(alpha: 0.35)),
                ),
                alignment: Alignment.center,
                child: Text(
                  data.initial,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${data.result} · ${data.duration}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Plan price block + row ───────────────────────────────────────────────────

class _PlanPriceBlock extends StatelessWidget {
  const _PlanPriceBlock({required this.plan, required this.dark});
  final Plan plan;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (plan.prices.isEmpty) return const SizedBox.shrink();
    final popularIdx = plan.prices.length >= 2 ? 1 : -1;
    return Column(
      children: [
        for (var i = 0; i < plan.prices.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PriceRow(
              price: plan.prices[i],
              planName: plan.name.isEmpty ? 'Tarif' : plan.name,
              isPopular: i == popularIdx,
              dark: dark,
              hasMentor: plan.hasMentor,
            ),
          ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.planName,
    required this.dark,
    this.isPopular = false,
    this.hasMentor = false,
  });

  final PlanPrice price;
  final String planName;
  final bool dark;
  final bool isPopular;
  final bool hasMentor;

  // On iOS, platform (one-to-many) subscriptions must not go through in-app
  // payment — Apple guideline 3.1.3(d). Redirect to website instead.
  // Mentor plans are 1:1 person-to-person and are exempt (3.1.3(b)).
  bool get _iosWebRedirect => Platform.isIOS && !hasMentor;

  @override
  Widget build(BuildContext context) {
    final hasSaving = price.hasDiscount;
    final savingPct = hasSaving
        ? ((price.actualPrice - price.price) / price.actualPrice * 100).round()
        : 0;
    final perMonth = price.price / price.month;

    final bgColor = isPopular
        ? AppColors.primary.withValues(alpha: dark ? 0.18 : 0.1)
        : (dark ? Colors.white.withValues(alpha: 0.05) : Colors.white);
    final borderColor = isPopular
        ? AppColors.primary.withValues(alpha: 0.5)
        : (dark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0));
    final textColor = dark ? Colors.white : AppColors.textPrimary;
    final subColor = dark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return InkWell(
      onTap: () async {
        if (_iosWebRedirect) {
          final uri = Uri.parse(NetworkConfig.mainHostUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          return;
        }
        final paymentId = await PaymentTypesSheet.show(
          context,
          amount: price.price,
          title: '$planName · ${price.month} oy',
        );
        if (paymentId != null && context.mounted) {
          context.goNamed(AppRoute.main.name, extra: MainScreen.coursesTab);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${price.month} oylik obuna',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'MASHHUR',
                            style: TextStyle(
                              color: Color(0xFF1A1200),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      if (hasSaving)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            '-$savingPct%',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (price.month > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      "${_formatPrice(perMonth.round())}/oy",
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasSaving)
                  Text(
                    _formatPrice(price.actualPrice),
                    style: TextStyle(
                      color: subColor,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: subColor,
                    ),
                  ),
                Text(
                  _formatPrice(price.price),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: isPopular
                    ? AppColors.primary
                    : (dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Tanlash',
                style: TextStyle(
                  color: isPopular
                      ? Colors.white
                      : (dark
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppColors.primary),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Platform animated avatar ─────────────────────────────────────────────────

class _PlatformAvatar extends StatefulWidget {
  const _PlatformAvatar();

  @override
  State<_PlatformAvatar> createState() => _PlatformAvatarState();
}

class _PlatformAvatarState extends State<_PlatformAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  late final Animation<double> _float = Tween<double>(
    begin: -5.0,
    end: 5.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('📱', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}

// ─── Platform section ─────────────────────────────────────────────────────────

class _PlatformSection extends StatelessWidget {
  const _PlatformSection({required this.plans, required this.isSubscribed});

  final List<Plan> plans;
  final bool isSubscribed;

  static const _violet = Color(0xFF7C3AED);
  static const _violetLight = Color(0xFFA78BFA);
  static const _indigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0A1A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _violet.withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative glow circles
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _violet.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _indigo.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: badge + avatar ───────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _violet.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _violet.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 12,
                                  color: _violetLight,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'PLATFORMA',
                                  style: TextStyle(
                                    color: _violetLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "O'z tezligingizda —\nprofessional darajaga",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _PlatformAvatar(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "O'qituvchisiz ham muvaffaqiyat mumkin. AI va video kurslar bilan o'z jadvalingizda o'rganing.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                // ── 2×2 feature grid ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _PlatformFeatureCard(
                        icon: Icons.record_voice_over_rounded,
                        title: "AI Speaking",
                        subtitle: "Cheksiz muloqot",
                        color: _violetLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PlatformFeatureCard(
                        icon: Icons.play_circle_rounded,
                        title: "Video Kurslar",
                        subtitle: "Native speakerlar",
                        color: _indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PlatformFeatureCard(
                        icon: Icons.smart_toy_rounded,
                        title: "AI Yordamchi",
                        subtitle: "24/7 javob",
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PlatformFeatureCard(
                        icon: Icons.quiz_rounded,
                        title: "Mock Testlar",
                        subtitle: "IELTS & CEFR",
                        color: const Color(0xFFF472B6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // ── CEFR level chips ─────────────────────────────────────
                _RowDivider(label: 'DARAJALAR'),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final lvl in [
                        'A1',
                        'A2',
                        'B1',
                        'B2',
                        'C1',
                        'C2',
                      ]) ...[_LevelChip(level: lvl), const SizedBox(width: 8)],
                    ],
                  ),
                ),
                // ── Testimonials ─────────────────────────────────────────
                const SizedBox(height: 26),
                _RowDivider(label: "O'QUVCHILAR AYTADI"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 152,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: _kPlatformTestimonials.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) =>
                        _TestimonialCard(data: _kPlatformTestimonials[i]),
                  ),
                ),
                // ── Pricing ──────────────────────────────────────────────
                if (!isSubscribed && plans.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  _RowDivider(label: 'NARXLAR'),
                  const SizedBox(height: 14),
                  for (final plan in plans)
                    _PlanPriceBlock(plan: plan, dark: true),
                ],
                // ── Subscribed badge ──────────────────────────────────────
                if (isSubscribed) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _violet.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _violet.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: _violetLight,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Siz platforma obunasida",
                          style: TextStyle(
                            color: _violetLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformFeatureCard extends StatelessWidget {
  const _PlatformFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        level,
        style: const TextStyle(
          color: Color(0xFFA78BFA),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
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

// ─── Course cover ─────────────────────────────────────────────────────────────

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

String _formatPrice(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return "${buf.toString()} so'm";
}
