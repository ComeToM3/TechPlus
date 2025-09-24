import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Widget d'animation générique pour différents types d'animations
class CustomAnimatedWidget extends StatefulWidget {
  final Widget child;
  final AnimationConfig config;
  final bool animate;
  final VoidCallback? onAnimationComplete;
  final Duration? delay;

  const CustomAnimatedWidget({
    super.key,
    required this.child,
    required this.config,
    this.animate = true,
    this.onAnimationComplete,
    this.delay,
  });

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    if (widget.animate) {
      _startAnimation();
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // Configuration de l'animation selon le type
    switch (widget.config.type) {
      case AnimationType.fadeIn:
      case AnimationType.fadeOut:
      case AnimationType.scaleIn:
      case AnimationType.scaleOut:
      case AnimationType.bounceIn:
      case AnimationType.elasticIn:
        _animation = Tween<double>(
          begin: widget.config.begin ?? 0.0,
          end: widget.config.end ?? 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.config.curve,
        ));
        break;
      case AnimationType.slideInFromTop:
      case AnimationType.slideInFromBottom:
      case AnimationType.slideInFromLeft:
      case AnimationType.slideInFromRight:
        _offsetAnimation = Tween<Offset>(
          begin: widget.config.offset ?? Offset.zero,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.config.curve,
        ));
        _animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.config.curve,
        ));
        break;
      case AnimationType.rotation:
        _animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.config.curve,
        ));
        break;
      case AnimationType.shimmer:
        _animation = Tween<double>(
          begin: -1.0,
          end: 2.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.config.curve,
        ));
        break;
    }
  }

  void _startAnimation() async {
    if (widget.delay != null) {
      await Future.delayed(widget.delay!);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = widget.child;

        // Application des transformations selon le type d'animation
        switch (widget.config.type) {
          case AnimationType.fadeIn:
          case AnimationType.fadeOut:
            animatedChild = Opacity(
              opacity: _animation.value,
              child: animatedChild,
            );
            break;
          case AnimationType.scaleIn:
          case AnimationType.scaleOut:
          case AnimationType.bounceIn:
          case AnimationType.elasticIn:
            animatedChild = Transform.scale(
              scale: _animation.value,
              child: animatedChild,
            );
            break;
          case AnimationType.slideInFromTop:
          case AnimationType.slideInFromBottom:
          case AnimationType.slideInFromLeft:
          case AnimationType.slideInFromRight:
            animatedChild = SlideTransition(
              position: _offsetAnimation!,
              child: FadeTransition(
                opacity: _animation,
                child: animatedChild,
              ),
            );
            break;
          case AnimationType.rotation:
            animatedChild = Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: animatedChild,
            );
            break;
          case AnimationType.shimmer:
            animatedChild = _ShimmerWidget(
              animation: _animation,
              child: animatedChild,
            );
            break;
        }

        return animatedChild;
      },
    );
  }
}

/// Widget pour l'effet shimmer
class _ShimmerWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ShimmerWidget({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                animation.value - 0.3,
                animation.value,
                animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
