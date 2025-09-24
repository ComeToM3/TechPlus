import 'package:flutter/material.dart';

/// Bouton simple sans animations complexes pour éviter les erreurs de layout
class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const SimpleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
      case ButtonType.ghost:
        button = TextButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
      case ButtonType.success:
        button = ElevatedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null ? Icon(icon, size: _getIconSize()) : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: _getVerticalPadding(),
              horizontal: 16,
            ),
            minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
          ),
        );
        break;
    }

    return button;
  }

  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 8.0;
      case ButtonSize.medium:
        return 12.0;
      case ButtonSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }
}

/// Types de boutons
enum ButtonType { primary, secondary, outline, ghost, danger, success }

/// Tailles de boutons
enum ButtonSize { small, medium, large }
