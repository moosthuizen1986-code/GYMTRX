import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =====================================================
  // BACKGROUND
  // =====================================================

  static const Color background = Color(0xFF0F0F10);

  static const Color surface = Color(0xFF17181C);

  static const Color card = Color(0xFF1F2024);

  static const Color cardLight = Color(0xFF292B31);

  // =====================================================
  // BRAND
  // =====================================================

  static const Color primary = Color(0xFFE53935);

  static const Color primaryDark = Color(0xFFC62828);

  static const Color primaryLight = Color(0xFFFF6F60);

  // =====================================================
  // TEXT
  // =====================================================

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Color(0xFFB0B3B8);

  static const Color textHint = Color(0xFF6F7278);

  // =====================================================
  // STATUS
  // =====================================================

  static const Color success = Color(0xFF4CAF50);

  static const Color warning = Color(0xFFFFC107);

  static const Color danger = Color(0xFFF44336);

  static const Color info = Color(0xFF29B6F6);

  // =====================================================
  // DIVIDERS
  // =====================================================

  static const Color divider = Color(0xFF32343A);

  // =====================================================
  // GRADIENTS
  // =====================================================

  static const LinearGradient primaryGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryLight,
      primary,
      primaryDark,
    ],
  );

  static const LinearGradient darkGradient =
      LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      surface,
      background,
    ],
  );
}