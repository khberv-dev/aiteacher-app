import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/dictionary/data/definition_parser.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_ref.dart';
import 'package:ai_teacher/core/dictionary/presentation/dictionary_providers.dart';
import 'package:ai_teacher/ui/dictionary/widget/dictionary_definition_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _SavedFilter { all, today, week }

enum _SortMode { newest, alphabetical }

class DictionarySavedWordsScreen extends ConsumerStatefulWidget {
  const DictionarySavedWordsScreen({super.key});

  @override
  ConsumerState<DictionarySavedWordsScreen> createState() =>
      _DictionarySavedWordsScreenState();
}

class _DictionarySavedWordsScreenState
    extends ConsumerState<DictionarySavedWordsScreen> {
  _SavedFilter _filter = _SavedFilter.all;
  _SortMode _sort = _SortMode.newest;

  @override
  Widget build(BuildContext context) {
    final marksAsync = ref.watch(
      dictionaryMarksControllerProvider(DictionaryMarkKind.saved),
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
          child: marksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Yuklanmadi')),
            data: (marks) {
              final now = DateTime.now();
              final todayCount = marks
                  .where((m) => _isSameDay(m.markedAt, now))
                  .length;
              final weekCount = marks
                  .where((m) => now.difference(m.markedAt).inDays < 7)
                  .length;

              var visible = switch (_filter) {
                _SavedFilter.all => marks,
                _SavedFilter.today =>
                  marks.where((m) => _isSameDay(m.markedAt, now)).toList(),
                _SavedFilter.week =>
                  marks
                      .where((m) => now.difference(m.markedAt).inDays < 7)
                      .toList(),
              };
              visible = [...visible];
              if (_sort == _SortMode.newest) {
                visible.sort((a, b) => b.markedAt.compareTo(a.markedAt));
              } else {
                visible.sort(
                  (a, b) =>
                      a.word.toLowerCase().compareTo(b.word.toLowerCase()),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: _Header(
                      count: marks.length,
                      onBack: () => Navigator.of(context).pop(),
                      onSort: () => _showSortSheet(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: _FilterRow(
                      filter: _filter,
                      allCount: marks.length,
                      todayCount: todayCount,
                      weekCount: weekCount,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _SavedWordRow(mark: visible[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "Saralash",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _SortOption(
              label: 'Yangi qo\'shilganlar',
              selected: _sort == _SortMode.newest,
              onTap: () {
                setState(() => _sort = _SortMode.newest);
                Navigator.of(context).pop();
              },
            ),
            _SortOption(
              label: 'Alifbo bo\'yicha (A-Z)',
              selected: _sort == _SortMode.alphabetical,
              onTap: () {
                setState(() => _sort = _SortMode.alphabetical);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.onBack,
    required this.onSort,
  });

  final int count;
  final VoidCallback onBack;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kunlik lug'atim",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$count ta saqlangan so\'z',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onSort,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.tune_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.allCount,
    required this.todayCount,
    required this.weekCount,
    required this.onChanged,
  });

  final _SavedFilter filter;
  final int allCount;
  final int todayCount;
  final int weekCount;
  final ValueChanged<_SavedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Barchasi $allCount',
          selected: filter == _SavedFilter.all,
          onTap: () => onChanged(_SavedFilter.all),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Bugun $todayCount',
          selected: filter == _SavedFilter.today,
          onTap: () => onChanged(_SavedFilter.today),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Hafta $weekCount',
          selected: filter == _SavedFilter.week,
          onTap: () => onChanged(_SavedFilter.week),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF0F172A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedWordRow extends ConsumerWidget {
  const _SavedWordRow({required this.mark});

  final DictionaryWordMark mark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = DictionaryEntry(word: mark.word, definition: mark.definition);
    final parsed = parseDefinition(entry.definition, entry.word);
    final translation = parsed.senses.isNotEmpty
        ? parsed.senses.first.text
        : entry.definition;
    final wordRef = DictionaryWordRef(entry: entry, direction: mark.direction);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DictionaryDefinitionSheet.show(
          context,
          wordRef: wordRef,
          isSaved: true,
          onToggleSaved: () => ref
              .read(
                dictionaryMarksControllerProvider(
                  DictionaryMarkKind.saved,
                ).notifier,
              )
              .toggle(wordRef),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        if (entry.phonetic.isNotEmpty) '/${entry.phonetic}/',
                        translation,
                      ].join(' · '),
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
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Audio talaffuz tez kunda qo'shiladi"),
                  ),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Hali saqlangan so'z yo'q",
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
