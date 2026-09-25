import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/animations/animation_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/extensions.dart';

/// Shimmer-style skeleton block. Compose multiple for full-screen skeletons.
typedef ShimmerBox = SkeletonBox;

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
    final block = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1B1B22) : const Color(0xFFEAEAF0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (Motion.reduced(context)) return block;
    return Shimmer.fromColors(
      baseColor: dark ? const Color(0xFF1B1B22) : const Color(0xFFEAEAF0),
      highlightColor: dark ? const Color(0xFF282832) : const Color(0xFFF8F8FB),
      period: Motion.pulse,
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: <Widget>[
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
