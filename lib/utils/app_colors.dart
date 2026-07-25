import 'package:flutter/material.dart';

/// Centralized monochrome color palette for the authentication module.
/// Keeping every color reference here makes future theming trivial and
/// prevents magic hex values from leaking into widget code.
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF111111);
  static const Color cardSecondary = Color(0xFF181818);
  static const Color divider = Color(0xFF262626);
  static const Color border = Color(0xFF2A2A2A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFF4A4A4A);

  // Actions / semantic
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFFE8F5E9); // used sparingly, monochrome-safe
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorMuted = Color(0xFF3A1A1A);

  // Glass effect helpers
  static Color glassFill = Colors.white.withOpacity(0.06);
  static Color glassBorder = Colors.white.withOpacity(0.12);
  static Color shadowColor = Colors.black.withOpacity(0.6);

  // Overlay
  static Color scrim = Colors.black.withOpacity(0.7);
}
