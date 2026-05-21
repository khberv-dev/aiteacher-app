import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OtpProgressDots extends StatelessWidget {
  const OtpProgressDots({
    super.key,
    required this.length,
    required this.filled,
  });

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _Dot(active: i < filled),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: active ? 20 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFE2DED7),
        borderRadius: BorderRadius.circular(4),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
    );
  }
}
