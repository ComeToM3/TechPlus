import 'package:flutter/material.dart';

/// Constantes du thème de l'application - Tendances 2025
class ThemeConstants {
  // === COULEURS PRINCIPALES (Tendances 2025) ===

  // Palette principale - Vert moderne et sophistiqué
  static const Color primaryColor = Color(0xFF00C896); // Vert émeraude moderne
  static const Color primaryVariant = Color(0xFF00A67E); // Vert plus foncé
  static const Color primaryLight = Color(0xFF4DD4B0); // Vert clair

  // Palette secondaire - Or chaleureux
  static const Color secondaryColor = Color(0xFFFFB800); // Or moderne
  static const Color secondaryVariant = Color(0xFFE6A600); // Or foncé
  static const Color secondaryLight = Color(0xFFFFD54F); // Or clair

  // Couleurs d'accent - Palette émotionnelle
  static const Color accentColor = Color(0xFF6C5CE7); // Violet moderne
  static const Color successColor = Color(0xFF00B894); // Vert succès
  static const Color warningColor = Color(0xFFFDCB6E); // Orange doux
  static const Color errorColor = Color(0xFFE17055); // Rouge corail
  static const Color infoColor = Color(0xFF74B9FF); // Bleu ciel

  // === COULEURS DE SURFACE (Design minimaliste avancé) ===
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFF1F3F4);
  static const Color backgroundColor = Color(0xFFFAFBFC);

  // === COULEURS DE TEXTE (Accessibilité optimisée) ===
  static const Color textPrimary = Color(0xFF1A1A1A); // Noir doux
  static const Color textSecondary = Color(0xFF6C757D); // Gris moderne
  static const Color textTertiary = Color(0xFFADB5BD); // Gris clair
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1A1A1A);

  // === COULEURS D'ÉTAT (Micro-interactions) ===
  static const Color hoverColor = Color(0xFFE3F2FD);
  static const Color pressedColor = Color(0xFFBBDEFB);
  static const Color focusColor = Color(0xFF2196F3);
  static const Color disabledColor = Color(0xFFE0E0E0);

  // === ESPACEMENTS (Style BENTO modulaire) ===
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Espacements BENTO (grille modulaire)
  static const double bentoGap = 16.0;
  static const double bentoPadding = 20.0;
  static const double bentoRadius = 16.0;

  // === RAYONS DE BORDURE (Design moderne) ===
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // === TAILLES D'ICÔNES (Hiérarchie visuelle) ===
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;

  // === HAUTEURS DE COMPOSANTS (Accessibilité) ===
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 80.0;

  // === MICRO-INTERACTIONS (Tendances 2025) ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Courbes d'animation
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // === OMBRES (Design immersif) ===
  static const List<BoxShadow> shadowS = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowM = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowL = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowXL = [
    BoxShadow(color: Color(0x24000000), blurRadius: 24, offset: Offset(0, 12)),
  ];

  // === BREAKPOINTS RESPONSIVE ===
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1200.0;
  static const double wideBreakpoint = 1440.0;
}
