import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/dictionary/data/definition_parser.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_entry.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_search.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_mark.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_ref.dart';
import 'package:ai_teacher/core/dictionary/presentation/dictionary_providers.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DictionarySearchScreen extends ConsumerStatefulWidget {
  const DictionarySearchScreen({super.key});

  @override
  ConsumerState<DictionarySearchScreen> createState() =>
      _DictionarySearchScreenState();
}

class _DictionarySearchScreenState
    extends ConsumerState<DictionarySearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectWord(String word) {
    _controller.text = word;
    _controller.selection = TextSelection.collapsed(offset: word.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final direction = ref.watch(dictionaryDirectionProvider);
    final entriesAsync = ref.watch(dictionaryEntriesProvider(direction));
    final query = _controller.text;

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
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: entriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      Center(child: Text(l10n.dictionaryLoadError)),
                  data: (entries) {
                    if (query.trim().isEmpty) {
                      return const _PromptState();
                    }
                    final matches = searchDictionaryEntries(entries, query);
                    if (matches.isEmpty) {
                      return const _NotFoundState();
                    }
                    final best = matches.first;
                    final others = matches.skip(1).take(8).toList();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _WordDetailCard(entry: best, direction: direction),
                        const SizedBox(height: 20),
                        _SimilarResults(
                          entry: best,
                          others: others,
                          onSelect: _selectWord,
                        ),
                      ],
                    );
                  },
                ),
              ),
              _SearchField(
                controller: _controller,
                direction: direction,
                onToggleDirection: () {
                  ref
                      .read(dictionaryDirectionProvider.notifier)
                      .state = direction == DictionaryDirection.enToUz
                      ? DictionaryDirection.uzToEn
                      : DictionaryDirection.enToUz;
                },
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.dictionarySearchTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptState extends StatelessWidget {
  const _PromptState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.dictionaryEnterWordPrompt,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n.dictionaryNotFound,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WordDetailCard extends ConsumerWidget {
  const _WordDetailCard({required this.entry, required this.direction});

  final DictionaryEntry entry;
  final DictionaryDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final parsed = parseDefinition(entry.definition, entry.word);
    final key = markKeyFor(direction, entry.word, entry.definition);
    final savedMarks =
        ref
            .watch(dictionaryMarksControllerProvider(DictionaryMarkKind.saved))
            .valueOrNull ??
        const [];
    final learnedMarks =
        ref
            .watch(
              dictionaryMarksControllerProvider(DictionaryMarkKind.learned),
            )
            .valueOrNull ??
        const [];
    final isSaved = savedMarks.any((m) => m.key == key);
    final isLearned = learnedMarks.any((m) => m.key == key);
    final wordRef = DictionaryWordRef(entry: entry, direction: direction);

    final headline = parsed.senses.isNotEmpty
        ? parsed.senses.first.text
        : entry.definition;
    final extraSenses = parsed.senses.length > 1
        ? parsed.senses.sublist(1)
        : const <DefinitionSense>[];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (entry.phonetic.isNotEmpty)
                          Text(
                            '/${entry.phonetic}/',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        if (entry.phonetic.isNotEmpty &&
                            parsed.partOfSpeech != null)
                          const Text(
                            '  ·  ',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        if (parsed.partOfSpeech != null)
                          Text(
                            parsed.partOfSpeech!,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.dictionaryAudioComingSoon)),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            headline,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (extraSenses.isNotEmpty) ...[
            const Divider(height: 28, color: Color(0xFFE2E8F0)),
            _Label(l10n.dictionaryNoteLabel),
            const SizedBox(height: 6),
            for (final sense in extraSenses)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  sense.index != null
                      ? '${sense.index}) ${sense.text}'
                      : sense.text,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: isSaved ? l10n.dictionarySavedButton : l10n.commonSave,
                  icon: isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  filled: true,
                  onTap: () => ref
                      .read(
                        dictionaryMarksControllerProvider(
                          DictionaryMarkKind.saved,
                        ).notifier,
                      )
                      .toggle(wordRef),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: l10n.dictionaryLearnedButton,
                  icon: Icons.check_rounded,
                  filled: false,
                  active: isLearned,
                  onTap: () => ref
                      .read(
                        dictionaryMarksControllerProvider(
                          DictionaryMarkKind.learned,
                        ).notifier,
                      )
                      .toggle(wordRef),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showFilled = filled || active;
    return Material(
      color: showFilled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: showFilled
                ? null
                : Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: showFilled ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: showFilled ? Colors.white : AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _SimilarResults extends StatelessWidget {
  const _SimilarResults({
    required this.entry,
    required this.others,
    required this.onSelect,
  });

  final DictionaryEntry entry;
  final List<DictionaryEntry> others;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parsed = parseDefinition(entry.definition, entry.word);
    final hasPhrases = parsed.relatedPhrases.isNotEmpty;
    final hasOthers = others.isNotEmpty;
    if (!hasPhrases && !hasOthers) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.dictionarySimilarResultsLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final phrase in parsed.relatedPhrases)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                phrase,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        for (final other in others)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SimilarRow(entry: other, onTap: () => onSelect(other.word)),
          ),
      ],
    );
  }
}

class _SimilarRow extends StatelessWidget {
  const _SimilarRow({required this.entry, required this.onTap});

  final DictionaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parsed = parseDefinition(entry.definition, entry.word);
    final translation = parsed.senses.isNotEmpty
        ? parsed.senses.first.text
        : entry.definition;

    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: entry.word),
                      TextSpan(
                        text: ' — $translation',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.direction,
    required this.onToggleDirection,
  });

  final TextEditingController controller;
  final DictionaryDirection direction;
  final VoidCallback onToggleDirection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: l10n.dictionarySearchWordHint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: controller.clear,
                ),
              GestureDetector(
                onTap: onToggleDirection,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
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
              ),
            ],
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
