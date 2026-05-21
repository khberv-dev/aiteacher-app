import 'package:ai_teacher/app/theme/app_radius.dart';
import 'package:ai_teacher/ui/chat/widget/chat_filter_tabs.dart';
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.online,
    required this.activeFilterIndex,
    required this.onFilterTap,
    required this.onBack,
    required this.onSearch,
    required this.onMenu,
  });

  final String title;
  final String subtitle;
  final bool online;
  final int activeFilterIndex;
  final ValueChanged<int> onFilterTap;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x0F000000), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _BackChip(onTap: onBack),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          if (online) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Flexible(
                            child: Text(
                              subtitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: online
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF888888),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _IconChip(icon: Icons.search_rounded, onTap: onSearch),
                const SizedBox(width: 6),
                _IconChip(icon: Icons.menu_rounded, onTap: onMenu),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChatFilterTabs(
              activeIndex: activeFilterIndex,
              onTap: onFilterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDEAE4),
      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF555555),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDEAE4),
      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: const Color(0xFF555555), size: 16),
        ),
      ),
    );
  }
}
