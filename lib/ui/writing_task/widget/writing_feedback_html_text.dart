import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class WritingFeedbackHtmlText extends StatelessWidget {
  const WritingFeedbackHtmlText({super.key, required this.feedback});

  final String feedback;

  static const _base = TextStyle(
    color: Color(0xFF1E293B),
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.55,
  );

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: feedback,
      styleSheet: MarkdownStyleSheet(
        p: _base,
        strong: _base.copyWith(fontWeight: FontWeight.w700),
        em: _base.copyWith(fontStyle: FontStyle.italic),
        h3: _base.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
        listBullet: _base,
        blockSpacing: 4,
      ),
    );
  }
}
