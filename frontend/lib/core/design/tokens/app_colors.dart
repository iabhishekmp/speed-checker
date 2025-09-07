import 'package:flutter/material.dart';

/// Design tokens for colors used throughout the app
abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00B4D8);
  static const Color primaryLight = Color(0xFF48CAE4);
  static const Color primaryDark = Color(0xFF0096C7);

  // Background Colors
  static const Color background = Color(0xFF0B1929);
  static const Color surface = Color(0xFF1E2A3B);
  static const Color surfaceLight = Color(0xFF2C3B52);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF64748B);

  // Accent Colors
  static const Color accent = Color(0xFF2196F3);
  static const Color accentLight = Color(0xFF42A5F5);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);

  // Demo Badge
  static const Color demoBadge = Color(0xFFEF4444);

  // Overlay Colors
  static final Color overlay = const Color(0xFF1E293B).withAlpha(95);
  static final Color successOverlay = const Color(0xFF4CAF50).withAlpha(51);
}
