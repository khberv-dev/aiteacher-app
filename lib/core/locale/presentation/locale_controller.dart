import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locales the app ships translations for, in the order offered by the
/// language picker.
const supportedAppLocales = [Locale('uz'), Locale('en')];

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(cacheServiceProvider).languageCode;
    if (code == null) return null;
    return supportedAppLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => supportedAppLocales.first,
    );
  }

  Future<void> setLocale(Locale locale) async {
    await ref.read(cacheServiceProvider).setLanguageCode(locale.languageCode);
    state = locale;
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
