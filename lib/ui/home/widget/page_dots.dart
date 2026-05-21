import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.length, required this.activeIndex});

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            _Dot(active: i == activeIndex),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
