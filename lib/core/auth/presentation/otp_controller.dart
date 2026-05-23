import 'package:ai_teacher/core/auth/data/auth_dtos.dart';
import 'package:ai_teacher/core/auth/data/auth_exception.dart';
import 'package:ai_teacher/core/auth/data/auth_repository.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/session/presentation/session_controller.dart';
import 'package:ai_teacher/core/user/presentation/current_user_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpControllerProvider = NotifierProvider<OtpController, AuthActionState>(
  OtpController.new,
);

class OtpController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthIdle();

  /// Verifies the OTP and immediately exchanges the verification token for
  /// auth tokens via sign-up. Returns the tokens on success.
  Future<AuthTokens?> verifyAndSignUp({
    required RegistrationDraft draft,
    required String code,
  }) async {
    state = const AuthLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final verify = await repo.verifyOtp(
        phoneNumber: draft.phoneNumber!,
        code: code,
      );
      final tokens = await repo.signUp(
        draft: draft,
        verificationToken: verify.verificationToken,
      );
      ref.invalidate(currentUserProvider);
      try {
        await ref.read(currentUserProvider.future);
      } catch (_) {
        // Non-fatal: profile screen will retry on its own watch.
      }
      await ref.read(sessionControllerProvider.notifier).syncSession();
      state = const AuthIdle();
      return tokens;
    } on AuthException catch (e) {
      state = AuthFailure(e.message);
      return null;
    }
  }

  Future<bool> resend(String phoneNumber) async {
    state = const AuthLoading();
    try {
      await ref.read(authRepositoryProvider).requestOtp(phoneNumber);
      state = const AuthIdle();
      return true;
    } on AuthException catch (e) {
      state = AuthFailure(e.message);
      return false;
    }
  }

  void reset() => state = const AuthIdle();
}
