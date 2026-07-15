/// Parses the free-text `definition` field of a bundled dictionary entry
/// into a part of speech, a list of (possibly numbered) senses and any
/// `~`-headword phrase examples embedded in the source text, e.g.
/// "n olma; ~ pie olmali pirog." for the word "apple".
library;

const Map<String, String> _posLabels = {
  'adv': 'ravish',
  'pron': 'olmosh',
  'prep': "old ko'makchi",
  'pref': "old qo'shimcha",
  'num': 'son',
  'int': 'undov',
  'conj': "bog'lovchi",
  'cj': "bog'lovchi",
  'pl': "ko'plik",
  'n': 'ot',
  'v': "fe'l",
  'a': 'sifat',
};

final RegExp _posPattern = RegExp(
  '^(${_posLabels.keys.map(RegExp.escape).join('|')})\\.?\\s+',
);

final RegExp _formsPattern = RegExp(r'^\([^)]*\)\s*');
final RegExp _numberedSensePattern = RegExp(r'^(\d+)\)\s*(.*)$');
final RegExp _leadingJunkPattern = RegExp(r'^[^a-zA-Z0-9~]+');
final RegExp _trailingDotPattern = RegExp(r'\.+$');

class DefinitionSense {
  const DefinitionSense({required this.index, required this.text});

  /// The original `N)` marker, or null when the source text had no
  /// explicit numbering for this sense.
  final int? index;
  final String text;
}

class ParsedDefinition {
  const ParsedDefinition({
    required this.partOfSpeech,
    required this.senses,
    required this.relatedPhrases,
  });

  final String? partOfSpeech;
  final List<DefinitionSense> senses;
  final List<String> relatedPhrases;

  bool get hasMultipleSenses => senses.length > 1;
}

ParsedDefinition parseDefinition(String rawDefinition, String headword) {
  var text = rawDefinition.trim().replaceFirst(_leadingJunkPattern, '');

  String? partOfSpeech;
  final posMatch = _posPattern.firstMatch(text);
  if (posMatch != null) {
    partOfSpeech = _posLabels[posMatch.group(1)];
    text = text.substring(posMatch.end);
  }

  final formsMatch = _formsPattern.firstMatch(text);
  if (formsMatch != null) {
    text = text.substring(formsMatch.end);
  }

  final senses = <DefinitionSense>[];
  final relatedPhrases = <String>[];

  for (final rawClause in text.split(';')) {
    final trimmed = rawClause.trim();
    if (trimmed.isEmpty) continue;

    final numberedMatch = _numberedSensePattern.firstMatch(trimmed);
    if (numberedMatch != null) {
      final content = _clean(numberedMatch.group(2) ?? '', headword);
      if (content.isNotEmpty) {
        senses.add(
          DefinitionSense(
            index: int.tryParse(numberedMatch.group(1)!),
            text: content,
          ),
        );
      }
      continue;
    }

    if (trimmed.contains('~')) {
      final content = _clean(trimmed, headword);
      if (content.isNotEmpty) relatedPhrases.add(content);
      continue;
    }

    final content = _clean(trimmed, headword);
    if (content.isNotEmpty) {
      senses.add(DefinitionSense(index: null, text: content));
    }
  }

  if (senses.isEmpty && relatedPhrases.isEmpty) {
    final fallback = _clean(text, headword);
    if (fallback.isNotEmpty) {
      senses.add(DefinitionSense(index: null, text: fallback));
    }
  }

  return ParsedDefinition(
    partOfSpeech: partOfSpeech,
    senses: senses,
    relatedPhrases: relatedPhrases,
  );
}

String _clean(String text, String headword) {
  return text
      .replaceAll('~', headword)
      .replaceFirst(_trailingDotPattern, '')
      .trim();
}
