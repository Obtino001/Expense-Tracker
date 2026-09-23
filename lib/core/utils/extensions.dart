import 'package:flutter/material.dart';

/// Tiny ergonomic helpers used across the app.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
}

extension NumX on num {
  /// `12.h` → `SizedBox(height: 12)`
  SizedBox get h => SizedBox(height: toDouble());

  /// `12.w` → `SizedBox(width: 12)`
  SizedBox get w => SizedBox(width: toDouble());
}

extension WidgetX on Widget {
  /// Quick padding extension to keep widget trees flat.
  Widget paddedAll(double v) => Padding(padding: EdgeInsets.all(v), child: this);
  Widget paddedH(double v) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: v), child: this);
  Widget paddedV(double v) =>
      Padding(padding: EdgeInsets.symmetric(vertical: v), child: this);
}
