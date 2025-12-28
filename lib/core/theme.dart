import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Brand Colors (from your reference)
  static const Color tonicBlue = Color(0xFF1D4ED8);
  static const Color minorAmber = Color(0xFFA36D11);
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
  static const Color minorLight = Color(0xFFFFF4D6);
  static const Color blueMediumTint = Color(0xFFE0ECFF);
  static const Color amberMediumTint = Color(0xFFF7E3B2);

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
  static const Color darkMinorLight = Color(0xFF422006);

  // Brighter accent colors for dark mode (better readability on dark backgrounds)
  static const Color darkTonicBlue = Color(0xFF60A5FA);      // Brighter blue for dark mode
  static const Color darkMinorAmber = Color(0xFFFBBF24);     // Brighter amber for dark mode
  static const Color darkAccentRed = Color(0xFFFB7185);      // Brighter red for dark mode

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

  /// Get tonic blue color based on current theme (for badge text)
  static Color getTonicBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTonicBlue
        : tonicBlue;
  }

  /// Get minor amber color based on current theme (for badge text)
  static Color getMinorAmber(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkMinorAmber
        : minorAmber;
  }

  /// Get accent red color based on current theme (for diminished chords)
  static Color getAccentRed(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAccentRed
        : accentRed;
  }

  /// Get input fill color based on current theme
  static Color getInputFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF1E293B) 
        : const Color(0xFFF1F5F9);
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
