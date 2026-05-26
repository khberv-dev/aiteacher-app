import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/speaking/report_grammar_page.dart';
import 'package:ai_teacher/ui/speaking/report_overview_page.dart';
import 'package:ai_teacher/ui/speaking/report_roadmap_page.dart';
import 'package:ai_teacher/ui/speaking/report_vocab_page.dart';
import 'package:ai_teacher/ui/speaking/widget/report_hero_card.dart';
import 'package:ai_teacher/ui/profile/subscription_details_sheet.dart';
import 'package:ai_teacher/ui/speaking/widget/report_top_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SpeakingReportScreen extends ConsumerWidget {
  const SpeakingReportScreen({super.key, required this.assessment});

  final Assessment assessment;

  static const _tabLabels = ["Ko'rish", "Lug'at", 'Grammatika', "Yo'l xarita"];

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.main.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final showUpsell = user?.activeSubscription == null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFECEAE3),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFECEAE3),
        body: SafeArea(
          bottom: false,
          child: DefaultTabController(
            length: _tabLabels.length,
            child: Column(
              children: [
                ReportTopNav(onBack: () => _onBack(context), onShare: () {}),
                ReportHeroCard(assessment: assessment),
                _SegmentedTabBar(labels: _tabLabels),
                Expanded(
                  child: TabBarView(
                    children: [
                      ReportOverviewPage(assessment: assessment),
                      ReportVocabPage(assessment: assessment),
                      ReportGrammarPage(assessment: assessment),
                      ReportRoadmapPage(assessment: assessment),
                    ],
                  ),
                ),
                if (showUpsell) const _UnlimitedReportsCta(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlimitedReportsCta extends StatelessWidget {
  const _UnlimitedReportsCta();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => SubscriptionDetailsSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Cheksiz to'liq hisobotlar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Pro paketga obuna bo'ling — barcha "
                        "hisobotlarni cheksiz oling",
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
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
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          isScrollable: false,
          labelPadding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: const Color(0xFF6B6860),
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
          tabs: [for (final label in labels) Tab(text: label, height: 36)],
        ),
      ),
    );
  }
}
