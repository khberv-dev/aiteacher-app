import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref.watch(sharedPreferencesProvider));
});

class CacheService {
  CacheService(this._prefs);

  final SharedPreferences _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionIdKey = 'session_id';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _webIdentifierKey = 'web_identifier';
  static const String _webPasswordKey = 'web_password';

  String? get accessToken => _prefs.getString(_accessTokenKey);

  Future<bool> setAccessToken(String token) =>
      _prefs.setString(_accessTokenKey, token);

  Future<bool> removeAccessToken() => _prefs.remove(_accessTokenKey);

  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<bool> setRefreshToken(String token) =>
      _prefs.setString(_refreshTokenKey, token);

  Future<bool> removeRefreshToken() => _prefs.remove(_refreshTokenKey);

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  String? get sessionId => _prefs.getString(_sessionIdKey);

  Future<bool> setSessionId(String id) => _prefs.setString(_sessionIdKey, id);

  Future<bool> removeSessionId() => _prefs.remove(_sessionIdKey);

  String? get fcmToken => _prefs.getString(_fcmTokenKey);

  Future<bool> setFcmToken(String token) =>
      _prefs.setString(_fcmTokenKey, token);

  Future<bool> removeFcmToken() => _prefs.remove(_fcmTokenKey);

  String? get webIdentifier => _prefs.getString(_webIdentifierKey);

  Future<bool> setWebIdentifier(String v) =>
      _prefs.setString(_webIdentifierKey, v);

  String? get webPassword => _prefs.getString(_webPasswordKey);

  Future<bool> setWebPassword(String v) => _prefs.setString(_webPasswordKey, v);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
