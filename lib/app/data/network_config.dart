import 'package:flutter/foundation.dart';

class NetworkConfig {
  static const String devHostUrl = 'http://192.168.1.147:8000';
  static const String mainHostUrl = 'https://ai.myteacher.uz';

  static String get hostUrl => kDebugMode ? devHostUrl : mainHostUrl;

  static String get baseApiUrl => '$hostUrl/api/';

  static String get baseCdnUrl => '$hostUrl/public';

  /// Resolves a relative server path (e.g. `assessment/<uuid>.wav`,
  /// `payme/icon.png`) into an absolute URL on the static-files host.
  /// Pass-through for inputs that are already absolute (`http(s)://...`).
  static String resolveStatic(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    final clean = pathOrUrl.replaceFirst(RegExp(r'^/+'), '');
    return '$baseCdnUrl/$clean';
  }
}
