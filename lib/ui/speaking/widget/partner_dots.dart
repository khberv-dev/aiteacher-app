import 'package:flutter/material.dart';

class PartnerDots extends StatelessWidget {
  const PartnerDots({super.key, this.count = 9});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFB0BFE0),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
