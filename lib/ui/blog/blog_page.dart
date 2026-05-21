import 'package:ai_teacher/ui/shared/widget/coming_soon_view.dart';
import 'package:flutter/material.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.bookmark_outline_rounded,
      iconColor: Color(0xFFFB923C),
      iconBackground: Color(0xFFFFF7ED),
      title: 'Blog',
      subtitle: "Maqolalar va maslahatlar tez orada",
    );
  }
}
