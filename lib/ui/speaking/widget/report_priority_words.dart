import 'package:ai_teacher/ui/speaking/widget/report_section_label.dart';
import 'package:flutter/material.dart';

enum _ChipKind { yellow, blue, neutral }

class _WordChip {
  const _WordChip(this.label, this.kind);

  final String label;
  final _ChipKind kind;
}

class ReportPriorityWords extends StatelessWidget {
  const ReportPriorityWords({super.key, required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    final styled = <_WordChip>[
      for (var i = 0; i < words.length; i++)
        _WordChip(words[i], _kinds[i % _kinds.length]),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0A000000)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportSectionLabel(text: "B2 UCHUN ZARUR PRIORITY SO'ZLAR"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final w in styled) _Chip(word: w)],
            ),
            const SizedBox(height: 12),
            _Cta(total: words.length),
          ],
        ),
      ),
    );
  }

  static const _kinds = [
    _ChipKind.yellow,
    _ChipKind.blue,
    _ChipKind.neutral,
    _ChipKind.yellow,
    _ChipKind.blue,
    _ChipKind.neutral,
    _ChipKind.neutral,
    _ChipKind.blue,
  ];
}

class _Chip extends StatelessWidget {
  const _Chip({required this.word});

  final _WordChip word;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (word.kind) {
      _ChipKind.yellow => (
        const Color(0x1AF5B700),
        const Color(0xFF92400E),
        const Color(0x40F5B700),
      ),
      _ChipKind.blue => (
        const Color(0x143B82F6),
        const Color(0xFF1E40AF),
        const Color(0x333B82F6),
      ),
      _ChipKind.neutral => (
        const Color(0xFFFAF9F6),
        const Color(0xFF6B6860),
        const Color(0xFFEEEBE4),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Text(
        word.label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "📋  To'liq $total so'z ro'yxatini ko'rish",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}
