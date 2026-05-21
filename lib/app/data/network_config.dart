import 'package:flutter/foundation.dart';

class NetworkConfig {
  static const String devHostUrl = 'http://192.168.1.147:8000';
  static const String mainHostUrl = 'https://ai.myteacher.uz';

  static String get hostUrl => kDebugMode ? devHostUrl : mainHostUrl;

  static String get baseApiUrl => '$hostUrl/api/';

  static String get baseCdnUrl => '$hostUrl/public';
}
