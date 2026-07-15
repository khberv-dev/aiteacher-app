import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/dictionary/data/definition_parser.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:ai_teacher/core/dictionary/presentation/dictionary_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DictionaryStatsScreen extends ConsumerWidget {
  const DictionaryStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(
      dictionaryMarksControllerProvider(DictionaryMarkKind.saved),
    );
    final learnedAsync = ref.watch(
      dictionaryMarksControllerProvider(DictionaryMarkKind.learned),
    );

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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _Header(onBack: () => Navigator.of(context).pop()),
              ),
              Expanded(
                child: savedAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(child: Text('Yuklanmadi')),
                  data: (saved) {
                    final learned = learnedAsync.valueOrNull ?? const [];
                    final learnedCount = learned.length;
                    final savedCount = saved.length;
                    final ratio = savedCount == 0
                        ? 0.0
                        : (learnedCount / savedCount).clamp(0, 1).toDouble();
                    final needCount = savedCount - learnedCount;
                    final sortedLearned = [...learned]
                      ..sort((a, b) => b.markedAt.compareTo(a.markedAt));

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _ProgressCard(
                          learnedCount: learnedCount,
                          savedCount: savedCount,
                          ratio: ratio,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _PillStat(
                                icon: Icons.check_circle_rounded,
                                iconColor: AppColors.primary,
                                label: "O'rganilgan $learnedCount",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PillStat(
                                icon: Icons.access_time_rounded,
                                iconColor: const Color(0xFFD97706),
                                label: 'Kerak ${needCount < 0 ? 0 : needCount}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (sortedLearned.isEmpty)
                          const _EmptyState()
                        else
                          for (final mark in sortedLearned)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LearnedWordRow(mark: mark),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onBack,
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
        const SizedBox(width: 12),
        const Text(
          "Mening so'zlarim",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.learnedCount,
    required this.savedCount,
    required this.ratio,
  });

  final int learnedCount;
  final int savedCount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final percent = (ratio * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Saqlangan so'zlardan o'rganildi",
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (savedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$learnedCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                " / $savedCount so'z",
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: savedCount == 0 ? 0 : ratio,
              minHeight: 8,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnedWordRow extends StatelessWidget {
  const _LearnedWordRow({required this.mark});

  final DictionaryWordMark mark;

  @override
  Widget build(BuildContext context) {
    final entry = DictionaryEntry(word: mark.word, definition: mark.definition);
    final parsed = parseDefinition(entry.definition, entry.word);
    final translation = parsed.senses.isNotEmpty
        ? parsed.senses.first.text
        : entry.definition;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.word,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
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
          Text(
            _relativeTime(mark.markedAt),
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime date) {
  final days = DateTime.now().difference(date).inDays;
  if (days <= 0) return 'Bugun';
  if (days == 1) return 'Kecha';
  return '$days kun oldin';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          "Hali o'rganilgan so'z yo'q",
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
