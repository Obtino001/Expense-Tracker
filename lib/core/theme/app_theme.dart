import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// A quiet, editorial foundation shared by every surface in Picky.
class AppTheme {
  AppTheme._();
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
    final muted = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
      primary: primary, onPrimary: dark ? AppColors.deepBlack : Colors.white,
      surface: surface, onSurface: ink, onSurfaceVariant: muted,
      outline: muted, outlineVariant: border, error: AppColors.danger,
      surfaceContainerHighest: dark ? AppColors.darkCard : const Color(0xFFEEF2EC),
    );
    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData(brightness: brightness).textTheme);
    final text = base.apply(bodyColor: ink, displayColor: ink).copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 48, fontWeight: FontWeight.w600, letterSpacing: -2.2, color: ink),
      displayMedium: base.displayMedium?.copyWith(fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: -1.5, color: ink),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -1.1, color: ink),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -.7, color: ink),
      titleLarge: base.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -.5, color: ink),
      titleMedium: base.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -.2, color: ink),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.5, color: ink),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 13, height: 1.5, color: ink),
      bodySmall: base.bodySmall?.copyWith(fontSize: 11, height: 1.4, color: muted),
      labelLarge: base.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: ink),
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    return ThemeData(
      useMaterial3: true, brightness: brightness, colorScheme: scheme,
      scaffoldBackgroundColor: bg, textTheme: text, dividerColor: border,
      iconTheme: IconThemeData(color: ink, size: 22),
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(color: surface, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: border))),
      appBarTheme: AppBarTheme(backgroundColor: bg, foregroundColor: ink, elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(48, 52), shape: shape, textStyle: text.labelLarge)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: scheme.onPrimary, elevation: 0, minimumSize: const Size(48, 54), shape: shape)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), shape: shape, side: BorderSide(color: border))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48), textStyle: text.labelLarge)),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surface, hintStyle: TextStyle(color: muted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent, showDragHandle: true, dragHandleColor: border,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30)))),
      dialogTheme: DialogThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: dark ? const Color(0xFFDEF1E7) : AppColors.deepBlack,
        contentTextStyle: TextStyle(color: dark ? AppColors.deepBlack : Colors.white, fontSize: 13), actionTextColor: dark ? AppColors.primary : AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), insetPadding: const EdgeInsets.all(20)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary, linearTrackColor: border),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? scheme.onPrimary : muted), trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : border)),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}
