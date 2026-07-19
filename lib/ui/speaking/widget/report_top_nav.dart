import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ReportTopNav extends StatelessWidget {
  const ReportTopNav({super.key, required this.onBack, required this.onShare});

  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          _LightChip(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.speakingReportTopNavTitle,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _DarkChip(icon: Icons.ios_share_rounded, onTap: onShare),
        ],
      ),
    );
  }
}

class _LightChip extends StatelessWidget {
  const _LightChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 16),
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F172A),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 15),
        ),
      ),
    );
  }
}
