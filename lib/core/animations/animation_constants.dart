import 'package:flutter/material.dart';

/// Canonical animation durations & curves.
/// Sticking to these gives the whole app a cohesive motion language.
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 900);

  // Curves — emphasized motion (Material 3) for premium feel.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
}
