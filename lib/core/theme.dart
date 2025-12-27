import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Music Atlas Design System v2.0
/// A modern, premium design language for music education
class AppTheme {
  // ============================================
  // BRAND COLORS - Refined palette
  // ============================================
  static const Color tonicBlue = Color(0xFF2563EB);      // Vibrant blue
  static const Color minorAmber = Color(0xFFD97706);     // Warm amber
  static const Color accentRed = Color(0xFFDC2626);      // Alert red
  static const Color successGreen = Color(0xFF059669);   // Success green
  static const Color accentPurple = Color(0xFF7C3AED);   // Accent purple

  // ============================================
  // LIGHT THEME COLORS
  // ============================================
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Tints
  static const Color majorLight = Color(0xFFEFF6FF);
  static const Color minorLight = Color(0xFFFFFBEB);
  static const Color blueMediumTint = Color(0xFFDBEAFE);
  static const Color amberMediumTint = Color(0xFFFEF3C7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ============================================
  // DARK THEME COLORS
  // ============================================
  static const Color darkScaffoldBg = Color(0xFF0F172A);
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkCardBgElevated = Color(0xFF334155);
  static const Color darkBorderColor = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Dark mode tints
  static const Color darkMajorLight = Color(0xFF1E3A5F);
  static const Color darkMinorLight = Color(0xFF422006);

  // ============================================
  // SPACING SYSTEM (8pt grid)
  // ============================================
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // ============================================
  // BORDER RADIUS
  // ============================================
  static const double radiusXs = 6;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2Xl = 24;
  static const double radius3Xl = 32;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);

  // ============================================
  // ANIMATION CURVES
  // ============================================
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;
  static const Curve curveEaseInOut = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;

  // ============================================
  // SHADOWS
  // ============================================
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  // ============================================
  // INTERVAL COLORS (chromatic visualization)
  // ============================================
  static const Map<int, Color> intervalColors = {
    0: tonicBlue,              // Root / Unison
    1: Color(0xFFEF4444),      // minor 2nd (b2)
    2: Color(0xFFF97316),      // Major 2nd
    3: Color(0xFFEAB308),      // minor 3rd (b3)
    4: Color(0xFFF59E0B),      // Major 3rd
    5: Color(0xFF22C55E),      // Perfect 4th
    6: Color(0xFF14B8A6),      // Tritone (b5/#4)
    7: Color(0xFF3B82F6),      // Perfect 5th
    8: Color(0xFF6366F1),      // minor 6th (b6)
    9: Color(0xFF8B5CF6),      // Major 6th
    10: Color(0xFFA855F7),     // minor 7th (b7)
    11: Color(0xFFEC4899),     // Major 7th
  };

  static const Map<int, String> intervalLabels = {
    0: 'Root',
    1: '♭2',
    2: '2nd',
    3: '♭3',
    4: '3rd',
    5: '4th',
    6: '♭5',
    7: '5th',
    8: '♭6',
    9: '6th',
    10: '♭7',
    11: '7th',
  };

  static Color getIntervalColor(int interval) {
    return intervalColors[interval % 12] ?? textSecondary;
  }

  static String getIntervalLabel(int interval) {
    return intervalLabels[interval % 12] ?? '?';
  }

  // ============================================
  // THEME-AWARE HELPER METHODS
  // ============================================
  static Color getScaffoldBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkScaffoldBg
        : scaffoldBg;
  }

  static Color getCardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBg
        : cardBg;
  }

  static Color getCardBgElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBgElevated
        : surfaceElevated;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : borderColor;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : textTertiary;
  }

  static Color getMajorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkMajorLight
        : majorLight;
  }

  static Color getMinorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkMinorLight
        : minorLight;
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
  }

  static List<BoxShadow> getShadow(BuildContext context, {String size = 'md'}) {
    if (isDark(context)) return [];
    switch (size) {
      case 'sm':
        return shadowSm;
      case 'lg':
        return shadowLg;
      case 'xl':
        return shadowXl;
      default:
        return shadowMd;
    }
  }

  // Legacy method aliases (for compatibility)
  static Color cardBackground(BuildContext context) => getCardBg(context);
  static Color border(BuildContext context) => getBorderColor(context);
  static Color textPrimaryColor(BuildContext context) => getTextPrimary(context);
  static Color textSecondaryColor(BuildContext context) => getTextSecondary(context);
  static Color majorLightColor(BuildContext context) => getMajorLight(context);
  static Color minorLightColor(BuildContext context) => getMinorLight(context);
  static Color scaffoldBackground(BuildContext context) => getScaffoldBg(context);

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tonicBlue,
        surface: cardBg,
        onSurface: textPrimary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyLarge: const TextStyle(color: textSecondary),
        bodyMedium: const TextStyle(color: textPrimary),
        labelLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        elevation: 0,
        indicatorColor: majorLight,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tonicBlue,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 24, color: tonicBlue);
          }
          return const IconThemeData(size: 24, color: textSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: tonicBlue, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tonicBlue,
        surface: darkCardBg,
        onSurface: darkTextPrimary,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: const TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyLarge: const TextStyle(color: darkTextSecondary),
        bodyMedium: const TextStyle(color: darkTextPrimary),
        labelLarge: const TextStyle(
          color: darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkScaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardBg,
        elevation: 0,
        indicatorColor: darkMajorLight,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tonicBlue,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 24, color: tonicBlue);
          }
          return const IconThemeData(size: 24, color: darkTextSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: tonicBlue, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
