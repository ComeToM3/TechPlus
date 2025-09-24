import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Transition de page avec slide depuis le bas
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  SlideUpPageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween.chain(
              CurveTween(curve: curve),
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Transition de page avec slide depuis la droite
class SlideRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  SlideRightPageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween.chain(
              CurveTween(curve: curve),
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Transition de page avec fade
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  FadePageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: curve)),
              child: child,
            );
          },
        );
}

/// Transition de page avec scale
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  ScalePageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation.drive(CurveTween(curve: curve)),
              child: child,
            );
          },
        );
}

/// Transition de page avec rotation
class RotationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  RotationPageRoute({
    required this.page,
    this.duration = AnimationConstants.slow,
    this.curve = AnimationConstants.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RotationTransition(
              turns: animation.drive(CurveTween(curve: curve)),
              child: child,
            );
          },
        );
}

/// Transition de page avec slide et fade combinés
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;

  SlideFadePageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
    this.slideOffset = const Offset(0.0, 0.3),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: slideOffset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Transition de page avec scale et fade combinés
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  ScaleFadePageRoute({
    required this.page,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
    this.beginScale = 0.8,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: beginScale,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Transition de page avec effet de rotation 3D
class Rotation3DPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  Rotation3DPageRoute({
    required this.page,
    this.duration = AnimationConstants.slow,
    this.curve = AnimationConstants.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final rotationAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            return AnimatedBuilder(
              animation: rotationAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotationAnimation.value * 3.14159),
                  child: child,
                );
              },
              child: child,
            );
          },
        );
}

/// Classe utilitaire pour les transitions de page
class PageTransitions {
  /// Transition par défaut (slide depuis le bas)
  static Route<T> defaultRoute<T>(Widget page) {
    return SlideUpPageRoute<T>(page: page);
  }

  /// Transition pour les modales
  static Route<T> modalRoute<T>(Widget page) {
    return ScaleFadePageRoute<T>(page: page);
  }

  /// Transition pour les pages de détail
  static Route<T> detailRoute<T>(Widget page) {
    return SlideRightPageRoute<T>(page: page);
  }

  /// Transition pour les pages de configuration
  static Route<T> settingsRoute<T>(Widget page) {
    return FadePageRoute<T>(page: page);
  }

  /// Transition pour les pages de succès
  static Route<T> successRoute<T>(Widget page) {
    return ScalePageRoute<T>(page: page);
  }

  /// Transition pour les pages d'erreur
  static Route<T> errorRoute<T>(Widget page) {
    return SlideFadePageRoute<T>(
      page: page,
      slideOffset: const Offset(0.0, -0.3),
    );
  }
}
