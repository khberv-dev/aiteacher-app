import 'package:flutter/material.dart';

class ProfileTrailingValue extends StatelessWidget {
  const ProfileTrailingValue({
    super.key,
    this.value,
    this.badge,
    this.showChevron = true,
    this.chevronColor = const Color(0xFF999999),
  });

  final String? value;
  final Widget? badge;
  final bool showChevron;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?badge,
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              value!,
              style: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (badge != null) const SizedBox(width: 6),
        if (showChevron)
          Icon(Icons.chevron_right_rounded, color: chevronColor, size: 18),
      ],
    );
  }
}
