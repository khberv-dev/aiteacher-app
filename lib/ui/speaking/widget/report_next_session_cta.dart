import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ReportNextSessionCta extends StatelessWidget {
  const ReportNextSessionCta({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, Color(0xFF0F766E)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.speakingReportNextSessionTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.speakingReportNextSessionSubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onStart,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Center(
                    child: Text(
                      l10n.speakingReportNextSessionButton,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
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
