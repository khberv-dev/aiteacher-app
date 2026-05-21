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
