import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';

/// Ambient gradient background with soft "aurora" blobs.
/// Use as the bottom-most layer of premium screens (onboarding, splash).
class GradientBackground extends StatelessWidget {
  const GradientBackground({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return Stack(
      children: <Widget>[
        // Base
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dark ? AppColors.darkBg : AppColors.lightBg,
            ),
          ),
        ),
        // Aurora blobs
        Positioned(
          top: -120,
          left: -80,
          child: _Blob(
            color: AppColors.primary.withValues(alpha: dark ? 0.35 : 0.18),
            size: 320,
          ),
        ),
        Positioned(
          bottom: -150,
          right: -100,
          child: _Blob(
            color: AppColors.secondary.withValues(alpha: dark ? 0.25 : 0.15),
            size: 360,
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
