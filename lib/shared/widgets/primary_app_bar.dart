import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';
import 'pressable.dart';

/// Reusable app bar with optional leading back button and trailing actions.
class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PrimaryAppBar({
    required this.title,
    this.actions,
    this.showBack = true,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.padding.top + AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Row(
          children: <Widget>[
            if (showBack && Navigator.of(context).canPop())
              _IconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            if (showBack) const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                title,
                style: context.text.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
