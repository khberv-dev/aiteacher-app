import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/dictionary/data/definition_parser.dart';
import 'package:ai_teacher/core/dictionary/data/dictionary_word_ref.dart';
import 'package:flutter/material.dart';

class DictionaryDefinitionSheet extends StatefulWidget {
  const DictionaryDefinitionSheet._({
    required this.wordRef,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final DictionaryWordRef wordRef;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  static Future<void> show(
    BuildContext context, {
    required DictionaryWordRef wordRef,
    required bool isSaved,
    required VoidCallback onToggleSaved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => DictionaryDefinitionSheet._(
        wordRef: wordRef,
        isSaved: isSaved,
        onToggleSaved: onToggleSaved,
      ),
    );
  }

  @override
  State<DictionaryDefinitionSheet> createState() =>
      _DictionaryDefinitionSheetState();
}

class _DictionaryDefinitionSheetState extends State<DictionaryDefinitionSheet> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  void _handleToggleSaved() {
    setState(() => _isSaved = !_isSaved);
    widget.onToggleSaved();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.wordRef.entry;
    final parsed = parseDefinition(entry.definition, entry.word);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  entry.word,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              IconButton(
                onPressed: _handleToggleSaved,
                icon: Icon(
                  _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _isSaved ? AppColors.primary : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          if (entry.phonetic.isNotEmpty || parsed.partOfSpeech != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
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
                  if (entry.phonetic.isNotEmpty && parsed.partOfSpeech != null)
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
            ),
          const SizedBox(height: 18),
          const _Label("TA'RIF"),
          const SizedBox(height: 6),
          if (parsed.senses.isNotEmpty)
            for (final sense in parsed.senses)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  sense.index != null
                      ? '${sense.index}) ${sense.text}'
                      : sense.text,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ta'rif topilmadi",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Yopish',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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
