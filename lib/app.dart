import 'dart:async';
import 'dart:io' show Platform;

import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_theme.dart';
import 'package:ai_teacher/core/session/presentation/session_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  StreamSubscription<String>? _fcmRefreshSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _fcmRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    final sessionCtrl = ref.read(sessionControllerProvider.notifier);

    String? fcmToken;
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          'FCM foreground: ${message.notification?.title ?? '(no title)'} — '
          'data=${message.data}',
        );
      });

      // iOS needs an APNs token before getToken() can succeed; Android has
      // no APNs round-trip so we call getToken() directly.
      if (Platform.isIOS) {
        String? apnsToken;
        for (var i = 0; i < 10; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          debugPrint(
            'APNS token unavailable after 10s — continuing without FCM token.',
          );
        } else {
          fcmToken = await messaging.getToken();
        }
      } else {
        fcmToken = await messaging.getToken();
      }
      debugPrint('FCM token: $fcmToken');

      _fcmRefreshSub?.cancel();
      _fcmRefreshSub = messaging.onTokenRefresh.listen((next) {
        debugPrint('FCM token refreshed: $next');
        sessionCtrl.updateFcmToken(next);
      });
    } catch (e, st) {
      debugPrint('FCM bootstrap failed: $e\n$st');
    }

    if (!mounted) return;
    // Route initial token through the same path as refreshes: cache + sync.
    // When there is no token (failed bootstrap, simulator), still sync so the
    // session is created/attached.
    if (fcmToken != null && fcmToken.isNotEmpty) {
      await sessionCtrl.updateFcmToken(fcmToken);
    } else {
      await sessionCtrl.syncSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'AI Teacher',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
