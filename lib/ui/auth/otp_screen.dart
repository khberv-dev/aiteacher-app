import 'dart:async';

import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/data/auth_dtos.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/auth/presentation/otp_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/auth/widget/otp_app_bar.dart';
import 'package:ai_teacher/ui/auth/widget/otp_progress_dots.dart';
import 'package:ai_teacher/ui/auth/widget/otp_verify_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.draft});

  final RegistrationDraft draft;

  static const int codeLength = 5;
  static const int resendSeconds = 60;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _ticker;
  int _remaining = OtpScreen.resendSeconds;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCodeChanged);
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    _remaining = OtpScreen.resendSeconds;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  Future<void> _onResend() async {
    final ok = await ref
        .read(otpControllerProvider.notifier)
        .resend(widget.draft);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      _startCountdown();
    }
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  Future<void> _onVerify() async {
    if (_controller.text.length != OtpScreen.codeLength) return;
    FocusScope.of(context).unfocus();
    final tokens = await ref
        .read(otpControllerProvider.notifier)
        .verifyAndSignUp(draft: widget.draft, code: _controller.text);
    if (!mounted || tokens == null) return;
    context.goNamed(AppRoute.main.name);
  }

  String _maskedIdentifier(AppLocalizations l10n) {
    final email = widget.draft.email;
    if (email != null && email.isNotEmpty) {
      final at = email.indexOf('@');
      if (at > 1) {
        final name = email.substring(0, at);
        final domain = email.substring(at);
        final masked =
            '${name.substring(0, 1)}${'•' * (name.length - 1)}$domain';
        return l10n.authOtpSentToTarget(masked);
      }
      return l10n.authOtpSentToTarget(email);
    }
    final phone = widget.draft.phoneNumber ?? '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return l10n.authOtpSentToPhone(phone);
    final country = digits.substring(0, 3);
    final head = digits.substring(3, 5);
    final tail = digits.substring(digits.length - 2);
    return l10n.authOtpSentToPhone('+$country $head ••• ••$tail');
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(otpControllerProvider);
    ref.listen<AuthActionState>(otpControllerProvider, (prev, next) {
      if (next is AuthFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(otpControllerProvider.notifier).reset();
      }
    });

    final loading = state is AuthLoading;
    final filled = _controller.text.length;
    final canVerify = filled == OtpScreen.codeLength && !loading;
    final canResend = _remaining == 0 && !loading;

    final defaultPin = PinTheme(
      width: 46,
      height: 60,
      textStyle: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DED7), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              OtpAppBar(title: l10n.authOtpAppBarTitle, onBack: _onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      const _MailIcon(),
                      const SizedBox(height: 22),
                      Text(
                        widget.draft.email != null
                            ? l10n.authOtpEnterEmailCodeLabel
                            : l10n.authOtpEnterSmsCodeLabel,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _maskedIdentifier(l10n),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.55,
                        ),
                      ),
                      Text(
                        l10n.authOtpCodeSentCount(OtpScreen.codeLength),
                        style: const TextStyle(
                          color: Color(0xFF8A8580),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Pinput(
                        length: OtpScreen.codeLength,
                        controller: _controller,
                        focusNode: _focusNode,
                        defaultPinTheme: defaultPin,
                        focusedPinTheme: focusedPin,
                        submittedPinTheme: submittedPin,
                        separatorBuilder: (_) => const SizedBox(width: 8),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        cursor: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: 2,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        onCompleted: (_) => _onVerify(),
                      ),
                      const SizedBox(height: 14),
                      OtpProgressDots(
                        length: OtpScreen.codeLength,
                        filled: filled,
                      ),
                      const SizedBox(height: 14),
                      _ResendRow(
                        canResend: canResend,
                        countdownLabel: _formatCountdown(_remaining),
                        onResend: _onResend,
                      ),
                      const SizedBox(height: 18),
                      OtpVerifyButton(
                        label: loading
                            ? l10n.authOtpVerifyingLabel
                            : l10n.authOtpVerifyButtonLabel,
                        enabled: canVerify,
                        onPressed: _onVerify,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 12,
                            color: Color(0xFFB5B0A8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.authOtpDataProtectedLabel,
                            style: const TextStyle(
                              color: Color(0xFFB5B0A8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MailIcon extends StatelessWidget {
  const _MailIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F7F5), Color(0xFFD0EEEA)],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.mark_email_read_outlined,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.canResend,
    required this.countdownLabel,
    required this.onResend,
  });

  final bool canResend;
  final String countdownLabel;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authOtpResendPromptLabel,
          style: const TextStyle(
            color: Color(0xFF8A8580),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 5),
        if (canResend)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onResend,
            child: Text(
              l10n.authOtpResendActionLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            countdownLabel,
            style: const TextStyle(
              color: Color(0xFF8A8580),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
