import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VocabularyIntroSheet extends StatelessWidget {
  const VocabularyIntroSheet._({required this.onStart});

  final VoidCallback onStart;

  static Future<void> show(BuildContext context) {
    final router = GoRouter.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => VocabularyIntroSheet._(
        onStart: () => router.goNamed(AppRoute.vocabularyTraining.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.vocabularyTitle,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.vocabularyIntroSubtitle,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionTitle(l10n.vocabularyHowItWorksTitle),
                    const SizedBox(height: 14),
                    _StepCard(
                      icon: '📖',
                      title: l10n.vocabularyStep1Title,
                      body: l10n.vocabularyStep1Body,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      icon: '🎙️',
                      title: l10n.vocabularyStep2Title,
                      body: l10n.vocabularyStep2Body,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      icon: '🤖',
                      title: l10n.vocabularyStep3Title,
                      body: l10n.vocabularyStep3Body,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      icon: '✅',
                      title: l10n.vocabularyStep4Title,
                      body: l10n.vocabularyStep4Body,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(l10n.vocabularyExtraButtonsTitle),
                    const SizedBox(height: 14),
                    _ButtonInfoCard(
                      emoji: '👍',
                      color: const Color(0xFF16A34A),
                      bg: const Color(0xFFF0FDF4),
                      borderColor: const Color(0xFFBBF7D0),
                      title: l10n.vocabularySkipButtonTitle,
                      body: l10n.vocabularySkipButtonBody,
                    ),
                    const SizedBox(height: 10),
                    _ButtonInfoCard(
                      emoji: '🤷',
                      color: const Color(0xFFB91C1C),
                      bg: const Color(0xFFFEF2F2),
                      borderColor: const Color(0xFFFECACA),
                      title: l10n.vocabularyDefinitionButtonTitle,
                      body: l10n.vocabularyDefinitionButtonBody,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStart();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.vocabularyStart,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final String icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonInfoCard extends StatelessWidget {
  const _ButtonInfoCard({
    required this.emoji,
    required this.color,
    required this.bg,
    required this.borderColor,
    required this.title,
    required this.body,
  });

  final String emoji;
  final Color color;
  final Color bg;
  final Color borderColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
