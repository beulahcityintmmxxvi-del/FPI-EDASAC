import 'package:flutter/material.dart';

/// Academic Color Palette - Deep Green, Gold, Red, Orange, Blue
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================

  /// Deep Green - Primary Brand (Growth, Learning, Achievement)
  static const Color primaryGreen = Color(0xFF006633);
  static const Color primaryGreenLight = Color(0xFF2E8B57);
  static const Color primaryGreenDark = Color(0xFF004225);

  /// Gold - Excellence, Achievement, Premium
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF4C430);
  static const Color goldDark = Color(0xFFB8860B);

  /// Red - Urgency, Important, Alerts
  static const Color red = Color(0xFFC8102E);
  static const Color redLight = Color(0xFFE63946);
  static const Color redDark = Color(0xFF8B0000);

  /// Orange - Energy, Warmth, Progress
  static const Color orange = Color(0xFFE87722);
  static const Color orangeLight = Color(0xFFF59A3C);
  static const Color orangeDark = Color(0xFFCC5500);

  /// Blue - Trust, Knowledge, Professionalism
  static const Color blue = Color(0xFF003F7D);
  static const Color blueLight = Color(0xFF1E5AAA);
  static const Color blueDark = Color(0xFF002855);

  // ==================== NEUTRAL COLORS ====================

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color mediumGray = Color(0xFF757575);
  static const Color darkGray = Color(0xFF424242);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color black = Color(0xFF000000);

  // ==================== SEMANTIC COLORS ====================

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ==================== BACKGROUND COLORS ====================

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color backgroundCardDark = Color(0xFF2C2C2C);

  // ==================== TEXT COLORS ====================

  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // ==================== BORDER COLORS ====================

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E0);
  static const Color borderDark = Color(0xFF4A5568);

  // ==================== GRADIENTS ====================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryGreenDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDark],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blueDark],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDark],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red, redDark],
  );

  // Academic shimmer effect
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
  );

  // ==================== ROLE-BASED COLORS ====================

  static const Color adminColor = red;
  static const Color tutorColor = blue;
  static const Color studentColor = primaryGreen;

  // ==================== SHADOW COLORS ====================

  static Color shadowLight = black.withValues(alpha: 0.08);
  static Color shadowMedium = black.withValues(alpha: 0.12);
  static Color shadowDark = black.withValues(alpha: 0.16);
}
