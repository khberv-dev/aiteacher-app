import 'package:ai_teacher/ui/shared/widget/coming_soon_view.dart';
import 'package:flutter/material.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.play_arrow_rounded,
      iconColor: Color(0xFF22C55E),
      iconBackground: Color(0xFFF0FDF4),
      title: 'Darslar',
      subtitle: "Interaktiv darslar tayyorlanmoqda",
    );
  }
}
