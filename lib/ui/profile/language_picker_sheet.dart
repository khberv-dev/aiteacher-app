import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/locale/presentation/locale_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeControllerProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l10n.settingsLanguageSheetTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _Option(
            flag: '🇺🇿',
            label: l10n.languageNameUzbek,
            selected: current?.languageCode == 'uz',
            onTap: () async {
              await ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(const Locale('uz'));
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
          _Option(
            flag: '🇬🇧',
            label: l10n.languageNameEnglish,
            selected: current?.languageCode == 'en',
            onTap: () async {
              await ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(const Locale('en'));
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySubtle : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
