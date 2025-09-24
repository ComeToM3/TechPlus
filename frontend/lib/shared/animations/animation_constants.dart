import 'package:flutter/material.dart';

/// Constantes pour les animations de l'application
class AnimationConstants {
  // Durées d'animation
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Courbes d'animation
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Valeurs d'animation
  static const double scaleSmall = 0.8;
  static const double scaleNormal = 1.0;
  static const double scaleLarge = 1.1;
  
  static const double opacityTransparent = 0.0;
  static const double opacitySemiTransparent = 0.5;
  static const double opacityOpaque = 1.0;

  // Délais d'animation
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration pageTransitionDelay = Duration(milliseconds: 150);
}

/// Types d'animations disponibles
enum AnimationType {
  fadeIn,
  fadeOut,
  slideInFromTop,
  slideInFromBottom,
  slideInFromLeft,
  slideInFromRight,
  scaleIn,
  scaleOut,
  bounceIn,
  elasticIn,
  rotation,
  shimmer,
}

/// Configuration d'animation personnalisée
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double? begin;
  final double? end;
  final Offset? offset;
  final AnimationType type;

  const AnimationConfig({
    required this.duration,
    required this.curve,
    required this.type,
    this.begin,
    this.end,
    this.offset,
  });

  // Configurations prédéfinies
  static const AnimationConfig fadeIn = AnimationConfig(
    duration: AnimationConstants.normal,
    curve: AnimationConstants.easeInOut,
    type: AnimationType.fadeIn,
    begin: 0.0,
    end: 1.0,
  );

  static const AnimationConfig fadeOut = AnimationConfig(
    duration: AnimationConstants.fast,
    curve: AnimationConstants.easeOut,
    type: AnimationType.fadeOut,
    begin: 1.0,
    end: 0.0,
  );

  static const AnimationConfig slideInFromBottom = AnimationConfig(
    duration: AnimationConstants.normal,
    curve: AnimationConstants.easeOut,
    type: AnimationType.slideInFromBottom,
    offset: Offset(0, 1),
  );

  static const AnimationConfig slideInFromTop = AnimationConfig(
    duration: AnimationConstants.normal,
    curve: AnimationConstants.easeOut,
    type: AnimationType.slideInFromTop,
    offset: Offset(0, -1),
  );

  static const AnimationConfig scaleIn = AnimationConfig(
    duration: AnimationConstants.normal,
    curve: AnimationConstants.elasticOut,
    type: AnimationType.scaleIn,
    begin: 0.0,
    end: 1.0,
  );

  static const AnimationConfig bounceIn = AnimationConfig(
    duration: AnimationConstants.slow,
    curve: AnimationConstants.bounceOut,
    type: AnimationType.bounceIn,
    begin: 0.0,
    end: 1.0,
  );
}
