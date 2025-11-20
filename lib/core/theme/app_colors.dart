import 'package:flutter/material.dart';

/// ألوان التطبيق
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3); // أزرق
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // برتقالي
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // أخضر
  static const Color error = Color(0xFFF44336); // أحمر
  static const Color warning = Color(0xFFFFC107); // أصفر
  static const Color info = Color(0xFF2196F3); // أزرق

  // Trip State Colors
  static const Color stateDraft = Color(0xFF9E9E9E); // رمادي
  static const Color statePlanned = Color(0xFF2196F3); // أزرق
  static const Color stateOngoing = Color(0xFFFF9800); // برتقالي
  static const Color stateDone = Color(0xFF4CAF50); // أخضر
  static const Color stateCancelled = Color(0xFFF44336); // أحمر

  // Trip Line Status Colors
  static const Color statusNotStarted = Color(0xFF9E9E9E); // رمادي
  static const Color statusAbsent = Color(0xFFF44336); // أحمر
  static const Color statusBoarded = Color(0xFF2196F3); // أزرق
  static const Color statusDropped = Color(0xFF4CAF50); // أخضر

  // Neutral Colors (Light Theme)
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors (Light Theme)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Text Colors (Dark Theme)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textDisabledDark = Color(0xFF666666);

  // Border Colors (Dark Theme)
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerDark = Color(0xFF424242);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Map Colors
  static const Color mapMarkerPickup = Color(0xFF2196F3);
  static const Color mapMarkerDropoff = Color(0xFF4CAF50);
  static const Color mapMarkerCurrent = Color(0xFFFF9800);
  static const Color mapRoute = Color(0xFF2196F3);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
  ];
}
