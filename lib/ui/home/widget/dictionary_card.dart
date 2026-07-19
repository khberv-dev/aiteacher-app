import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class DictionaryCard extends StatelessWidget {
  const DictionaryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                        l10n.homeDictionaryCardTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.homeDictionaryCardSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _OpenPill(onTap: onTap),
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
                    Icons.translate_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
        l10n.homeDictionaryBadgeLabel,
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

class _OpenPill extends StatelessWidget {
  const _OpenPill({required this.onTap});

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
                l10n.homeDictionaryOpenAction,
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
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
