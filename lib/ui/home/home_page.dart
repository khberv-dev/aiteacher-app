import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/home/widget/cashback_card.dart';
import 'package:ai_teacher/ui/home/widget/home_header.dart';
import 'package:ai_teacher/ui/home/widget/live_card.dart';
import 'package:ai_teacher/ui/home/widget/mini_cards_row.dart';
import 'package:ai_teacher/ui/home/widget/page_dots.dart';
import 'package:ai_teacher/ui/home/widget/radar_card.dart';
import 'package:ai_teacher/ui/home/widget/section_header.dart';
import 'package:ai_teacher/ui/home/widget/stats_card.dart';
import 'package:ai_teacher/ui/home/widget/streak_card.dart';
import 'package:ai_teacher/ui/home/widget/writing_task_card.dart';
import 'package:ai_teacher/ui/streak/streak_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(currentUserProvider).valueOrNull?.firstName;
    final greeting = firstName == null || firstName.isEmpty
        ? 'Salom 👋'
        : 'Salom, $firstName 👋';
    return Column(
      children: [
        const HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Text(
                    greeting,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const RadarCard(),
                SectionHeader(
                  title: 'Streak',
                  actionLabel: 'Batafsil →',
                  onAction: () => StreakSheet.show(context),
                ),
                const StreakCard(),
                const SectionHeader(title: 'AI bilan suhbat'),
                LiveCard(
                  onStart: () => context.pushNamed(AppRoute.speaking.name),
                ),
                const MiniCardsRow(),
                const SectionHeader(title: 'AI Writing Task'),
                WritingTaskCard(
                  onStart: () => context.pushNamed(AppRoute.writingTask.name),
                ),
                const SectionHeader(title: 'Cashback'),
                const CashbackCard(),
                const SectionHeader(title: "Mening o'sishim raqamlarda"),
                const StatsCard(),
                const PageDots(length: 4, activeIndex: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
