import 'package:flutter/material.dart';

/// Design System unifié pour l'application TechPlus
class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF212121);
  static const Color onBackgroundColor = Color(0xFF212121);
  
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double appBarElevation = 0.0;
  
  /// Thème sombre de l'application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: appBarElevation,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  /// Thème principal de l'application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: appBarElevation,
        centerTitle: true,
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
  
  /// Couleurs personnalisées pour les métriques
  static const Map<String, Color> metricColors = {
    'reservations': Color(0xFF2196F3),
    'tables': Color(0xFF4CAF50),
    'revenue': Color(0xFFFF9800),
    'customers': Color(0xFF9C27B0),
    'pending': Color(0xFFFF9800),
    'confirmed': Color(0xFF4CAF50),
    'cancelled': Color(0xFFF44336),
  };
  
  /// Espacements standardisés
  static const Map<String, double> spacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
    'xxl': 48.0,
  };
  
  /// Tailles de texte standardisées
  static const Map<String, TextStyle> textStyles = {
    'h1': TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    'h2': TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    'h3': TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    'h4': TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    'body1': TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    'body2': TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    'caption': TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
  };
}