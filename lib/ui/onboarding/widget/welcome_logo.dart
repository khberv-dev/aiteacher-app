import 'package:flutter/material.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage('assets/images/brand_full_white.png'),
      height: 40,
      fit: BoxFit.contain,
    );
  }
}
