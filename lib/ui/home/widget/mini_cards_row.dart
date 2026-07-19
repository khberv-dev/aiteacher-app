import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/vocabulary/vocabulary_intro_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MiniCardsRow extends StatelessWidget {
  const MiniCardsRow({super.key, this.vocabularyKey, this.battleKey});

  final GlobalKey? vocabularyKey;
  final GlobalKey? battleKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              key: vocabularyKey,
              icon: Icons.menu_book_outlined,
              titleLines: l10n.homeVocabMiniCardTitle.split('\n'),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              shadowColor: const Color(0x522563EB),
              onTap: () => VocabularyIntroSheet.show(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              key: battleKey,
              icon: Icons.sports_esports_outlined,
              titleLines: l10n.homeBattleMiniCardTitle.split('\n'),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9A3412), Color(0xFFDC2626)],
              ),
              shadowColor: const Color(0x52DC2626),
              onTap: () => context.pushNamed(AppRoute.wordBattle.name),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    super.key,
    required this.icon,
    required this.titleLines,
    required this.gradient,
    required this.shadowColor,
    this.onTap,
  });

  final IconData icon;
  final List<String> titleLines;
  final Gradient gradient;
  final Color shadowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 28),
              for (final line in titleLines)
                Text(
                  line,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
