import 'package:flutter/material.dart';

/// Utilitaires pour le design responsive
class ResponsiveUtils {
  // Breakpoints selon les standards Material Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 840;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Détermine le type d'écran basé sur la largeur
  static ScreenType getScreenType(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Vérifie si l'écran est large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Retourne le nombre de colonnes selon le type d'écran
  static int getColumnCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isDesktop(context)) return 3;
    return 4;
  }

  /// Retourne l'espacement selon le type d'écran
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  /// Retourne la taille de police selon le type d'écran
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  /// Retourne le padding selon le type d'écran
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Retourne la largeur maximale du contenu selon le type d'écran
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    if (isDesktop(context)) return 1200;
    return 1400;
  }

  /// Retourne la hauteur de l'AppBar selon le type d'écran
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return 56.0;
    return 64.0;
  }

  /// Retourne la taille des icônes selon le type d'écran
  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) return baseIconSize;
    if (isTablet(context)) return baseIconSize * 1.1;
    return baseIconSize * 1.2;
  }

  /// Retourne le rayon de bordure selon le type d'écran
  static double getBorderRadius(BuildContext context, double baseRadius) {
    if (isMobile(context)) return baseRadius;
    if (isTablet(context)) return baseRadius * 1.1;
    return baseRadius * 1.2;
  }

  /// Retourne la largeur du drawer selon le type d'écran
  static double getDrawerWidth(BuildContext context) {
    if (isMobile(context)) return 280.0;
    if (isTablet(context)) return 320.0;
    return 360.0;
  }

  /// Retourne la hauteur des boutons selon le type d'écran
  static double getButtonHeight(BuildContext context, ButtonSize size) {
    final baseHeight = switch (size) {
      ButtonSize.small => 32.0,
      ButtonSize.medium => 40.0,
      ButtonSize.large => 48.0,
    };

    if (isMobile(context)) return baseHeight;
    if (isTablet(context)) return baseHeight * 1.1;
    return baseHeight * 1.2;
  }

  /// Retourne la largeur des boutons selon le type d'écran
  static double getButtonWidth(BuildContext context, ButtonSize size) {
    final baseWidth = switch (size) {
      ButtonSize.small => 80.0,
      ButtonSize.medium => 120.0,
      ButtonSize.large => 160.0,
    };

    if (isMobile(context)) return baseWidth;
    if (isTablet(context)) return baseWidth * 1.1;
    return baseWidth * 1.2;
  }

  /// Retourne le nombre d'éléments par ligne dans une grille
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isDesktop(context)) return 3;
    return 4;
  }

  /// Retourne l'espacement entre les éléments de grille
  static double getGridSpacing(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 12.0;
    return 16.0;
  }

  /// Retourne la largeur de la sidebar selon le type d'écran
  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) return 0; // Pas de sidebar sur mobile
    if (isTablet(context)) return 200.0;
    return 250.0;
  }

  /// Retourne la hauteur de la bottom navigation selon le type d'écran
  static double getBottomNavigationHeight(BuildContext context) {
    if (isMobile(context)) return 56.0;
    return 64.0;
  }

  /// Retourne la taille des avatars selon le type d'écran
  static double getAvatarSize(BuildContext context, AvatarSize size) {
    final baseSize = switch (size) {
      AvatarSize.small => 24.0,
      AvatarSize.medium => 40.0,
      AvatarSize.large => 56.0,
      AvatarSize.xlarge => 80.0,
    };

    if (isMobile(context)) return baseSize;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  /// Retourne la largeur des cartes selon le type d'écran
  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 300.0;
    if (isDesktop(context)) return 350.0;
    return 400.0;
  }

  /// Retourne la hauteur des cartes selon le type d'écran
  static double getCardHeight(BuildContext context, CardSize size) {
    final baseHeight = switch (size) {
      CardSize.small => 120.0,
      CardSize.medium => 180.0,
      CardSize.large => 240.0,
    };

    if (isMobile(context)) return baseHeight;
    if (isTablet(context)) return baseHeight * 1.1;
    return baseHeight * 1.2;
  }

  /// Retourne la largeur des modales selon le type d'écran
  static double getModalWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 500.0;
    return 600.0;
  }

  /// Retourne la hauteur des modales selon le type d'écran
  static double getModalHeight(BuildContext context) {
    if (isMobile(context)) return MediaQuery.of(context).size.height * 0.9;
    if (isTablet(context)) return 600.0;
    return 700.0;
  }

  /// Retourne la largeur des formulaires selon le type d'écran
  static double getFormWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 400.0;
    return 500.0;
  }

  /// Retourne l'espacement des champs de formulaire selon le type d'écran
  static double getFormFieldSpacing(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 20.0;
    return 24.0;
  }

  /// Retourne la largeur des images selon le type d'écran
  static double getImageWidth(BuildContext context, ImageSize size) {
    final baseWidth = switch (size) {
      ImageSize.small => 100.0,
      ImageSize.medium => 200.0,
      ImageSize.large => 300.0,
      ImageSize.xlarge => 400.0,
    };

    if (isMobile(context)) return baseWidth;
    if (isTablet(context)) return baseWidth * 1.2;
    return baseWidth * 1.5;
  }

  /// Retourne la hauteur des images selon le type d'écran
  static double getImageHeight(BuildContext context, ImageSize size) {
    final baseHeight = switch (size) {
      ImageSize.small => 75.0,
      ImageSize.medium => 150.0,
      ImageSize.large => 225.0,
      ImageSize.xlarge => 300.0,
    };

    if (isMobile(context)) return baseHeight;
    if (isTablet(context)) return baseHeight * 1.2;
    return baseHeight * 1.5;
  }
}

/// Types d'écran
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Tailles de boutons
enum ButtonSize {
  small,
  medium,
  large,
}

/// Tailles d'avatars
enum AvatarSize {
  small,
  medium,
  large,
  xlarge,
}

/// Tailles de cartes
enum CardSize {
  small,
  medium,
  large,
}

/// Tailles d'images
enum ImageSize {
  small,
  medium,
  large,
  xlarge,
}
