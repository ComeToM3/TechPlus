import 'dart:math';
import 'package:flutter/material.dart';
import 'accessibility_constants.dart';

/// Utilitaires pour l'accessibilité
class AccessibilityUtils {
  // === CALCUL DU CONTRASTE ===

  /// Calcule le ratio de contraste entre deux couleurs
  /// Retourne un ratio entre 1 et 21 (21:1 étant le maximum)
  static double calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = _getRelativeLuminance(color1);
    final luminance2 = _getRelativeLuminance(color2);

    final lighter = max(luminance1, luminance2);
    final darker = min(luminance1, luminance2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calcule la luminance relative d'une couleur (0.0 à 1.0)
  static double _getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearise un composant de couleur pour le calcul de luminance
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Vérifie si le contraste respecte WCAG 2.1 AA
  static bool isContrastCompliant(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    final requiredRatio = isLargeText
        ? AccessibilityConstants.minContrastRatioLarge
        : AccessibilityConstants.minContrastRatio;

    return ratio >= requiredRatio;
  }

  /// Ajuste une couleur pour respecter le contraste minimum
  static Color adjustColorForContrast(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    if (isContrastCompliant(foreground, background, isLargeText: isLargeText)) {
      return foreground;
    }

    // Ajuster la luminosité pour améliorer le contraste
    final hsl = HSLColor.fromColor(foreground);
    // final requiredRatio = isLargeText
    //     ? AccessibilityConstants.minContrastRatioLarge
    //     : AccessibilityConstants.minContrastRatio;

    // Essayer d'ajuster la luminosité
    double lightness = hsl.lightness;
    const step = 0.1;

    // Essayer de rendre plus sombre
    while (lightness > 0.0) {
      lightness -= step;
      final adjustedColor = hsl
          .withLightness(lightness.clamp(0.0, 1.0))
          .toColor();
      if (isContrastCompliant(
        adjustedColor,
        background,
        isLargeText: isLargeText,
      )) {
        return adjustedColor;
      }
    }

    // Essayer de rendre plus clair
    lightness = hsl.lightness;
    while (lightness < 1.0) {
      lightness += step;
      final adjustedColor = hsl
          .withLightness(lightness.clamp(0.0, 1.0))
          .toColor();
      if (isContrastCompliant(
        adjustedColor,
        background,
        isLargeText: isLargeText,
      )) {
        return adjustedColor;
      }
    }

    // Si aucun ajustement ne fonctionne, retourner la couleur originale
    return foreground;
  }

  // === GESTION DES TOUCH TARGETS ===

  /// Vérifie si un élément respecte la taille minimale de touch target
  static bool isTouchTargetCompliant(Size size) {
    return size.width >= AccessibilityConstants.minTouchTargetSize &&
        size.height >= AccessibilityConstants.minTouchTargetSize;
  }

  /// Ajuste la taille d'un widget pour respecter les touch targets
  static Widget ensureMinTouchTarget(Widget child, {double? minSize}) {
    final size = minSize ?? AccessibilityConstants.minTouchTargetSize;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: child,
    );
  }

  // === GESTION DU FOCUS ===

  /// Crée un focus ring personnalisé
  static Widget createFocusRing({
    required Widget child,
    required bool hasFocus,
    Color? focusColor,
    double? focusWidth,
    BorderRadius? borderRadius,
  }) {
    final color = focusColor ?? AccessibilityConstants.focusRingColor;
    final width = focusWidth ?? AccessibilityConstants.focusRingWidth;
    final radius = borderRadius ?? BorderRadius.circular(4.0);

    return Container(
      decoration: hasFocus
          ? BoxDecoration(
              border: Border.all(color: color, width: width),
              borderRadius: radius,
            )
          : null,
      child: child,
    );
  }

  // === GESTION DES ANIMATIONS ===

  /// Vérifie si une durée d'animation respecte WCAG
  static bool isAnimationDurationCompliant(Duration duration) {
    return duration <= AccessibilityConstants.maxAnimationDuration;
  }

  /// Crée une animation respectant les standards d'accessibilité
  static AnimationController createAccessibleAnimationController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    final animationDuration =
        duration ?? AccessibilityConstants.recommendedTransitionDuration;

    return AnimationController(duration: animationDuration, vsync: vsync);
  }

  // === GESTION DES LABELS SÉMANTIQUES ===

  /// Obtient un label sémantique pour une action
  static String getSemanticLabel(String key) {
    return AccessibilityConstants.semanticLabels[key] ?? key;
  }

  /// Obtient un rôle sémantique pour un composant
  static String getSemanticRole(String key) {
    return AccessibilityConstants.semanticRoles[key] ?? key;
  }

  /// Obtient un message d'accessibilité
  static String getAccessibilityMessage(String key) {
    return AccessibilityConstants.accessibilityMessages[key] ?? key;
  }

  // === GESTION DES ANNONCES ===

  /// Crée un message d'annonce pour les lecteurs d'écran
  static String createAnnouncement(String message, {String? priority}) {
    final priorityLevel = priority ?? 'info';
    final priorityText =
        AccessibilityConstants.accessibilityMessages[priorityLevel] ?? '';

    if (priorityText.isNotEmpty) {
      return '$priorityText: $message';
    }

    return message;
  }

  // === TESTS D'ACCESSIBILITÉ ===

  /// Teste le contraste d'une palette de couleurs
  static Map<String, dynamic> testColorContrast(List<Color> colors) {
    final results = <String, dynamic>{};

    for (int i = 0; i < colors.length; i++) {
      for (int j = i + 1; j < colors.length; j++) {
        final color1 = colors[i];
        final color2 = colors[j];
        final ratio = calculateContrastRatio(color1, color2);

        final key =
            '${color1.value.toRadixString(16)}_${color2.value.toRadixString(16)}';
        results[key] = {
          'color1': color1,
          'color2': color2,
          'ratio': ratio,
          'compliant': ratio >= AccessibilityConstants.minContrastRatio,
          'compliantLarge':
              ratio >= AccessibilityConstants.minContrastRatioLarge,
        };
      }
    }

    return results;
  }

  /// Teste la taille des touch targets
  static Map<String, dynamic> testTouchTargets(List<Size> sizes) {
    final results = <String, dynamic>{};

    for (int i = 0; i < sizes.length; i++) {
      final size = sizes[i];
      final key = 'target_$i';

      results[key] = {
        'size': size,
        'compliant': isTouchTargetCompliant(size),
        'minRequired': AccessibilityConstants.minTouchTargetSize,
      };
    }

    return results;
  }

  // === UTILITAIRES POUR LES THÈMES ===

  /// Crée un thème accessible
  static ThemeData createAccessibleTheme({
    required ThemeData baseTheme,
    required ColorScheme colorScheme,
  }) {
    return baseTheme.copyWith(
      colorScheme: colorScheme,
      // Améliorer le contraste des couleurs
      textTheme: baseTheme.textTheme.apply(
        bodyColor: adjustColorForContrast(
          colorScheme.onSurface,
          colorScheme.surface,
        ),
        displayColor: adjustColorForContrast(
          colorScheme.onSurface,
          colorScheme.surface,
        ),
      ),
      // Améliorer les boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AccessibilityConstants.minTouchTargetSize,
            AccessibilityConstants.minTouchTargetSize,
          ),
        ),
      ),
      // Améliorer les champs de texte
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
    );
  }
}
