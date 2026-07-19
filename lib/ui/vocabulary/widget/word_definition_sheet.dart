import 'package:ai_teacher/core/vocabulary/data/vocabulary_word.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WordDefinitionSheet extends StatelessWidget {
  const WordDefinitionSheet._({required this.word});

  final VocabularyWord word;

  static Future<void> show(BuildContext context, VocabularyWord word) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => WordDefinitionSheet._(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDefinition =
        word.definition != null && word.definition!.isNotEmpty;
    final hasExample =
        word.exampleSentence != null && word.exampleSentence!.isNotEmpty;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  word.cefrLevel.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  word.word,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          if (hasDefinition) ...[
            const SizedBox(height: 18),
            _Label(l10n.vocabularyDefinitionLabel),
            const SizedBox(height: 6),
            Text(
              word.definition!,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
          if (!hasDefinition) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.vocabularyDefinitionPreparing,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasExample) ...[
            const SizedBox(height: 18),
            _Label(l10n.vocabularyExampleLabel),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '"${word.exampleSentence!}"',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ),
          ],
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
              child: Text(
                l10n.commonClose,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
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
