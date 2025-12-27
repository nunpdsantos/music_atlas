import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Brand Colors (from your reference)
  static const Color tonicBlue = Color(0xFF1D4ED8);
  static const Color minorAmber = Color(0xFFA36D11); // Legacy - use minorTeal instead
  static const Color accentRed = Color(0xFFBE123C);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF8FAFC); // Light Grey/White
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE5E7EB);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF6B7280); // Slate 500

  // Tints
  static const Color majorLight = Color(0xFFE7F0FF);
  static const Color minorLight = Color(0xFFE0F2F1); // Teal tint (was amber)
  static const Color blueMediumTint = Color(0xFFE0ECFF);
  static const Color amberMediumTint = Color(0xFFF7E3B2);

  // ============================================
  // CHORD QUALITY COLORS (standardized)
  // ============================================

  // Major chord colors (Blue)
  static const Color majorBgLight = Color(0xFFE7F0FF);
  static const Color majorBgDark = Color(0xFF1E3A5F);
  static const Color majorTextLight = Color(0xFF1D4ED8);
  static const Color majorTextDark = Color(0xFF60A5FA);

  // Minor chord colors (Teal - cleaner than amber)
  static const Color minorBgLight = Color(0xFFE0F2F1);
  static const Color minorBgDark = Color(0xFF134E4A);
  static const Color minorTextLight = Color(0xFF0D9488);
  static const Color minorTextDark = Color(0xFF2DD4BF);

  // Diminished chord colors (Red)
  static const Color dimBgLight = Color(0xFFFFEBEE);
  static const Color dimBgDark = Color(0xFF4A1515);
  static const Color dimTextLight = Color(0xFFD32F2F);
  static const Color dimTextDark = Color(0xFFF87171);

  // Augmented chord colors (Purple)
  static const Color augBgLight = Color(0xFFF3E8FF);
  static const Color augBgDark = Color(0xFF2D1B4E);
  static const Color augTextLight = Color(0xFF7C3AED);
  static const Color augTextDark = Color(0xFFA78BFA);

  // ============================================
  // INTERVAL COLORS (for fretboard/piano visualization)
  // ============================================
  
  static const Map<int, Color> intervalColors = {
    0: tonicBlue,              // Root / Unison
    1: Color(0xFFEF4444),      // minor 2nd (b2)
    2: Color(0xFFF97316),      // Major 2nd
    3: Color(0xFFEAB308),      // minor 3rd (b3)
    4: Color(0xFFF59E0B),      // Major 3rd
    5: Color(0xFF22C55E),      // Perfect 4th
    6: Color(0xFF10B981),      // Tritone (b5/#4)
    7: Color(0xFF3B82F6),      // Perfect 5th
    8: Color(0xFF6366F1),      // minor 6th (b6)
    9: Color(0xFF8B5CF6),      // Major 6th
    10: Color(0xFFA855F7),     // minor 7th (b7)
    11: Color(0xFFD946EF),     // Major 7th
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

  /// Get color for an interval (0-11 semitones from root)
  static Color getIntervalColor(int interval) {
    return intervalColors[interval % 12] ?? textSecondary;
  }

  /// Get label for an interval
  static String getIntervalLabel(int interval) {
    return intervalLabels[interval % 12] ?? '?';
  }

  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  static const Color darkScaffoldBg = Color(0xFF0F172A);
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkBorderColor = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Tints for dark mode
  static const Color darkMajorLight = Color(0xFF1E3A5F);
  static const Color darkMinorLight = Color(0xFF134E4A); // Teal (was brown 0xFF422006)

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
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        bodyLarge: const TextStyle(color: textSecondary),
        bodyMedium: const TextStyle(color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: majorLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tonicBlue);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 26, color: tonicBlue);
          }
          return const IconThemeData(size: 26, color: textSecondary);
        }),
      ),
    );
  }

  // ============================================
  // THEME-AWARE HELPER METHODS
  // ============================================

  /// Get scaffold background color based on current theme
  static Color getScaffoldBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkScaffoldBg 
        : scaffoldBg;
  }

  /// Get card background color based on current theme
  static Color getCardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCardBg 
        : cardBg;
  }

  /// Get border color based on current theme
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBorderColor 
        : borderColor;
  }

  /// Get primary text color based on current theme
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : textPrimary;
  }

  /// Get secondary text color based on current theme
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : textSecondary;
  }

  /// Get major light tint based on current theme
  static Color getMajorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkMajorLight 
        : majorLight;
  }

  /// Get minor light tint based on current theme
  static Color getMinorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkMinorLight 
        : minorLight;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get input fill color based on current theme
  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
  }

  // ============================================
  // CHORD QUALITY COLOR HELPERS
  // ============================================

  /// Get background and text colors for a chord based on its quality
  /// Returns (backgroundColor, textColor)
  static (Color, Color) getChordQualityColors(BuildContext context, {
    required bool isMajor,
    required bool isMinor,
    required bool isDim,
    required bool isAug,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDim) {
      return (
        isDark ? dimBgDark : dimBgLight,
        isDark ? dimTextDark : dimTextLight,
      );
    } else if (isAug) {
      return (
        isDark ? augBgDark : augBgLight,
        isDark ? augTextDark : augTextLight,
      );
    } else if (isMinor) {
      return (
        isDark ? minorBgDark : minorBgLight,
        isDark ? minorTextDark : minorTextLight,
      );
    } else {
      // Major (default)
      return (
        isDark ? majorBgDark : majorBgLight,
        isDark ? majorTextDark : majorTextLight,
      );
    }
  }

  /// Get major chord colors based on theme
  static (Color, Color) getMajorChordColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      isDark ? majorBgDark : majorBgLight,
      isDark ? majorTextDark : majorTextLight,
    );
  }

  /// Get minor chord colors based on theme
  static (Color, Color) getMinorChordColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      isDark ? minorBgDark : minorBgLight,
      isDark ? minorTextDark : minorTextLight,
    );
  }

  /// Get diminished chord colors based on theme
  static (Color, Color) getDimChordColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      isDark ? dimBgDark : dimBgLight,
      isDark ? dimTextDark : dimTextLight,
    );
  }

  /// Get augmented chord colors based on theme
  static (Color, Color) getAugChordColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      isDark ? augBgDark : augBgLight,
      isDark ? augTextDark : augTextLight,
    );
  }

  /// Get major text color based on theme (for scale notes, borders, etc.)
  static Color getMajorTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? majorTextDark
        : majorTextLight;
  }

  /// Get minor text color based on theme (for scale notes, borders, etc.)
  static Color getMinorTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? minorTextDark
        : minorTextLight;
  }

  // ============================================
  // LEGACY METHOD ALIASES (for compatibility)
  // ============================================
  
  static Color cardBackground(BuildContext context) => getCardBg(context);
  static Color border(BuildContext context) => getBorderColor(context);
  static Color textPrimaryColor(BuildContext context) => getTextPrimary(context);
  static Color textSecondaryColor(BuildContext context) => getTextSecondary(context);
  static Color majorLightColor(BuildContext context) => getMajorLight(context);
  static Color minorLightColor(BuildContext context) => getMinorLight(context);
  static Color scaffoldBackground(BuildContext context) => getScaffoldBg(context);

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
        displayLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800),
        bodyLarge: const TextStyle(color: darkTextSecondary),
        bodyMedium: const TextStyle(color: darkTextPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkScaffoldBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardBg,
        indicatorColor: darkMajorLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tonicBlue);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(size: 26, color: tonicBlue);
          }
          return const IconThemeData(size: 26, color: darkTextSecondary);
        }),
      ),
    );
  }
}
