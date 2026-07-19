import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

enum AuthIdentifierKind { phone, email }

class AuthIdentifierToggle extends StatelessWidget {
  const AuthIdentifierToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AuthIdentifierKind value;
  final ValueChanged<AuthIdentifierKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Segment(
            label: l10n.authPhoneTabLabel,
            selected: value == AuthIdentifierKind.phone,
            onTap: () => onChanged(AuthIdentifierKind.phone),
          ),
          _Segment(
            label: l10n.authEmailTabLabel,
            selected: value == AuthIdentifierKind.email,
            onTap: () => onChanged(AuthIdentifierKind.email),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        elevation: selected ? 1 : 0,
        shadowColor: const Color(0x14000000),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? AppColors.textPrimary
                    : const Color(0xFF8A8580),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
