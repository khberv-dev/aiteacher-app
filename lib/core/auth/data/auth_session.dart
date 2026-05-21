import 'dart:convert';

import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSessionProvider = Provider<AuthSession>((ref) {
  return AuthSession(ref.watch(cacheServiceProvider));
});

class AuthSession {
  AuthSession(this._cache);

  final CacheService _cache;

  String? get accessToken => _cache.accessToken;

  String? get currentUserId {
    final token = accessToken;
    if (token == null || token.isEmpty) return null;
    return _decodeSubject(token);
  }

  static String? _decodeSubject(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      final sub = payload['sub'];
      return sub is String ? sub : null;
    } catch (_) {
      return null;
    }
  }
}
