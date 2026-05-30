import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _tabs = <NavTab>[
    NavTab(
      label: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: AppColors.primary,
      iconBackground: Color(0xFFF0FDFA),
    ),
    NavTab(
      label: 'Kurslar',
      icon: Icons.school_rounded,
      iconColor: Color(0xFF22C55E),
      iconBackground: Color(0xFFF0FDF4),
    ),
    NavTab(
      label: 'Home',
      icon: Icons.home_rounded,
      iconColor: AppColors.primary,
      iconBackground: Color(0xFFCCFBF1),
    ),
    NavTab(
      label: 'Izohlar',
      icon: Icons.forum_outlined,
      iconColor: Color(0xFFFB923C),
      iconBackground: Color(0xFFFFF7ED),
    ),
    NavTab(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      iconColor: Color(0xFFA855F7),
      iconBackground: Color(0xFFFDF4FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0x12000000), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: _tabs[i],
                  active: i == activeIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : tab.iconBackground,
                borderRadius: BorderRadius.circular(14),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                tab.icon,
                color: active ? Colors.white : tab.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                color: active ? AppColors.primary : const Color(0xFFBBBBBB),
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
