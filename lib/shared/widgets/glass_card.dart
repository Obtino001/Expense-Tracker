import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';

/// A frosted-glass surface used for premium accents.
/// Wraps a [BackdropFilter] over a translucent white/black overlay.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.radius = AppSizes.radiusXl,
    this.blur = AppSizes.blurMd,
    this.border = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: dark ? AppColors.glassDark : AppColors.glassLight,
            borderRadius: BorderRadius.circular(radius),
            border: border
                ? Border.all(color: AppColors.glassBorder, width: 1)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
