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

class DictionaryExplanatoryScreen extends ConsumerStatefulWidget {
  const DictionaryExplanatoryScreen({super.key});

  @override
  ConsumerState<DictionaryExplanatoryScreen> createState() =>
      _DictionaryExplanatoryScreenState();
}

class _DictionaryExplanatoryScreenState
    extends ConsumerState<DictionaryExplanatoryScreen> {
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
                    final matches = searchDictionaryEntries(entries, query);
                    if (matches.isEmpty) {
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
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _ExplanatoryCard(
                          entry: matches.first,
                          direction: direction,
                        ),
                      ],
                    );
                  },
                ),
              ),
              _SearchField(controller: _controller),
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
            l10n.dictionaryExplanatoryTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanatoryCard extends ConsumerWidget {
  const _ExplanatoryCard({required this.entry, required this.direction});

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
    final isSaved = savedMarks.any((m) => m.key == key);
    final wordRef = DictionaryWordRef(entry: entry, direction: direction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                    child: Text(
                      entry.word,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.dictionaryAudioComingSoon),
                            ),
                          ),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.phonetic.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '/${entry.phonetic}/',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (parsed.partOfSpeech != null)
                    _Pill(text: parsed.partOfSpeech!),
                  if (parsed.hasMultipleSenses)
                    _Pill(
                      text: l10n.dictionarySensesCount(parsed.senses.length),
                    ),
                ],
              ),
              const Divider(height: 28, color: Color(0xFFE2E8F0)),
              for (var i = 0; i < parsed.senses.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == parsed.senses.length - 1 ? 0 : 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          parsed.senses[i].text,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dictionarySynonymsLabel,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.dictionaryComingSoonLabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => ref
                .read(
                  dictionaryMarksControllerProvider(
                    DictionaryMarkKind.saved,
                  ).notifier,
                )
                .toggle(wordRef),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
            ),
            label: Text(
              isSaved
                  ? l10n.dictionaryInMyDictionary
                  : l10n.dictionaryAddToMyDictionary,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

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
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: controller.clear,
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
