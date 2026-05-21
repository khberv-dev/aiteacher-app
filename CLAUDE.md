# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app named `ai_teacher` (Dart SDK `^3.11.5`). Targets all six Flutter platforms — `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` directories are present and should stay buildable.

Stack: `flutter_riverpod` (state), `go_router` (nav), `dio` + `talker_dio_logger` (network/logging), `shared_preferences` (persistence).

## Architecture

Clean-architecture layout under `lib/`:

```
lib/
├── main.dart                    # bootstraps SharedPreferences + ProviderScope
├── app.dart                     # MaterialApp.router
├── app/                         # app-wide infrastructure
│   ├── router/                  # go_router config (AppRoute enum + routerProvider)
│   ├── theme/                   # AppColors, AppRadius, AppTheme (light only)
│   └── data/                    # NetworkConfig, dioProvider, AuthInterceptor, CacheService
├── core/<feature>/              # business logic per feature
│   ├── data/                    # repositories, dtos, datasources
│   ├── domain/                  # entities, use cases
│   └── presentation/            # Riverpod controllers / Notifiers (no widgets)
├── ui/<feature>/                # widgets per feature
│   ├── <feature>_screen.dart    # screen / page / dialog files live HERE — NOT in a screen/ subfolder
│   └── widget/                  # feature-local reusable widgets
├── ui/shared/                   # globally reusable dialogs
│   └── widget/                  # globally reusable widgets
└── utils/                       # extensions, formatters, helpers
```

## Conventions

- **No `screen/` subfolder under `ui/<feature>/`.** Screen, page, and dialog files go directly in the feature folder (e.g. `lib/ui/onboarding/onboarding_screen.dart`, not `lib/ui/onboarding/screen/onboarding_screen.dart`). Only `widget/` lives one level deeper for feature-local reusables.
- **One widget per screen/page/dialog file.** A `*_screen.dart` / `*_page.dart` / `*_dialog.dart` at the root of a feature folder must contain exactly one public widget — the screen / page / dialog itself (its private `State` class is fine). Every other widget used inside that screen — even single-use helpers — must be extracted to `lib/ui/<feature>/widget/`. Inside a `widget/` file, an internal helper that's only used by that file's main widget may stay as a private (`_`-prefixed) class in the same file.
- **Where to place a widget by reuse**:
  - Used in **one** feature only → `lib/ui/<feature>/widget/`.
  - Used in **two or more** features, or generically reusable (buttons, inputs, etc.) → `lib/ui/shared/widget/`.
- **Absolute imports only** — use `package:ai_teacher/...` everywhere. No `'../foo.dart'` or sibling-file `'foo.dart'` imports.
- **Riverpod controllers live in `core/<feature>/presentation/`**, never in `ui/`.
- **`SharedPreferences` is bootstrapped in `main()`** and injected by overriding `sharedPreferencesProvider`. All key-value reads/writes go through `CacheService` (`cacheServiceProvider`), not `SharedPreferences` directly.
- **Light theme only.** Component styles (TextField, FilledButton, IconButton, Card) are centralized in `AppTheme.light` and pull from `AppColors` / `AppRadius`.
- **Dio**: there are two providers — `dioProvider` (auth-aware, used by features) and a private `_refreshDioProvider` (no `AuthInterceptor`, used internally by `AuthInterceptor` to call `auth/refresh` and retry without recursion).

## Commands

```bash
flutter pub get                    # install deps after pubspec changes
flutter run                        # run on the default device
flutter run -d chrome              # run on a specific platform (chrome|macos|ios|android|...)
flutter analyze                    # static analysis (uses analysis_options.yaml → flutter_lints)
flutter test                       # run all tests (test/ directory does not exist yet — create it before adding tests)
flutter test test/foo_test.dart    # run a single test file
flutter test --name "pattern"      # run tests whose name matches
dart format lib test               # format Dart sources
flutter build <apk|ios|web|macos|linux|windows>   # produce a release build
```

## Notes

- Lints come from `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`. Run `flutter analyze` before declaring work done.
- `pubspec.yaml` has `publish_to: 'none'` — this is an application, not a publishable package.
- `pubspec.lock` is committed; do not delete it when changing dependencies.
