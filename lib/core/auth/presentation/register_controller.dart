import 'package:ai_teacher/core/auth/data/auth_dtos.dart';
import 'package:ai_teacher/core/auth/data/auth_exception.dart';
import 'package:ai_teacher/core/auth/data/auth_repository.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerControllerProvider =
    NotifierProvider<RegisterController, AuthActionState>(
      RegisterController.new,
    );

class RegisterController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthIdle();

  Future<RegistrationDraft?> requestOtp({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? goal,
    String? level,
    String? dailyTime,
    String? referralCode,
  }) async {
    state = const AuthLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .requestOtp(phoneNumber: phoneNumber);
      state = const AuthIdle();
      return RegistrationDraft(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        goal: goal,
        level: level,
        dailyTime: dailyTime,
        referralCode: referralCode,
      );
    } on AuthException catch (e) {
      state = AuthFailure(e.message);
      return null;
    }
  }

  Future<RegistrationDraft?> requestEmailOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? goal,
    String? level,
    String? dailyTime,
    String? referralCode,
  }) async {
    state = const AuthLoading();
    try {
      await ref.read(authRepositoryProvider).requestOtp(email: email);
      state = const AuthIdle();
      return RegistrationDraft(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        goal: goal,
        level: level,
        dailyTime: dailyTime,
        referralCode: referralCode,
      );
    } on AuthException catch (e) {
      state = AuthFailure(e.message);
      return null;
    }
  }

  void reset() => state = const AuthIdle();
}
