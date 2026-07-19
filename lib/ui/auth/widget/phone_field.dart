import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/app/theme/app_theme.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:ai_teacher/utils/uz_phone_formatter.dart';
import 'package:flutter/material.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrefixChip(),
            const SizedBox(width: 8),
            Expanded(
              child: _Shadow(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  validator: validator,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  inputFormatters: const [UzPhoneFormatter()],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(hintText: hint),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrefixChip extends StatelessWidget {
  const _PrefixChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.inputCornerRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        l10n.authPhoneCountryPrefix,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Shadow extends StatelessWidget {
  const _Shadow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.inputCornerRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
