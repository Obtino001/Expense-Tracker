import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../core/animations/animation_constants.dart';
import '../../core/animations/motion.dart';

/// SVG illustration with ambient floating motion (fxFloat),
/// optionally layered over a Lottie pulse halo at 55% opacity.
class AppIllustration extends StatelessWidget {
  const AppIllustration({
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.showPulse = true,
    this.dy = 3,
    super.key,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showPulse;
  final double dy;

  @override
  Widget build(BuildContext context) {
    final Widget svg = SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    ).fxFloat(context, dy: dy);

    if (!showPulse || Motion.reduced(context)) {
      return svg;
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(
          opacity: 0.55,
          child: Lottie.asset(
            'assets/lottie/pulse.json',
            repeat: true,
            width: (width ?? 200) * 1.3,
            height: (height ?? 200) * 1.3,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        svg,
      ],
    );
  }
}
