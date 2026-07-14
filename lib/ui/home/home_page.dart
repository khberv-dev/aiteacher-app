import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:ai_teacher/ui/cashback/cashback_info_sheet.dart';
import 'package:ai_teacher/ui/home/widget/cashback_card.dart';
import 'package:ai_teacher/ui/home/widget/dictionary_card.dart';
import 'package:ai_teacher/ui/home/widget/home_header.dart';
import 'package:ai_teacher/ui/home/widget/live_card.dart';
import 'package:ai_teacher/ui/home/widget/mini_cards_row.dart';
import 'package:ai_teacher/ui/home/widget/page_dots.dart';
import 'package:ai_teacher/ui/home/widget/radar_card.dart';
import 'package:ai_teacher/ui/home/widget/section_header.dart';
import 'package:ai_teacher/ui/home/widget/stats_card.dart';
import 'package:ai_teacher/ui/home/widget/streak_card.dart';
import 'package:ai_teacher/ui/home/widget/writing_task_card.dart';
import 'package:ai_teacher/ui/shared/widget/feature_intro_overlay.dart';
import 'package:ai_teacher/ui/streak/streak_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _speakingKey = GlobalKey();
  final _vocabKey = GlobalKey();
  final _battleKey = GlobalKey();
  final _writingTaskKey = GlobalKey();
  final _cashbackKey = GlobalKey();

  OverlayEntry? _introEntry;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _introEntry?.remove();
    _introEntry = null;
    super.dispose();
  }

  void _maybeShowIntro() {
    if (!mounted || _introEntry != null) return;

    final steps = [
      IntroStep(
        targetKey: _speakingKey,
        title: 'AI Speaking Partner',
        description:
            "Sun'iy intellekt bilan ingliz tilida real suhbat quning. "
            "Talaffuzingizni baholang va nutq ko'nikmalaringizni tez "
            'rivojlantiring.',
        icon: Icons.record_voice_over_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.primarySubtle,
      ),
      IntroStep(
        targetKey: _vocabKey,
        title: "Kundalik Lug'atlar",
        description:
            "Har kuni yangi so'zlar o'rganing. Smart kartochkalar va "
            "intervalli takrorlash tizimi yordamida lug'atni kengaytiring.",
        icon: Icons.menu_book_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBackground: const Color(0xFFEFF6FF),
      ),
      IntroStep(
        targetKey: _battleKey,
        title: "So'z Jangi",
        description:
            "Boshqa o'quvchilar bilan real vaqtda so'z bilimingizni "
            "sinab ko'ring. G'olib bo'ling va reytingda tepaga chiqing!",
        icon: Icons.sports_esports_rounded,
        iconColor: const Color(0xFFDC2626),
        iconBackground: const Color(0xFFFEF2F2),
      ),
      IntroStep(
        targetKey: _writingTaskKey,
        title: 'AI Writing Task',
        description:
            "Yozish ko'nikmangizni sun'iy intellekt yordamida rivojlantiring. "
            'Topshiriqlarni bajaring va batafsil fikr-mulohaza oling.',
        icon: Icons.edit_note_rounded,
        iconColor: const Color(0xFF7C3AED),
        iconBackground: const Color(0xFFF5F3FF),
      ),
      IntroStep(
        targetKey: _cashbackKey,
        title: 'Cashback',
        description:
            "Har bir dars va topshiriq uchun cashback yig'ing. "
            "To'plangan cashbackni keyingi to'lovlarda ishlating.",
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF059669),
        iconBackground: const Color(0xFFECFDF5),
      ),
    ];

    _introEntry = OverlayEntry(
      builder: (_) =>
          FeatureIntroOverlay(steps: steps, onComplete: _finishIntro),
    );

    ref.read(introActiveProvider.notifier).state = true;
    Overlay.of(context).insert(_introEntry!);
  }

  void _finishIntro() {
    _introEntry?.remove();
    _introEntry = null;
    ref.read(introActiveProvider.notifier).state = false;
    ref.read(cacheServiceProvider).setIntroCompleted();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(introTriggerProvider, (_, _) => _maybeShowIntro());

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
                  key: _speakingKey,
                  onStart: () => context.pushNamed(AppRoute.speaking.name),
                ),
                MiniCardsRow(vocabularyKey: _vocabKey, battleKey: _battleKey),
                DictionaryCard(
                  onTap: () => context.pushNamed(AppRoute.dictionary.name),
                ),
                const SectionHeader(title: 'AI Writing Task'),
                WritingTaskCard(
                  key: _writingTaskKey,
                  onStart: () => context.pushNamed(AppRoute.writingTask.name),
                ),
                SectionHeader(
                  title: 'Cashback',
                  actionLabel: 'Batafsil →',
                  onAction: () => CashbackInfoSheet.show(context),
                ),
                CashbackCard(
                  key: _cashbackKey,
                  onTap: () => CashbackInfoSheet.show(context),
                ),
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
