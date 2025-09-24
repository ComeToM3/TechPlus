import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Widget pour animer une liste d'éléments avec un délai échelonné
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final AnimationType animationType;
  final bool reverse;
  final VoidCallback? onAnimationComplete;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.staggerDelay = AnimationConstants.staggerDelay,
    this.itemDuration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
    this.animationType = AnimationType.fadeIn,
    this.reverse = false,
    this.onAnimationComplete,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _completedAnimations = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(widget.children.length, (index) {
      final controller = AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      );
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _completedAnimations++;
          if (_completedAnimations == widget.children.length) {
            widget.onAnimationComplete?.call();
          }
        }
      });
      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      final delay = widget.reverse
          ? Duration(milliseconds: (widget.children.length - 1 - i) * widget.staggerDelay.inMilliseconds)
          : Duration(milliseconds: i * widget.staggerDelay.inMilliseconds);
      
      Future.delayed(delay, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedChild(
              widget.children[index],
              _animations[index],
              index,
            );
          },
        );
      }),
    );
  }

  Widget _buildAnimatedChild(Widget child, Animation<double> animation, int index) {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: animation.value,
          child: child,
        );
      case AnimationType.slideInFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.slideInFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.slideInFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.slideInFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.scaleIn:
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.bounceIn:
        return Transform.scale(
          scale: animation.value,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      default:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
}

/// Widget pour animer une grille d'éléments avec un délai échelonné
class StaggeredGridAnimation extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final AnimationType animationType;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const StaggeredGridAnimation({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.staggerDelay = AnimationConstants.staggerDelay,
    this.itemDuration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
    this.animationType = AnimationType.scaleIn,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
  });

  @override
  State<StaggeredGridAnimation> createState() => _StaggeredGridAnimationState();
}

class _StaggeredGridAnimationState extends State<StaggeredGridAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(widget.children.length, (index) {
      final controller = AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      );
      return controller;
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      final row = i ~/ widget.crossAxisCount;
      final col = i % widget.crossAxisCount;
      final delay = Duration(
        milliseconds: (row + col) * widget.staggerDelay.inMilliseconds,
      );
      
      Future.delayed(delay, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedChild(
              widget.children[index],
              _animations[index],
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedChild(Widget child, Animation<double> animation) {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: animation.value,
          child: child,
        );
      case AnimationType.scaleIn:
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.slideInFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case AnimationType.bounceIn:
        return Transform.scale(
          scale: animation.value,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      default:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
}

/// Widget pour animer l'apparition d'éléments dans une liste
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = AnimationConstants.staggerDelay,
    this.duration = AnimationConstants.normal,
    this.curve = AnimationConstants.easeOut,
    this.animationType = AnimationType.fadeIn,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
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
      curve: widget.curve,
    ));

    // Démarrer l'animation avec un délai basé sur l'index
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
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
        switch (widget.animationType) {
          case AnimationType.fadeIn:
            return Opacity(
              opacity: _animation.value,
              child: widget.child,
            );
          case AnimationType.slideInFromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_animation),
              child: FadeTransition(
                opacity: _animation,
                child: widget.child,
              ),
            );
          case AnimationType.scaleIn:
            return ScaleTransition(
              scale: _animation,
              child: FadeTransition(
                opacity: _animation,
                child: widget.child,
              ),
            );
          default:
            return FadeTransition(
              opacity: _animation,
              child: widget.child,
            );
        }
      },
    );
  }
}
