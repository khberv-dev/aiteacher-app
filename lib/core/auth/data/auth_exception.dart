import 'package:dio/dio.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';

  static AuthException fromDio(DioException error, {String? fallback}) {
    final response = error.response;
    final status = response?.statusCode;
    final body = response?.data;
    if (body is Map) {
      final raw = body['message'];
      if (raw is List && raw.isNotEmpty) {
        return AuthException(raw.first.toString(), statusCode: status);
      }
      if (raw is String && raw.isNotEmpty) {
        return AuthException(raw, statusCode: status);
      }
    }
    if (status == 401) {
      return AuthException(
        fallback ?? 'Avtorizatsiya rad etildi',
        statusCode: status,
      );
    }
    return AuthException(
      fallback ?? "Tarmoq xatosi. Qayta urinib ko'ring.",
      statusCode: status,
    );
  }
}
