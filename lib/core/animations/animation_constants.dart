import 'package:flutter/material.dart';

/// Canonical animation durations & curves.
/// Sticking to these gives the whole app a cohesive motion language.
class Motion {
  Motion._();

  // Durations
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const hero = Duration(milliseconds: 900);
  static const stagger = Duration(milliseconds: 50);
  static const pulse = Duration(milliseconds: 1400);
  static const drift = Duration(milliseconds: 2600);
  static const splashLoop = Duration(milliseconds: 1800);

  // Curves — emphasized motion (Material 3) for premium feel.
  static const out = Curves.easeOutCubic;
  static const inn = Curves.easeInCubic;
  static const inOut = Curves.easeInOutCubic;
  static const emphasized = Cubic(.2, 0, 0, 1);
  static const spring = Curves.easeOutBack;
  static const bounce = Curves.elasticOut;

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
