import 'package:flutter/material.dart';

/// Centralized color palette.
/// Inspired by Revolut/Stripe — deep navy, electric purple, gradient accents.
class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFF227A67);
  static const Color primaryDark = Color(0xFF175A4D);
  static const Color secondary = Color(0xFFBDEBD8);
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Picky specific colors
  static const Color coral = primary;
  static const Color coralSoft = Color(0xFFEDF6F1);
  static const Color coralMuted = Color(0xFFD8EEE3);
  static const Color deepBlack = Color(0xFF152A26);
  static const Color darkCardSurface = Color(0xFF1C1C22);
  static const Color darkPill = Color(0xFF24242C);
  static const Color darkPillBorder = Color(0xFF32323C);

  // Category specific colors from reference design
  static const Color catHousing = Color(0xFF2F80ED); // Rich royal blue
  static const Color catFood = Color(0xFFFF5B4D); // Coral red
  static const Color catGroceries = Color(0xFF10B981); // Emerald green
  static const Color catShopping = Color(0xFFF59E0B); // Golden amber
  static const Color catTransport = Color(0xFF8B5CF6); // Purple violet
  static const Color catEntertainment = Color(0xFFEC4899); // Soft magenta

  // ---------- Semantic ----------
  static const Color success = Color(0xFF279578);
  static const Color successSoft = Color(0xFFE8F7EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFD96161);
  static const Color info = Color(0xFF2F80ED);

  // ---------- Light theme ----------
  static const Color lightBg = Color(0xFFF6F7F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1D302C);
  static const Color lightTextSecondary = Color(0xFF6C7974);
  static const Color lightDivider = Color(0xFFE7ECE6);
  static const Color lightBorder = Color(0xFFE3E9E2);

  // ---------- Dark theme ----------
  static const Color darkBg = Color(0xFF101715);
  static const Color darkSurface = Color(0xFF18221F);
  static const Color darkCard = Color(0xFF1C2823);
  static const Color darkTextPrimary = Color(0xFFEDF3EE);
  static const Color darkTextSecondary = Color(0xFFA4B2AA);
  static const Color darkDivider = Color(0xFF2C3932);
  static const Color darkBorder = Color(0xFF304038);

  // ---------- Gradients ----------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[Color(0xFF227A67), Color(0xFF36977C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: <Color>[Color(0xFF233C32), Color(0xFF152720)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: <Color>[Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: <Color>[Color(0xFFFF5B4D), Color(0xFFFF7A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: <Color>[Color(0xFF213E34), Color(0xFF152A26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: <Color>[Color(0xFF227A67), Color(0xFFBDEBD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism overlays
  static Color glassLight = Colors.white.withValues(alpha: 0.15);
  static Color glassDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}
