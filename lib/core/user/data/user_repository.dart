import 'package:ai_teacher/app/data/dio_client.dart';
import 'package:ai_teacher/core/user/data/user_dtos.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
});

class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  Future<User> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('users/me');
    return User.fromJson(response.data ?? const {});
  }

  Future<User> updateMe({required String firstName}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'users/me',
      data: {'firstName': firstName},
    );
    return User.fromJson(response.data ?? const {});
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.patch<dynamic>(
      'users/me/password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}
