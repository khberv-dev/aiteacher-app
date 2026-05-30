import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/call/presentation/call_controller.dart';
import 'package:ai_teacher/core/cashback/data/cashback_repository.dart';
import 'package:ai_teacher/core/streak/presentation/streak_check_in_controller.dart';
import 'package:ai_teacher/ui/blog/blog_page.dart' show CommentsPage;
import 'package:ai_teacher/ui/cashback/cashback_earned_toast.dart';
import 'package:ai_teacher/ui/chat/chat_list_page.dart';
import 'package:ai_teacher/ui/courses/courses_page.dart';
import 'package:ai_teacher/ui/home/home_page.dart';
import 'package:ai_teacher/ui/profile/profile_page.dart';
import 'package:ai_teacher/ui/shared/widget/app_bottom_nav.dart';
import 'package:ai_teacher/ui/streak/streak_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, this.initialTab = MainScreen.homeTab});

  static const int chatTab = 0;
  static const int coursesTab = 1;
  static const int homeTab = 2;
  static const int commentsTab = 3;
  static const int profileTab = 4;

  final int initialTab;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _activeTab = widget.initialTab;

  static const _pages = <Widget>[
    ChatListPage(),
    CoursesPage(),
    HomePage(),
    CommentsPage(),
    ProfilePage(),
  ];

  bool _cashbackToastShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.read(callControllerProvider.notifier).ensureListening();
      final streak = await ref
          .read(streakCheckInProvider.notifier)
          .runIfNeeded();
      if (!mounted) return;
      if (streak != null) {
        await StreakSheet.show(context);
        if (!mounted) return;
      }
      await _showCashbackToastIfAny();
    });
  }

  Future<void> _showCashbackToastIfAny() async {
    if (_cashbackToastShown) return;
    _cashbackToastShown = true;
    try {
      final cashbacks = await ref.read(cashbackRepositoryProvider).list();
      final unclaimed = cashbacks.where((c) => !c.claimed).toList();
      if (!mounted || unclaimed.isEmpty) return;
      await CashbackEarnedToast.show(context, unclaimed: unclaimed);
    } catch (_) {
      // Silent — the user will see cashbacks the next time they relaunch.
      _cashbackToastShown = false;
    }
  }

  void _onTabTap(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallState>(callControllerProvider, (prev, next) {
      final wasIdle = prev == null || prev.phase == CallPhase.idle;
      final isLive =
          next.phase == CallPhase.incoming ||
          next.phase == CallPhase.outgoing ||
          next.phase == CallPhase.connecting ||
          next.phase == CallPhase.active;
      if (wasIdle && isLive) {
        context.pushNamed(AppRoute.call.name);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: _activeTab, children: _pages),
        ),
        bottomNavigationBar: AppBottomNav(
          activeIndex: _activeTab,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}
