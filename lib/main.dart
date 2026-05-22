import 'package:ai_teacher/app.dart';
import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebaseMessaging();

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}

/// Minimal FCM bootstrap: init Firebase, request notification permission,
/// and print the device token. Replace the print with real registration
/// once the backend is ready.
Future<void> _initFirebaseMessaging() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // iOS: show banners/alerts even when the app is in the foreground.
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

    // On iOS, getToken() needs an APNS token first. Poll briefly for it.
    String? apnsToken;
    for (var i = 0; i < 10; i++) {
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) break;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    if (apnsToken == null) {
      debugPrint(
        'APNS token unavailable after 10s — skipping FCM token fetch '
        '(simulator or Push capability/APNs key missing).',
      );
    } else {
      final token = await messaging.getToken();
      debugPrint('FCM token: $token');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((next) {
      debugPrint('FCM token refreshed: $next');
    });
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
  }
}
