import 'package:flutter/material.dart';

class CallRoundButton extends StatelessWidget {
  const CallRoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.background = const Color(0x33FFFFFF),
    this.iconColor = Colors.white,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 68.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: iconColor, size: large ? 30 : 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB7BCC8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
