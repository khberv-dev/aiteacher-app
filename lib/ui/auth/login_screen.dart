import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/auth/presentation/login_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/auth/widget/auth_header.dart';
import 'package:ai_teacher/ui/auth/widget/auth_identifier_toggle.dart';
import 'package:ai_teacher/ui/auth/widget/labeled_field.dart';
import 'package:ai_teacher/ui/auth/widget/password_field.dart';
import 'package:ai_teacher/ui/auth/widget/phone_field.dart';
import 'package:ai_teacher/ui/shared/widget/primary_button.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthIdentifierKind _identifierKind = AuthIdentifierKind.phone;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  void _onForgot() {
    // Forgot-password flow not implemented yet.
  }

  void _onSignUp() {
    context.goNamed(AppRoute.survey.name);
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();
    final isPhone = _identifierKind == AuthIdentifierKind.phone;
    final tokens = await ref
        .read(loginControllerProvider.notifier)
        .signIn(
          phoneNumber: isPhone
              ? UzPhoneFormatter.toE164(_phoneController.text)
              : null,
          email: isPhone ? null : _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted || tokens == null) return;
    context.goNamed(AppRoute.main.name);
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    final digits = UzPhoneFormatter.digitsOf(value ?? '');
    if (digits.isEmpty) return l10n.authPhoneRequiredError;
    if (digits.length != 9) return l10n.authPhoneDigitsError;
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.authEmailRequiredError;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
    if (!ok) return l10n.authEmailInvalidError;
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.authPasswordRequiredError;
    if (v.length < 6) return l10n.authPasswordMinLengthError;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(loginControllerProvider);
    ref.listen<AuthActionState>(loginControllerProvider, (prev, next) {
      if (next is AuthFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(loginControllerProvider.notifier).reset();
      }
    });

    final loading = state is AuthLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthHeader(
                titleStart: l10n.authLoginTitleStart,
                titleAccent: l10n.authLoginTitleAccent,
                subtitle: l10n.authLoginSubtitle,
                onBack: _onBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthIdentifierToggle(
                        value: _identifierKind,
                        onChanged: (kind) =>
                            setState(() => _identifierKind = kind),
                      ),
                      const SizedBox(height: 16),
                      if (_identifierKind == AuthIdentifierKind.phone)
                        PhoneField(
                          label: l10n.authPhoneNumberLabel,
                          hint: l10n.authPhoneNumberHint,
                          controller: _phoneController,
                          textInputAction: TextInputAction.next,
                          validator: (value) => _validatePhone(value, l10n),
                        )
                      else
                        LabeledField(
                          label: l10n.authEmailLabel,
                          hint: l10n.authEmailHint,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) => _validateEmail(value, l10n),
                        ),
                      const SizedBox(height: 16),
                      PasswordField(
                        label: l10n.authPasswordLabel,
                        hint: l10n.authPasswordHint,
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(),
                        validator: (value) => _validatePassword(value, l10n),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onForgot,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              l10n.authForgotPasswordLabel,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (MediaQuery.viewInsetsOf(context).bottom == 0)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: loading
                              ? l10n.authLoginLoadingLabel
                              : l10n.authLoginSubmitLabel,
                          enabled: !loading,
                          onPressed: _onSubmit,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authNoAccountPrompt,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _onSignUp,
                              child: Text(
                                l10n.authSignUpLinkLabel,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
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
