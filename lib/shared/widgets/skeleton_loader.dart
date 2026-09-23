import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';

/// Shimmer-style skeleton block. Compose multiple for full-screen skeletons.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.height = 16,
    this.width = double.infinity,
    this.radius = AppSizes.radiusSm,
    super.key,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return Shimmer.fromColors(
      baseColor: dark ? AppColors.darkCard : Colors.grey.shade300,
      highlightColor:
          dark ? AppColors.darkSurface : Colors.grey.shade100,
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Pre-baked skeleton tile used while transactions load.
class SkeletonTransactionTile extends StatelessWidget {
  const SkeletonTransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: const <Widget>[
          SkeletonBox(
            height: AppSizes.avatarMd,
            width: AppSizes.avatarMd,
            radius: AppSizes.radiusLg,
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: 14, width: 140),
                SizedBox(height: AppSizes.xs),
                SkeletonBox(height: 12, width: 80),
              ],
            ),
          ),
          SkeletonBox(height: 16, width: 60),
        ],
      ),
    );
  }
}
