import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ReportFeedbackCard extends StatelessWidget {
  const ReportFeedbackCard({super.key, required this.feedback});

  final String feedback;

  @override
  Widget build(BuildContext context) {
    if (feedback.trim().isEmpty) return const SizedBox.shrink();

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
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🧑‍🏫', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'AI Mentor sharhi',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        "Suhbatga umumiy baho",
                        style: TextStyle(
                          color: Color(0xFF6B6860),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEBE4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '"',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MarkdownBody(
                    data: feedback,
                    softLineBreak: true,
                    shrinkWrap: true,
                    styleSheet: _markdownStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final MarkdownStyleSheet _markdownStyle = MarkdownStyleSheet(
  p: const TextStyle(
    color: Color(0xFF333333),
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.55,
  ),
  strong: const TextStyle(
    color: Color(0xFF111111),
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    height: 1.55,
  ),
  em: const TextStyle(
    color: Color(0xFF333333),
    fontSize: 12.5,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    height: 1.55,
  ),
  del: const TextStyle(
    color: Color(0xFFB91C1C),
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.55,
    decoration: TextDecoration.lineThrough,
    decorationColor: Color(0xFFB91C1C),
  ),
  h1: const TextStyle(
    color: Color(0xFF111111),
    fontSize: 16,
    fontWeight: FontWeight.w900,
    height: 1.3,
  ),
  h2: const TextStyle(
    color: Color(0xFF111111),
    fontSize: 14.5,
    fontWeight: FontWeight.w900,
    height: 1.3,
  ),
  h3: const TextStyle(
    color: Color(0xFF0D9488),
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
    height: 1.3,
  ),
  listBullet: const TextStyle(
    color: Color(0xFF6B6860),
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
  ),
  blockquote: const TextStyle(
    color: Color(0xFF555555),
    fontSize: 12.5,
    fontStyle: FontStyle.italic,
    height: 1.55,
  ),
  blockquoteDecoration: BoxDecoration(
    color: const Color(0xFFEFFCFA),
    borderRadius: BorderRadius.circular(8),
    border: const Border(left: BorderSide(color: Color(0xFF0D9488), width: 3)),
  ),
  blockquotePadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
  code: const TextStyle(
    color: Color(0xFF0F172A),
    backgroundColor: Color(0xFFEEF2FF),
    fontSize: 12,
    fontFamily: 'monospace',
    height: 1.45,
  ),
  codeblockDecoration: BoxDecoration(
    color: const Color(0xFFF1F5F9),
    borderRadius: BorderRadius.circular(8),
  ),
  blockSpacing: 8,
);
