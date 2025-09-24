import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_constants.dart';

/// Widget avec animation de tap (ripple effect)
class AnimatedTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? rippleColor;
  final double scaleOnTap;
  final Duration animationDuration;
  final bool enableHapticFeedback;

  const AnimatedTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.rippleColor,
    this.scaleOnTap = 0.95,
    this.animationDuration = AnimationConstants.fast,
    this.enableHapticFeedback = true,
  });

  @override
  State<AnimatedTapWidget> createState() => _AnimatedTapWidgetState();
}

class _AnimatedTapWidgetState extends State<AnimatedTapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _handleLongPress() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: _handleLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _isPressed
                    ? (widget.rippleColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.1))
                    : Colors.transparent,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Widget avec animation de hover (pour desktop/web)
class HoverAnimationWidget extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final Duration animationDuration;
  final Color? hoverColor;
  final VoidCallback? onHover;
  final VoidCallback? onUnhover;

  const HoverAnimationWidget({
    super.key,
    required this.child,
    this.hoverScale = 1.05,
    this.animationDuration = AnimationConstants.fast,
    this.hoverColor,
    this.onHover,
    this.onUnhover,
  });

  @override
  State<HoverAnimationWidget> createState() => _HoverAnimationWidgetState();
}

class _HoverAnimationWidgetState extends State<HoverAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.easeInOut,
    ));
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.hoverColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    _controller.forward();
    widget.onHover?.call();
  }

  void _handleHoverExit(PointerExitEvent event) {
    _controller.reverse();
    widget.onUnhover?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Widget avec animation de shake (pour les erreurs)
class ShakeAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool shouldShake;
  final Duration duration;
  final double shakeIntensity;

  const ShakeAnimationWidget({
    super.key,
    required this.child,
    required this.shouldShake,
    this.duration = const Duration(milliseconds: 500),
    this.shakeIntensity = 10.0,
  });

  @override
  State<ShakeAnimationWidget> createState() => _ShakeAnimationWidgetState();
}

class _ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(ShakeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _controller.forward().then((_) {
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final shake = widget.shakeIntensity * 
            (0.5 - (0.5 * (1 - _animation.value).clamp(0.0, 1.0)));
        return Transform.translate(
          offset: Offset(shake, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Widget avec animation de pulse (pour les notifications)
class PulseAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isPulsing;
  final Duration duration;
  final double pulseScale;
  final Color? pulseColor;

  const PulseAnimationWidget({
    super.key,
    required this.child,
    required this.isPulsing,
    this.duration = const Duration(milliseconds: 1000),
    this.pulseScale = 1.1,
    this.pulseColor,
  });

  @override
  State<PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState extends State<PulseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pulseScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PulseAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !oldWidget.isPulsing) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && oldWidget.isPulsing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Widget avec animation de bounce (pour les succès)
class BounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool shouldBounce;
  final Duration duration;
  final double bounceHeight;

  const BounceAnimationWidget({
    super.key,
    required this.child,
    required this.shouldBounce,
    this.duration = const Duration(milliseconds: 600),
    this.bounceHeight = 20.0,
  });

  @override
  State<BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<BounceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void didUpdateWidget(BounceAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldBounce && !oldWidget.shouldBounce) {
      _controller.forward().then((_) {
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final bounce = widget.bounceHeight * _animation.value;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: widget.child,
        );
      },
    );
  }
}
