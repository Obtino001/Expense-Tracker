import 'package:flutter/material.dart';

/// Elevation shadow tokens matching TestGah's design system:
/// Light only: two soft shadows; dark uses tone + hairline instead of shadow.
class AppElevations {
  AppElevations._();

  /// Default card elevation:
  /// Light: alpha .04/blur 2/dy 1 and alpha .05/blur 24/dy 8
  /// Dark: empty (uses surface tone + hairline border)
  static List<BoxShadow> card(bool isDark) {
    if (isDark) return const <BoxShadow>[];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: .05),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Hover elevation:
  /// Light: alpha .05/3/1 and .10/40/16
  /// Dark: empty
  static List<BoxShadow> hover(bool isDark) {
    if (isDark) return const <BoxShadow>[];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .05),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: .10),
        blurRadius: 40,
        offset: const Offset(0, 16),
      ),
    ];
  }

  /// Float elevation (modals, floating cards):
  /// black .14/40/16 + .06/6/2
  static List<BoxShadow> float() {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: .14),
        blurRadius: 40,
        offset: const Offset(0, 16),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
