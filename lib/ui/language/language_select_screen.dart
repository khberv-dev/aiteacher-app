import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/locale/presentation/locale_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/onboarding/widget/welcome_cta.dart';
import 'package:ai_teacher/ui/onboarding/widget/welcome_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  late Locale _selected;

  @override
  void initState() {
    super.initState();
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    _selected = supportedAppLocales.firstWhere(
      (l) => l.languageCode == deviceLocale.languageCode,
      orElse: () => supportedAppLocales.first,
    );
  }

  Future<void> _continue() async {
    await ref.read(localeControllerProvider.notifier).setLocale(_selected);
    if (!mounted) return;
    final hasAccessToken =
        (ref.read(cacheServiceProvider).accessToken ?? '').isNotEmpty;
    if (hasAccessToken) {
      context.goNamed(AppRoute.main.name);
    } else {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.navy,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(alignment: Alignment.center, child: WelcomeLogo()),
                const SizedBox(height: 56),
                Text(
                  l10n.languageSelectTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.languageSelectSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8FA3B5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                _LanguageOption(
                  flag: '🇺🇿',
                  label: l10n.languageNameUzbek,
                  selected: _selected.languageCode == 'uz',
                  onTap: () => setState(() => _selected = const Locale('uz')),
                ),
                const SizedBox(height: 12),
                _LanguageOption(
                  flag: '🇬🇧',
                  label: l10n.languageNameEnglish,
                  selected: _selected.languageCode == 'en',
                  onTap: () => setState(() => _selected = const Locale('en')),
                ),
                const Spacer(),
                WelcomeCta(
                  label: l10n.languageSelectContinue,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
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
      color: selected
          ? AppColors.primary.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLight
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected
                    ? AppColors.primaryLight
                    : Colors.white.withValues(alpha: 0.2),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
