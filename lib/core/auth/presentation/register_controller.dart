import 'package:ai_teacher/core/auth/data/auth_dtos.dart';
import 'package:ai_teacher/core/auth/data/auth_exception.dart';
import 'package:ai_teacher/core/auth/data/auth_repository.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/session/presentation/session_controller.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
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
      await ref.read(authRepositoryProvider).requestOtp(phoneNumber);
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

  Future<AuthTokens?> signUpWithEmail({
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
      final tokens = await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            goal: goal,
            level: level,
            dailyTime: dailyTime,
            referralCode: referralCode,
          );
      ref.invalidate(currentUserProvider);
      try {
        await ref.read(currentUserProvider.future);
      } catch (_) {
        // Non-fatal: main/profile screens will retry on their own watch.
      }
      await ref.read(sessionControllerProvider.notifier).syncSession();
      state = const AuthIdle();
      return tokens;
    } on AuthException catch (e) {
      state = AuthFailure(e.message);
      return null;
    }
  }

  void reset() => state = const AuthIdle();
}
