import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class LiveCard extends StatelessWidget {
  const LiveCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: GestureDetector(
        onTap: onStart,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
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
                    const _LiveBadge(),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeLiveCardTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _StartPill(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _BotCircle(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulseDot(),
          const SizedBox(width: 5),
          Text(
            l10n.homeLiveBadgeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StartPill extends StatelessWidget {
  const _StartPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.homeStartAction,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
    );
  }
}

class _BotCircle extends StatelessWidget {
  const _BotCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: const Image(
        image: AssetImage('assets/images/ai_girl.png'),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }
}
