import 'package:flutter/material.dart';

class MiniCardsRow extends StatelessWidget {
  const MiniCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              icon: Icons.menu_book_outlined,
              titleLines: ['Kundalik', "lug'atlar"],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              shadowColor: Color(0x522563EB),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              icon: Icons.bolt_outlined,
              titleLines: ['Online', 'testlar'],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF064E3B), Color(0xFF059669)],
              ),
              shadowColor: Color(0x52059669),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.titleLines,
    required this.gradient,
    required this.shadowColor,
  });

  final IconData icon;
  final List<String> titleLines;
  final Gradient gradient;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 28),
          for (final line in titleLines)
            Text(
              line,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }
}
