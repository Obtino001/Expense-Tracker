import 'package:flutter/material.dart';

import '../../core/animations/animation_constants.dart';
import '../../core/utils/formatters.dart';

/// Smoothly animates from previous value to [value].
/// Used in the home balance card for that "premium" tweening feel.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.value,
    this.style,
    this.isCurrency = true,
    this.duration = Motion.hero,
    super.key,
  });

  final double value;
  final TextStyle? style;
  final bool isCurrency;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Motion.of(context, duration),
      curve: Motion.out,
      tween: Tween<double>(begin: 0, end: value),
      builder: (BuildContext c, double v, _) {
        final String text =
            isCurrency ? Formatters.currency(v) : v.toStringAsFixed(0);
        return Text(text, style: style);
      },
    );
  }
}
