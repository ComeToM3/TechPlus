import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme_constants.dart';
import '../accessibility/accessibility_utils.dart';
import '../accessibility/accessibility_constants.dart';

/// Thème de l'application TechPlus - Tendances 2025
class AppTheme {
  static ThemeData get lightTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: ThemeConstants.primaryColor,
      brightness: Brightness.light,
      primary: ThemeConstants.primaryColor,
      onPrimary: ThemeConstants.textOnPrimary,
      primaryContainer: ThemeConstants.primaryLight,
      onPrimaryContainer: ThemeConstants.textPrimary,
      secondary: ThemeConstants.secondaryColor,
      onSecondary: ThemeConstants.textOnSecondary,
      secondaryContainer: ThemeConstants.secondaryLight,
      onSecondaryContainer: ThemeConstants.textPrimary,
      tertiary: ThemeConstants.accentColor,
      onTertiary: ThemeConstants.textOnPrimary,
      error: ThemeConstants.errorColor,
      onError: ThemeConstants.textOnPrimary,
      surface: ThemeConstants.surfaceColor,
      onSurface: ThemeConstants.textPrimary,
      surfaceContainerHighest: ThemeConstants.surfaceVariant,
      onSurfaceVariant: ThemeConstants.textSecondary,
      outline: ThemeConstants.textTertiary,
      outlineVariant: ThemeConstants.disabledColor,
      shadow: ThemeConstants.textPrimary,
      scrim: ThemeConstants.textPrimary,
      inverseSurface: ThemeConstants.textPrimary,
      onInverseSurface: ThemeConstants.surfaceColor,
      inversePrimary: ThemeConstants.primaryLight,
    );

    // Améliorer le contraste pour l'accessibilité
    final accessibleColorScheme = baseColorScheme.copyWith(
      onSurface: AccessibilityUtils.adjustColorForContrast(
        baseColorScheme.onSurface,
        baseColorScheme.surface,
      ),
      onSurfaceVariant: AccessibilityUtils.adjustColorForContrast(
        baseColorScheme.onSurfaceVariant,
        baseColorScheme.surface,
      ),
      outline: AccessibilityUtils.adjustColorForContrast(
        baseColorScheme.outline,
        baseColorScheme.surface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: accessibleColorScheme,

      // Typographie
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeConstants.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.textSecondary,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: ThemeConstants.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textOnPrimary,
        ),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryColor,
          foregroundColor: ThemeConstants.textOnPrimary,
          minimumSize: const Size(
            AccessibilityConstants.minTouchTargetSize,
            AccessibilityConstants.minTouchTargetSize,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: ThemeConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: ThemeConstants.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.paddingM,
          vertical: ThemeConstants.paddingM,
        ),
        labelStyle: GoogleFonts.inter(color: ThemeConstants.textSecondary),
        hintStyle: GoogleFonts.inter(color: ThemeConstants.textSecondary),
      ),

      // Cartes - Configuration de base
      // cardTheme: CardTheme(...), // TODO: Configurer plus tard

      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ThemeConstants.surfaceColor,
        selectedItemColor: ThemeConstants.primaryColor,
        unselectedItemColor: ThemeConstants.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeConstants.primaryColor,
        brightness: Brightness.dark,
        primary: ThemeConstants.primaryLight,
        onPrimary: const Color(0xFF00332A),
        primaryContainer: ThemeConstants.primaryVariant,
        onPrimaryContainer: ThemeConstants.primaryLight,
        secondary: ThemeConstants.secondaryLight,
        onSecondary: const Color(0xFF2D1B00),
        secondaryContainer: ThemeConstants.secondaryVariant,
        onSecondaryContainer: ThemeConstants.secondaryLight,
        tertiary: const Color(0xFF9A7CFF),
        onTertiary: const Color(0xFF2A0054),
        error: const Color(0xFFFFB4AB),
        onError: const Color(0xFF690005),
        surface: const Color(0xFF0F1419),
        onSurface: const Color(0xFFE1E2E6),
        surfaceContainerHighest: const Color(0xFF1A1F24),
        onSurfaceVariant: const Color(0xFFC3C7CF),
        outline: const Color(0xFF8D9199),
        outlineVariant: const Color(0xFF44474E),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: const Color(0xFFE1E2E6),
        onInverseSurface: const Color(0xFF0F1419),
        inversePrimary: ThemeConstants.primaryVariant,
      ),

      // Typographie pour le mode sombre
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE1E2E6),
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE1E2E6),
            ),
            headlineSmall: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE1E2E6),
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE1E2E6),
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE1E2E6),
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: const Color(0xFFE1E2E6),
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFFE1E2E6),
            ),
            bodySmall: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFFC3C7CF),
            ),
          ),

      // AppBar pour le mode sombre
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F1419),
        foregroundColor: const Color(0xFFE1E2E6),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE1E2E6),
        ),
      ),

      // Boutons pour le mode sombre
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryLight,
          foregroundColor: const Color(0xFF00332A),
          minimumSize: const Size(
            double.infinity,
            ThemeConstants.buttonHeightM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Champs de saisie pour le mode sombre
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1F24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: Color(0xFF44474E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: Color(0xFF44474E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: ThemeConstants.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.paddingM,
          vertical: ThemeConstants.paddingM,
        ),
        labelStyle: GoogleFonts.inter(color: const Color(0xFFC3C7CF)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF8D9199)),
      ),

      // Navigation pour le mode sombre
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0F1419),
        selectedItemColor: ThemeConstants.primaryLight,
        unselectedItemColor: const Color(0xFF8D9199),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
