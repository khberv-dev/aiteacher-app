import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/dictionary/data/definition_parser.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:ai_teacher/core/dictionary/presentation/dictionary_providers.dart';
import 'package:ai_teacher/core/streak/presentation/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DictionaryHomeScreen extends ConsumerWidget {
  const DictionaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(weeklyStreakProvider).valueOrNull?.currentStreak;
    final saved =
        ref
            .watch(dictionaryMarksControllerProvider(DictionaryMarkKind.saved))
            .valueOrNull ??
        const [];
    final learned =
        ref
            .watch(
              dictionaryMarksControllerProvider(DictionaryMarkKind.learned),
            )
            .valueOrNull ??
        const [];
    final needCount = saved.length - learned.length;
    final dailyWords = ref.watch(dictionaryDailyWordsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BackButton(
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 4),
                      _Header(streak: streak ?? 0),
                      const SizedBox(height: 20),
                      _FeatureTilesRow(
                        onSaved: () => context.pushNamed(
                          AppRoute.dictionarySavedWords.name,
                        ),
                        onExplanatory: () => context.pushNamed(
                          AppRoute.dictionaryExplanatory.name,
                        ),
                        onAudio: () =>
                            _showComingSoon(context, 'Audio lug\'at'),
                      ),
                      const SizedBox(height: 26),
                      _SectionHeader(
                        title: "Mening so'zlarim",
                        actionLabel: 'Barchasi',
                        onAction: () =>
                            context.pushNamed(AppRoute.dictionaryStats.name),
                      ),
                      const SizedBox(height: 10),
                      _MyWordsRow(
                        learnedCount: learned.length,
                        needCount: needCount < 0 ? 0 : needCount,
                      ),
                      const SizedBox(height: 26),
                      const _SectionHeader(title: "Bugungi so'zlar"),
                      const SizedBox(height: 10),
                      dailyWords.when(
                        data: (words) => words.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  for (final entry in words) ...[
                                    _TodayWordCard(entry: entry),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              _SearchBar(
                direction: ref.watch(dictionaryDirectionProvider),
                onTap: () => context.pushNamed(AppRoute.dictionarySearch.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("$feature tez kunda qo'shiladi")));
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            "Lug'at",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
        ),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FeatureTilesRow extends StatelessWidget {
  const _FeatureTilesRow({
    required this.onSaved,
    required this.onExplanatory,
    required this.onAudio,
  });

  final VoidCallback onSaved;
  final VoidCallback onExplanatory;
  final VoidCallback onAudio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FeatureTile(
            icon: Icons.bookmark_outline_rounded,
            label: "Kunlik\nlug'atim",
            onTap: onSaved,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(
            icon: Icons.menu_book_outlined,
            label: "Izohli\nlug'at",
            onTap: onExplanatory,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(
            icon: Icons.headphones_rounded,
            label: 'Audio\nlug\'at',
            onTap: onAudio,
            badge: 'Tez kunda',
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                Text(
                  badge!,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _MyWordsRow extends StatelessWidget {
  const _MyWordsRow({required this.learnedCount, required this.needCount});

  final int learnedCount;
  final int needCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primary,
            iconBackground: AppColors.primarySubtle,
            value: '$learnedCount',
            label: "O'rganilgan",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFD97706),
            iconBackground: const Color(0xFFFEF3C7),
            value: '$needCount',
            label: "O'rganishim kerak",
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWordCard extends StatelessWidget {
  const _TodayWordCard({required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final parsed = parseDefinition(entry.definition, entry.word);
    final translation = parsed.senses.isNotEmpty
        ? parsed.senses.first.text
        : entry.definition;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.word,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  translation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showComingSoon(context, 'Audio talaffuz'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.volume_up_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.direction, required this.onTap});

  final DictionaryDirection direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "So'z qidiring...",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    direction.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
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
