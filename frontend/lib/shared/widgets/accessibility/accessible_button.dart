import 'package:flutter/material.dart';
// import 'package:flutter/semantics.dart'; // Unnecessary - already in material.dart
import '../../../core/accessibility/accessibility_constants.dart';
import '../../../core/accessibility/accessibility_utils.dart';

/// Bouton accessible respectant WCAG 2.1 AA
class AccessibleButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final String? semanticLabel;
  final String? tooltip;
  final bool showFocusRing;
  final Duration? animationDuration;

  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.semanticLabel,
    this.tooltip,
    this.showFocusRing = true,
    this.animationDuration,
  });

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late FocusNode _focusNode;

  bool _isPressed = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Vérifier que la durée d'animation respecte WCAG
    final duration =
        widget.animationDuration ??
        AccessibilityConstants.recommendedTransitionDuration;
    if (!AccessibilityUtils.isAnimationDurationCompliant(duration)) {
      debugPrint('Warning: Animation duration exceeds WCAG recommendations');
    }

    _scaleController = AnimationController(duration: duration, vsync: this);

    _rippleController = AnimationController(duration: duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
      _rippleController.forward(from: 0.0);
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // Vérifier le contraste des couleurs
    final bgColor = _getBackgroundColor(theme);
    final textColor = _getTextColor(theme);

    if (!AccessibilityUtils.isContrastCompliant(textColor, bgColor)) {
      debugPrint('Warning: Button color contrast may not meet WCAG standards');
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      hint: widget.tooltip,
      button: true,
      enabled: isEnabled,
      focusable: true,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isEnabled ? widget.onPressed : null,
        child: Focus(
          focusNode: _focusNode,
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _rippleController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AccessibilityUtils.ensureMinTouchTarget(
                  Container(
                    width: widget.isFullWidth ? double.infinity : null,
                    height: _getButtonHeight(),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(_getBorderRadius()),
                      boxShadow: _isPressed
                          ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))]
                          : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isPressed)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                _getBorderRadius(),
                              ),
                              child: CustomPaint(
                                painter: _RipplePainter(
                                  _rippleAnimation.value,
                                  textColor.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        if (widget.showFocusRing && _isFocused)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AccessibilityConstants.focusRingColor,
                                  width: AccessibilityConstants.focusRingWidth,
                                ),
                                borderRadius: BorderRadius.circular(
                                  _getBorderRadius(),
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: widget.isLoading
                              ? SizedBox(
                                  width: _getIconSize(),
                                  height: _getIconSize(),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      textColor,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.icon != null) ...[
                                      Icon(
                                        widget.icon,
                                        color: textColor,
                                        size: _getIconSize(),
                                        semanticLabel:
                                            AccessibilityUtils.getSemanticLabel(
                                              'icon',
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      widget.text,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AccessibilityConstants.minTouchTargetSize;
      case ButtonSize.medium:
        return AccessibilityConstants.minTouchTargetSize;
      case ButtonSize.large:
        return AccessibilityConstants.minTouchTargetSize + 8;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8.0;
      case ButtonSize.medium:
        return 12.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    switch (widget.type) {
      case ButtonType.primary:
        return isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.38);
      case ButtonType.secondary:
        return isEnabled
            ? theme.colorScheme.secondary
            : theme.colorScheme.onSurface.withOpacity(0.38);
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.textColor != null) return widget.textColor!;

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    switch (widget.type) {
      case ButtonType.primary:
        return isEnabled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant;
      case ButtonType.secondary:
        return isEnabled
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurfaceVariant;
      case ButtonType.outline:
        return isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
      case ButtonType.text:
        return isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
    }
  }
}

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class _RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _RipplePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = size.width * 0.5 * animationValue;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
