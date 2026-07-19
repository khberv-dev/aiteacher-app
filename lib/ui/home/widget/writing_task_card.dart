import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WritingTaskCard extends StatelessWidget {
  const WritingTaskCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF065F46), Color(0xFF059669)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Badge(),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeWritingCardTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.homeWritingCardSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StartPill(onTap: onStart),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.edit_note_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.homeWritingBadgeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StartPill extends StatelessWidget {
  const _StartPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeStartAction,
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
