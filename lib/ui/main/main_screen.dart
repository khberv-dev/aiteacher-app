import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/call/presentation/call_controller.dart';
import 'package:ai_teacher/ui/blog/blog_page.dart';
import 'package:ai_teacher/ui/chat/chat_list_page.dart';
import 'package:ai_teacher/ui/home/home_page.dart';
import 'package:ai_teacher/ui/lessons/lessons_page.dart';
import 'package:ai_teacher/ui/profile/profile_page.dart';
import 'package:ai_teacher/ui/shared/widget/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, this.initialTab = MainScreen.homeTab});

  static const int chatTab = 0;
  static const int lessonsTab = 1;
  static const int homeTab = 2;
  static const int blogTab = 3;
  static const int profileTab = 4;

  final int initialTab;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _activeTab = widget.initialTab;

  static const _pages = <Widget>[
    ChatListPage(),
    LessonsPage(),
    HomePage(),
    BlogPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(callControllerProvider.notifier).ensureListening();
    });
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
