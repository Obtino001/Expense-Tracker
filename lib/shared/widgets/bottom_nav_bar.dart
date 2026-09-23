import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bottom Navigation Bar matching the reference Picky design:
/// - Floating rounded capsule docked at bottom
/// - Active tab highlighted with a vibrant Coral (#FF5B4D) rounded squircle and white icon
/// - Inactive tabs shown as clean minimal outline icons
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: dark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(items.length, (int i) {
              final bool selected = i == currentIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: selected ? 48 : 42,
                  height: selected ? 48 : 42,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.coral : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.38),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      selected ? items[i].activeIcon : items[i].icon,
                      size: 22,
                      color: selected
                          ? Colors.white
                          : (dark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF8E8E93)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
