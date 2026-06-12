# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app named `ai_teacher` (Dart SDK `^3.11.5`). Targets all six Flutter platforms — `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` directories are present and should stay buildable.

Stack: `flutter_riverpod` (state), `go_router` (nav), `dio` + `talker_dio_logger` (network/logging), `shared_preferences` (persistence). Target market is Uzbekistan — phone numbers are 9 digits formatted `XX XXX XX XX` via `UzPhoneFormatter`.

Notable packages: `record` (mic capture in speaking), `flutter_webrtc` (peer-to-peer video/audio in call feature), `audioplayers` (playback), `lottie` (animations), `flutter_inappwebview` (course web view with auto-login injection), `chewie` + `video_player` (video courses), `pinput` (OTP input), `flutter_markdown_plus` (AI chat message rendering), `image_picker` (profile/avatar upload), `url_launcher` (external links), `package_info_plus` (app version display).

## Architecture

Clean-architecture layout under `lib/`:

```
lib/
├── main.dart                    # bootstraps Firebase + SharedPreferences + ProviderScope
├── app.dart                     # MaterialApp.router
├── app/                         # app-wide infrastructure
│   ├── router/                  # go_router config (AppRoute enum + routerProvider)
│   ├── theme/                   # AppColors, AppRadius, AppTheme (light only)
│   └── data/                    # NetworkConfig, dioProvider, AuthInterceptor, CacheService
├── core/<feature>/              # business logic per feature
│   ├── data/                    # repositories, dtos, sockets
│   └── presentation/            # Riverpod controllers / Notifiers (no widgets)
├── ui/<feature>/                # widgets per feature
│   ├── <feature>_screen.dart    # screen / page / dialog files live HERE — NOT in a screen/ subfolder
│   └── widget/                  # feature-local reusable widgets
├── ui/shared/                   # globally reusable dialogs
│   └── widget/                  # globally reusable widgets
└── utils/                       # extensions, formatters, helpers
```

No `domain/` layer is used — features only have `data/` and `presentation/`.

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
- **Dio**: three providers — `dioProvider` (auth-aware, used by all authenticated endpoints), `unauthDioProvider` (no `AuthInterceptor`, for login/register/OTP so a stale token can't trigger a refresh loop), and a private `_refreshDioProvider` (used internally by `AuthInterceptor` to call `auth/refresh`).
- **AuthSession** (`authSessionProvider`): thin wrapper over `CacheService` that exposes `accessToken` and decodes `currentUserId` from the JWT `sub` claim. Used by socket providers that need the token at connect time.
- **Sockets**: `battle`, `call`, `chat`, `support`, and `student_activity` features use Socket.IO via `socket_io_client`. Each socket class is provided as an `autoDispose` Provider. Sockets authenticate by passing `setAuth({'token': accessToken})` in `OptionBuilder` and connect manually (`.disableAutoConnect()` + explicit `.connect()`). Events are exposed as broadcast Streams via `StreamController`s, all closed in `dispose()`.
- **Route navigation**: routes pass typed objects via `state.extra` (not path parameters). Cast with `state.extra is SomeType ? state.extra as SomeType : fallback`. The `AppRoute` enum holds all paths.
- **MainScreen tabs**: IndexedStack with five slots — chat (0), courses (1), home (2), comments (3), profile (4). Use `MainScreen.homeTab` / `.chatTab` etc. constants when pushing with extra. **Exception**: the chat slot (0) holds a `SizedBox.shrink()` — tapping it pushes `AppRoute.chat` as a full-screen route rather than swapping a tab page. `CommentsPage` (tab 3) lives in `lib/ui/blog/blog_page.dart` despite the filename mismatch.
- **Firebase**: `firebase_core` + `firebase_messaging` are initialized in `main()` (errors are caught silently so the app still runs without Firebase). FCM token is stored via `CacheService.setFcmToken`.
- **Router auth guard**: `routerProvider` reads `cacheService.accessToken` once at startup to pick `AppRoute.main` vs `AppRoute.onboarding`. The guard is **not reactive** — a token that expires mid-session won't redirect automatically; that's handled by `AuthInterceptor` triggering a refresh or clearing tokens on 401.
- **CacheService time-limit tracking**: two 24-hour sliding-window helpers track usage seconds — `getDemoSecondsUsed(courseId)` / `setDemoSecondsUsed` (per demo course) and `getSpeakingSecondsUsed` / `setSpeakingSecondsUsed` (global speaking partner limit). Window resets automatically when ≥ 24 h have elapsed since the stored start timestamp.
- **Speaking conversation limits**: `ConversationLimit` model (`lib/core/speaking/data/conversation_limit.dart`) carries server-side per-plan limits (`baseLimit`, `addonExtra`, `effectiveLimit`, `remaining`, `isUnlimited`). This is the authoritative source for whether a user can start a session; the CacheService second-based tracker is a local UI safeguard, not the gating logic.
- **Chatbot feature**: `lib/core/chatbot/` holds `ChatbotController` (an `AutoDisposeAsyncNotifier` that creates a session on `build` then accepts `sendMessage` calls), `chatbotRepositoryProvider`, and DTOs. The reusable `ChatbotView` widget (`lib/ui/courses/widget/chatbot_view.dart`) embeds the chat UI and is used in both the course web screen and `AiManagerScreen` (route `AppRoute.aiManager` → `/ai-manager`). A companion `ChatbotSheet` wraps it in a bottom sheet.
- **Local development**: update `NetworkConfig.devHostUrl` (`lib/app/data/network_config.dart`) to your machine's LAN IP before running against a local API server. Use `NetworkConfig.resolveStatic(path)` to build CDN media URLs — it prepends `baseCdnUrl` to relative paths and returns absolute URLs unchanged.
- **Course web auto-login**: `CacheService` stores `webIdentifier` and `webPassword` which are injected as JavaScript into `flutter_inappwebview` pages to auto-authenticate the student on course web content.
- **Auth controller pattern**: auth form controllers (`LoginController`, `RegisterController`, `OtpController`) use a sealed `AuthActionState` class (`AuthIdle` / `AuthLoading` / `AuthFailure`) rather than `AsyncValue`, giving finer-grained UI control without the `loading` state hiding the form.

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
