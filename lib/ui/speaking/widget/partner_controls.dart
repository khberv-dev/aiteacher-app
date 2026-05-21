import 'package:flutter/material.dart';

class PartnerControls extends StatelessWidget {
  const PartnerControls({
    super.key,
    required this.onKeyboard,
    required this.onMic,
    required this.onMagic,
    required this.recording,
  });

  final VoidCallback onKeyboard;
  final VoidCallback onMic;
  final VoidCallback onMagic;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SideButton(icon: Icons.keyboard_alt_outlined, onTap: onKeyboard),
          _MicButton(active: recording, onTap: onMic),
          _SideButton(icon: Icons.auto_awesome_outlined, onTap: onMagic),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D1B4B).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF6B7A9F), size: 26),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: active
                  ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                  : const [Color(0xFF1340C4), Color(0xFF0D2B8E)],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (active ? const Color(0xFFEF4444) : const Color(0xFF1340C4))
                        .withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            active ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
