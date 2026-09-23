import 'package:flutter/material.dart';

/// Breakpoint helper for responsive layouts.
/// Mobile-first: <600 phone, <900 tablet, otherwise desktop.
class Responsive {
  Responsive._();

  static const double phoneBreak = 600;
  static const double tabletBreak = 900;

  static bool isPhone(BuildContext c) =>
      MediaQuery.sizeOf(c).width < phoneBreak;
  static bool isTablet(BuildContext c) {
    final double w = MediaQuery.sizeOf(c).width;
    return w >= phoneBreak && w < tabletBreak;
  }

  static bool isDesktop(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= tabletBreak;

  /// Returns one of three values based on viewport width.
  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return phone;
  }
}

/// Drop-in builder for responsive layouts.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.phone,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return Responsive.value<Widget>(
      context,
      phone: phone,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
