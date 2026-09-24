import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// A quiet, editorial foundation shared by every surface in Picky.
class AppTheme {
  AppTheme._();
  static bool useGoogleFonts = true;

  static TextStyle _style(
      double size, double lineHeight, FontWeight weight, double tracking,
      {bool display = false}) {
    final base = TextStyle(
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: tracking);
    if (!useGoogleFonts) return base.copyWith(fontFamily: 'Roboto');
    return display
        ? GoogleFonts.interTight(textStyle: base)
        : GoogleFonts.inter(textStyle: base);
  }

  static TextTheme _textTheme(Color ink) => TextTheme(
        displayLarge: _style(48, 52, FontWeight.w700, -1.6, display: true),
        displayMedium: _style(40, 44, FontWeight.w700, -1.2, display: true),
        displaySmall: _style(32, 40, FontWeight.w700, -.9, display: true),
        headlineLarge: _style(28, 36, FontWeight.w700, -.7, display: true),
        headlineMedium: _style(24, 32, FontWeight.w700, -.5, display: true),
        headlineSmall: _style(20, 28, FontWeight.w600, -.3, display: true),
        titleLarge: _style(20, 28, FontWeight.w600, -.3, display: true),
        titleMedium: _style(16, 24, FontWeight.w600, -.15, display: true),
        titleSmall: _style(14, 20, FontWeight.w600, -.1),
        bodyLarge: _style(16, 26, FontWeight.w400, -.1),
        bodyMedium: _style(14, 22, FontWeight.w400, -.05),
        bodySmall: _style(12, 18, FontWeight.w400, 0),
        labelLarge: _style(14, 20, FontWeight.w600, -.1),
        labelMedium: _style(12, 16, FontWeight.w600, 0),
        labelSmall: _style(11, 16, FontWeight.w600, .5),
      ).apply(bodyColor: ink, displayColor: ink);
  static ThemeData get light => build(Brightness.light);
  static ThemeData get dark => build(Brightness.dark);

  static ThemeData build(Brightness brightness, {String accent = 'mint'}) {
    final dark = brightness == Brightness.dark;
    final Color primary = switch (accent) {
      'blue' => dark ? const Color(0xFF96BDFF) : const Color(0xFF356CAE),
      'violet' => dark ? const Color(0xFFC8B5FF) : const Color(0xFF7657AC),
      _ => dark ? const Color(0xFFBDEBD8) : AppColors.primary,
    };
    final bg = dark ? AppColors.darkBg : AppColors.lightBg;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final ink = dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final muted =
        dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final scheme =
        ColorScheme.fromSeed(seedColor: primary, brightness: brightness)
            .copyWith(
      primary: primary,
      onPrimary: dark ? AppColors.deepBlack : Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: muted,
      outlineVariant: border,
      error: AppColors.danger,
      surfaceContainerHighest:
          dark ? AppColors.darkCard : const Color(0xFFEEF2EC),
    );
    final text = _textTheme(ink);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: text,
      primaryTextTheme: text,
      dividerColor: border,
      iconTheme: IconThemeData(color: ink, size: 22),
      splashFactory: NoSplash.splashFactory,
      hoverColor: ink.withValues(alpha: dark ? .06 : .04),
      focusColor: ink.withValues(alpha: dark ? .06 : .04),
      highlightColor: ink.withValues(alpha: dark ? .06 : .04),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
      }),
      scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(6),
          radius: Radius.circular(8)),
      cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: border))),
      appBarTheme: AppBarTheme(
          backgroundColor: bg,
          foregroundColor: ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          toolbarHeight: 64,
          titleTextStyle: _style(22, 28, FontWeight.w700, -.5, display: true)
              .copyWith(color: ink)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 52),
              shape: shape,
              textStyle: _style(15, 20, FontWeight.w600, -.1))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
              minimumSize: const Size(48, 54),
              shape: shape,
              textStyle: _style(15, 20, FontWeight.w600, -.1))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: shape,
              side: BorderSide(color: border),
              textStyle: _style(15, 20, FontWeight.w600, -.1))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              textStyle: _style(14, 20, FontWeight.w600, -.1))),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: _style(15, 22, FontWeight.w400, 0).copyWith(color: muted),
        labelStyle: _style(15, 22, FontWeight.w400, 0).copyWith(color: muted),
        floatingLabelStyle:
            _style(16, 20, FontWeight.w600, 0).copyWith(color: primary),
        helperStyle: _style(12, 18, FontWeight.w400, 0),
        errorStyle: _style(12, 18, FontWeight.w500, 0),
        prefixStyle: _style(15, 22, FontWeight.w400, 0).copyWith(color: ink),
        suffixStyle: _style(15, 22, FontWeight.w400, 0).copyWith(color: ink),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary, width: 1.5)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true,
          dragHandleColor: border,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)))),
      dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: _style(20, 28, FontWeight.w700, -.3, display: true)
              .copyWith(color: ink),
          contentTextStyle:
              _style(14, 22, FontWeight.w400, -.05).copyWith(color: muted),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: dark ? border : Colors.transparent))),
      tooltipTheme: TooltipThemeData(
          textStyle: _style(12, 16, FontWeight.w500, 0).copyWith(color: ink)),
      popupMenuTheme: PopupMenuThemeData(
          textStyle: _style(14, 20, FontWeight.w500, 0).copyWith(color: ink)),
      chipTheme: ChipThemeData(
          labelStyle: _style(13, 18, FontWeight.w600, 0).copyWith(color: ink)),
      tabBarTheme: TabBarThemeData(
          labelStyle: _style(14, 20, FontWeight.w600, -.1),
          unselectedLabelStyle: _style(14, 20, FontWeight.w500, -.1)),
      listTileTheme: ListTileThemeData(
          titleTextStyle:
              _style(15, 22, FontWeight.w600, 0).copyWith(color: ink),
          subtitleTextStyle:
              _style(13, 18, FontWeight.w400, 0).copyWith(color: muted)),
      navigationBarTheme: NavigationBarThemeData(
          labelTextStyle:
              WidgetStatePropertyAll(_style(12, 16, FontWeight.w600, 0))),
      segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
              textStyle:
                  WidgetStatePropertyAll(_style(13, 18, FontWeight.w600, 0)))),
      snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: dark ? const Color(0xFFDEF1E7) : AppColors.deepBlack,
          contentTextStyle: _style(14, 20, FontWeight.w500, 0)
              .copyWith(color: dark ? AppColors.deepBlack : Colors.white),
          actionTextColor: dark ? AppColors.primary : AppColors.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding: const EdgeInsets.all(20)),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: primary, linearTrackColor: border),
      switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? scheme.onPrimary : muted),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? primary : border)),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}
