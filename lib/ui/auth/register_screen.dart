import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/auth/presentation/register_controller.dart';
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
    final referral = _referralController.text.trim().isEmpty
        ? null
        : _referralController.text.trim();
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
      final tokens = await ref
          .read(registerControllerProvider.notifier)
          .signUpWithEmail(
            firstName: firstName,
            lastName: lastName,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            goal: survey?.goal,
            level: survey?.level,
            dailyTime: survey?.dailyTime,
            referralCode: referral,
          );
      if (!mounted || tokens == null) return;
      context.goNamed(AppRoute.main.name);
    }
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ismingizni kiriting';
    if (v.length < 2) return 'Ism juda qisqa';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = UzPhoneFormatter.digitsOf(value ?? '');
    if (digits.isEmpty) return 'Telefon raqamini kiriting';
    if (digits.length != 9) return "9 ta raqam bo'lishi kerak";
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Emailni kiriting';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
    if (!ok) return "Email noto'g'ri";
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Parolni kiriting';
    if (v.length < 6) return 'Kamida 6 ta belgi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                titleStart: 'Hisobingizni',
                titleAccent: 'yarating',
                subtitle: 'Bir daqiqa — umrbod foyda',
                onBack: _onBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledField(
                        label: 'ISMINGIZ',
                        hint: 'Sardor Toshmatov',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
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
                          label: 'TELEFON RAQAM',
                          hint: '90 123 45 67',
                          controller: _phoneController,
                          textInputAction: TextInputAction.next,
                          validator: _validatePhone,
                        )
                      else
                        LabeledField(
                          label: 'EMAIL',
                          hint: 'name@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                        ),
                      const SizedBox(height: 16),
                      PasswordField(
                        label: 'PAROL',
                        hint: 'Kamida 6 ta belgi',
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: "REFERAL KOD (IXTIYORIY)",
                        hint: 'A1B2C3D4',
                        controller: _referralController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (_) => _onSubmit(),
                      ),
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
                          label: loading ? 'Yuborilmoqda...' : 'Davom etish  →',
                          enabled: !loading,
                          onPressed: _onSubmit,
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Davom etish orqali Foydalanish shartlari va '
                            'Maxfiylik siyosatiga rozilik bildirasiz',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                            const Text(
                              'Hisobingiz bormi?',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _onLogin,
                              child: const Text(
                                'Kirish',
                                style: TextStyle(
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
