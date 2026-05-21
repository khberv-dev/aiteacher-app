import 'package:flutter/material.dart';

class GlowAvatar extends StatelessWidget {
  const GlowAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage('assets/images/ai_girl.png'),
      width: 240,
      height: 220,
      fit: BoxFit.contain,
    );
  }
}
