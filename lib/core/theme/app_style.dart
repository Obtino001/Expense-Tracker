import 'package:flutter/material.dart';

/// Compact system profile ("Facebook style") vs house standard profile.
/// Accessible via `context.appStyle`.
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.cardRadius,
    required this.sheetRadius,
    required this.bubbleRadius,
    required this.searchPillRadius,
    required this.gutterSm,
    required this.gutterMd,
    required this.gutterLg,
    required this.buttonHeightLg,
    required this.buttonHeightMd,
    required this.buttonHeightSm,
    required this.inputBorderWidth,
    required this.inputVerticalPadding,
    required this.toolbarHeight,
    this.inputBorderColorLight,
    this.inputBorderColorDark,
    this.isFacebook = false,
  });

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double cardRadius;
  final double sheetRadius;
  final double bubbleRadius;
  final double searchPillRadius;

  final double gutterSm;
  final double gutterMd;
  final double gutterLg;

  final double buttonHeightLg;
  final double buttonHeightMd;
  final double buttonHeightSm;

  final double inputBorderWidth;
  final double inputVerticalPadding;
  final double toolbarHeight;

  final Color? inputBorderColorLight;
  final Color? inputBorderColorDark;
  final bool isFacebook;

  static const standard = AppStyle(
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    cardRadius: 24,
    sheetRadius: 30,
    bubbleRadius: 18,
    searchPillRadius: 999,
    gutterSm: 12,
    gutterMd: 16,
    gutterLg: 24,
    buttonHeightLg: 54,
    buttonHeightMd: 48,
    buttonHeightSm: 40,
    inputBorderWidth: 1.0,
    inputVerticalPadding: 18.0,
    toolbarHeight: 64.0,
    isFacebook: false,
  );

  static const facebook = AppStyle(
    radiusSm: 4,
    radiusMd: 6,
    radiusLg: 8,
    cardRadius: 8,
    sheetRadius: 12,
    bubbleRadius: 18,
    searchPillRadius: 999,
    gutterSm: 12,
    gutterMd: 16,
    gutterLg: 24,
    buttonHeightLg: 48,
    buttonHeightMd: 40,
    buttonHeightSm: 36,
    inputBorderWidth: 1.0,
    inputBorderColorLight: Color(0xFFCED0D4),
    inputBorderColorDark: Color(0xFF3A3A44),
    inputVerticalPadding: 13.0,
    toolbarHeight: 56.0,
    isFacebook: true,
  );

  static TextTheme facebookTextTheme(Color ink) {
    TextStyle style(double size, double lineHeight, FontWeight weight) =>
        TextStyle(
          fontFamily: 'Roboto',
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          letterSpacing: 0,
        );

    return TextTheme(
      displayLarge: style(40, 44, FontWeight.w700),
      displayMedium: style(32, 36, FontWeight.w700),
      displaySmall: style(28, 32, FontWeight.w700),
      headlineLarge: style(24, 28, FontWeight.w700),
      headlineMedium: style(20, 24, FontWeight.w700),
      headlineSmall: style(20, 24, FontWeight.w600),
      titleLarge: style(17, 20, FontWeight.w700),
      titleMedium: style(17, 20, FontWeight.w600),
      titleSmall: style(15, 20, FontWeight.w600),
      bodyLarge: style(16, 22, FontWeight.w400),
      bodyMedium: style(15, 20, FontWeight.w400),
      bodySmall: style(13, 16, FontWeight.w400),
      labelLarge: style(15, 20, FontWeight.w600),
      labelMedium: style(13, 16, FontWeight.w600),
      labelSmall: style(12, 16, FontWeight.w600),
    ).apply(bodyColor: ink, displayColor: ink);
  }

  @override
  AppStyle copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? cardRadius,
    double? sheetRadius,
    double? bubbleRadius,
    double? searchPillRadius,
    double? gutterSm,
    double? gutterMd,
    double? gutterLg,
    double? buttonHeightLg,
    double? buttonHeightMd,
    double? buttonHeightSm,
    double? inputBorderWidth,
    double? inputVerticalPadding,
    double? toolbarHeight,
    Color? inputBorderColorLight,
    Color? inputBorderColorDark,
    bool? isFacebook,
  }) {
    return AppStyle(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      cardRadius: cardRadius ?? this.cardRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      searchPillRadius: searchPillRadius ?? this.searchPillRadius,
      gutterSm: gutterSm ?? this.gutterSm,
      gutterMd: gutterMd ?? this.gutterMd,
      gutterLg: gutterLg ?? this.gutterLg,
      buttonHeightLg: buttonHeightLg ?? this.buttonHeightLg,
      buttonHeightMd: buttonHeightMd ?? this.buttonHeightMd,
      buttonHeightSm: buttonHeightSm ?? this.buttonHeightSm,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      inputVerticalPadding: inputVerticalPadding ?? this.inputVerticalPadding,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      inputBorderColorLight:
          inputBorderColorLight ?? this.inputBorderColorLight,
      inputBorderColorDark: inputBorderColorDark ?? this.inputBorderColorDark,
      isFacebook: isFacebook ?? this.isFacebook,
    );
  }

  @override
  AppStyle lerp(ThemeExtension<AppStyle>? other, double t) {
    if (other is! AppStyle) return this;
    return AppStyle(
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      cardRadius: _lerpDouble(cardRadius, other.cardRadius, t),
      sheetRadius: _lerpDouble(sheetRadius, other.sheetRadius, t),
      bubbleRadius: _lerpDouble(bubbleRadius, other.bubbleRadius, t),
      searchPillRadius:
          _lerpDouble(searchPillRadius, other.searchPillRadius, t),
      gutterSm: _lerpDouble(gutterSm, other.gutterSm, t),
      gutterMd: _lerpDouble(gutterMd, other.gutterMd, t),
      gutterLg: _lerpDouble(gutterLg, other.gutterLg, t),
      buttonHeightLg: _lerpDouble(buttonHeightLg, other.buttonHeightLg, t),
      buttonHeightMd: _lerpDouble(buttonHeightMd, other.buttonHeightMd, t),
      buttonHeightSm: _lerpDouble(buttonHeightSm, other.buttonHeightSm, t),
      inputBorderWidth:
          _lerpDouble(inputBorderWidth, other.inputBorderWidth, t),
      inputVerticalPadding:
          _lerpDouble(inputVerticalPadding, other.inputVerticalPadding, t),
      toolbarHeight: _lerpDouble(toolbarHeight, other.toolbarHeight, t),
      inputBorderColorLight:
          Color.lerp(inputBorderColorLight, other.inputBorderColorLight, t),
      inputBorderColorDark:
          Color.lerp(inputBorderColorDark, other.inputBorderColorDark, t),
      isFacebook: t < 0.5 ? isFacebook : other.isFacebook,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
