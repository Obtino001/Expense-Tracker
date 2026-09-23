import 'package:flutter/material.dart';

/// Centralized color palette.
/// Inspired by Revolut/Stripe — deep navy, electric purple, gradient accents.
class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFFFF5B4D); // Picky coral accent
  static const Color primaryDark = Color(0xFFE2483B);
  static const Color secondary = Color(0xFF2F80ED); // Vibrant blue
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Picky specific colors
  static const Color coral = Color(0xFFFF5B4D);
  static const Color coralSoft = Color(0xFFFFF0ED);
  static const Color coralMuted = Color(0xFFFFE5E0);
  static const Color deepBlack = Color(0xFF0F0F12);
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
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFE8F7EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFF5B4D);
  static const Color info = Color(0xFF2F80ED);

  // ---------- Light theme ----------
  static const Color lightBg = Color(0xFFF8F9FA); // Warm clean off-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightDivider = Color(0xFFEEEEF0);
  static const Color lightBorder = Color(0xFFEAEBED);

  // ---------- Dark theme ----------
  static const Color darkBg = Color(0xFF090A0C);
  static const Color darkSurface = Color(0xFF121316);
  static const Color darkCard = Color(0xFF1B1C22);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9EA7);
  static const Color darkDivider = Color(0xFF262730);
  static const Color darkBorder = Color(0xFF2A2B35);

  // ---------- Gradients ----------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[Color(0xFFFF5B4D), Color(0xFFFF7A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: <Color>[Color(0xFF16161B), Color(0xFF0D0D10)],
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
    colors: <Color>[Color(0xFF16161B), Color(0xFF0F0F12)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: <Color>[Color(0xFFFF5B4D), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism overlays
  static Color glassLight = Colors.white.withValues(alpha: 0.15);
  static Color glassDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
}
