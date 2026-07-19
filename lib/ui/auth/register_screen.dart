import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/auth/presentation/register_controller.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/ui/auth/widget/auth_header.dart';
import 'package:ai_teacher/ui/auth/widget/auth_identifier_toggle.dart';
import 'package:ai_teacher/ui/auth/widget/labeled_field.dart';
import 'package:ai_teacher/ui/auth/widget/password_field.dart';
import 'package:ai_teacher/ui/auth/widget/phone_field.dart';
import 'package:ai_teacher/ui/shared/widget/primary_button.dart';
import 'package:ai_teacher/ui/survey/survey_data.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.surveyAnswers});

  final SurveyAnswers? surveyAnswers;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  AuthIdentifierKind _identifierKind = AuthIdentifierKind.phone;
  bool _hasReferral = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  void _onLogin() {
    context.goNamed(AppRoute.login.name);
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    final fullName = _nameController.text.trim();
    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';

    final survey = widget.surveyAnswers;
    final referral = _hasReferral && _referralController.text.trim().isNotEmpty
        ? _referralController.text.trim()
        : null;
    if (_identifierKind == AuthIdentifierKind.phone) {
      final draft = await ref
          .read(registerControllerProvider.notifier)
          .requestOtp(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: UzPhoneFormatter.toE164(_phoneController.text),
            password: _passwordController.text,
            goal: survey?.goal,
            level: survey?.level,
            dailyTime: survey?.dailyTime,
            referralCode: referral,
          );
      if (!mounted || draft == null) return;
      context.pushNamed(AppRoute.otp.name, extra: draft);
    } else {
      final draft = await ref
          .read(registerControllerProvider.notifier)
          .requestEmailOtp(
            firstName: firstName,
            lastName: lastName,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            goal: survey?.goal,
            level: survey?.level,
            dailyTime: survey?.dailyTime,
            referralCode: referral,
          );
      if (!mounted || draft == null) return;
      context.pushNamed(AppRoute.otp.name, extra: draft);
    }
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.authNameRequiredError;
    if (v.length < 2) return l10n.authNameTooShortError;
    return null;
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
    final state = ref.watch(registerControllerProvider);
    ref.listen<AuthActionState>(registerControllerProvider, (prev, next) {
      if (next is AuthFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(registerControllerProvider.notifier).reset();
      }
    });

    final loading = state is AuthLoading;
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

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
                titleStart: l10n.authRegisterTitleStart,
                titleAccent: l10n.authRegisterTitleAccent,
                subtitle: l10n.authRegisterSubtitle,
                onBack: _onBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledField(
                        label: l10n.authNameLabel,
                        hint: l10n.authNameHint,
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateName(value, l10n),
                      ),
                      const SizedBox(height: 16),
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
                        hint: l10n.authPasswordMinLengthError,
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validatePassword(value, l10n),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() {
                          _hasReferral = !_hasReferral;
                          if (!_hasReferral) _referralController.clear();
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _hasReferral,
                                  onChanged: (v) => setState(() {
                                    _hasReferral = v ?? false;
                                    if (!_hasReferral) {
                                      _referralController.clear();
                                    }
                                  }),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.authHasReferralLabel,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_hasReferral) ...[
                        const SizedBox(height: 12),
                        LabeledField(
                          label: l10n.authReferralCodeLabel,
                          hint: l10n.authReferralCodeHint,
                          controller: _referralController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isKeyboardOpen)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: loading
                              ? l10n.authRegisterLoadingLabel
                              : l10n.authContinueButtonLabel,
                          enabled: !loading,
                          onPressed: _onSubmit,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            l10n.authTermsAgreementText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authHasAccountPrompt,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _onLogin,
                              child: Text(
                                l10n.authLoginLinkLabel,
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
