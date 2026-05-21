import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/auth/presentation/auth_action_state.dart';
import 'package:ai_teacher/core/auth/presentation/login_controller.dart';
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
    context.goNamed(AppRoute.register.name);
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
                titleStart: 'Xush',
                titleAccent: 'kelibsiz',
                subtitle:
                    "Hisobingizga kirish uchun ma'lumotlaringizni kiriting",
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
                        hint: 'Parolingizni kiriting',
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onForgot,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Parolni unutdingizmi?',
                              style: TextStyle(
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
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: loading ? 'Kuting...' : 'Kirish  →',
                        enabled: !loading,
                        onPressed: _onSubmit,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Hisobingiz yo'qmi?",
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _onSignUp,
                            child: const Text(
                              "Ro'yxatdan o'tish",
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
