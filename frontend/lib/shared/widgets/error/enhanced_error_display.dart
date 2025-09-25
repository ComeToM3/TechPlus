import 'package:flutter/material.dart';
import '../../errors/contextual_errors.dart';

/// Widget d'affichage d'erreur amélioré avec messages contextuels
class EnhancedErrorDisplay extends StatelessWidget {
  final ContextualError? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIcon;
  final bool showRetryButton;
  final bool showSuggestedActions;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final bool compact;

  const EnhancedErrorDisplay({
    super.key,
    this.error,
    this.onRetry,
    this.retryText,
    this.showIcon = true,
    this.showRetryButton = true,
    this.showSuggestedActions = true,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final errorColor = _getErrorColor(error!);
    
    if (compact) {
      return _buildCompactError(context, theme, colorScheme, errorColor);
    }
    
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getErrorIcon(error!),
              color: errorColor,
              size: 24,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            error!.getLocalizedMessage(),
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: textColor ?? colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          if (showSuggestedActions && error!.getSuggestedActions().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSuggestedActions(context, theme, errorColor),
          ],
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 12),
            _buildRetryButton(context, theme, errorColor),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactError(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color errorColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: errorColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(error!),
            color: errorColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!.getLocalizedMessage(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: errorColor,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              color: errorColor,
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedActions(BuildContext context, ThemeData theme, Color errorColor) {
    final actions = error!.getSuggestedActions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions suggérées:',
          style: theme.textTheme.titleSmall?.copyWith(
            color: errorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...actions.take(3).map((action) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.arrow_right,
                size: 16,
                color: errorColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: errorColor,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context, ThemeData theme, Color errorColor) {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(retryText ?? 'Réessayer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: errorColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Color _getErrorColor(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Colors.orange;
      case ContextualReservationError:
        return Colors.red;
      case ContextualPaymentError:
        return Colors.purple;
      case ContextualValidationError:
        return Colors.amber;
      case ContextualNetworkError:
        return Colors.blue;
      case ContextualServerError:
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  IconData _getErrorIcon(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Icons.lock_outline;
      case ContextualReservationError:
        return Icons.event_busy;
      case ContextualPaymentError:
        return Icons.payment;
      case ContextualValidationError:
        return Icons.warning_outlined;
      case ContextualNetworkError:
        return Icons.wifi_off;
      case ContextualServerError:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}

/// Widget d'affichage d'erreur dans une liste
class EnhancedErrorListTile extends StatelessWidget {
  final ContextualError error;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showSuggestedActions;

  const EnhancedErrorListTile({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText,
    this.showSuggestedActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final errorColor = _getErrorColor(error);
    
    return ListTile(
      leading: Icon(
        _getErrorIcon(error),
        color: errorColor,
      ),
      title: Text(
        error.getLocalizedMessage(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: errorColor,
        ),
      ),
      subtitle: showSuggestedActions && error.getSuggestedActions().isNotEmpty
          ? Text(
              'Actions: ${error.getSuggestedActions().take(2).join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: errorColor.withOpacity(0.7),
              ),
            )
          : null,
      trailing: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: Text(retryText ?? 'Réessayer'),
            )
          : null,
    );
  }

  Color _getErrorColor(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Colors.orange;
      case ContextualReservationError:
        return Colors.red;
      case ContextualPaymentError:
        return Colors.purple;
      case ContextualValidationError:
        return Colors.amber;
      case ContextualNetworkError:
        return Colors.blue;
      case ContextualServerError:
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  IconData _getErrorIcon(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Icons.lock_outline;
      case ContextualReservationError:
        return Icons.event_busy;
      case ContextualPaymentError:
        return Icons.payment;
      case ContextualValidationError:
        return Icons.warning_outlined;
      case ContextualNetworkError:
        return Icons.wifi_off;
      case ContextualServerError:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}

/// Widget d'affichage d'erreur dans un SnackBar
class EnhancedErrorSnackBar extends StatelessWidget {
  final ContextualError error;
  final VoidCallback? onAction;
  final String? actionText;

  const EnhancedErrorSnackBar({
    super.key,
    required this.error,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = _getErrorColor(error);
    
    return SnackBar(
      content: Row(
        children: [
          Icon(
            _getErrorIcon(error),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.getLocalizedMessage(),
                  style: const TextStyle(color: Colors.white),
                ),
                if (error.getSuggestedActions().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Actions: ${error.getSuggestedActions().take(1).join(', ')}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      backgroundColor: errorColor,
      duration: Duration(seconds: error.isRetryable ? 6 : 4),
      action: onAction != null
          ? SnackBarAction(
              label: actionText ?? 'Détails',
              textColor: Colors.white,
              onPressed: onAction!,
            )
          : null,
    );
  }

  Color _getErrorColor(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Colors.orange;
      case ContextualReservationError:
        return Colors.red;
      case ContextualPaymentError:
        return Colors.purple;
      case ContextualValidationError:
        return Colors.amber;
      case ContextualNetworkError:
        return Colors.blue;
      case ContextualServerError:
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  IconData _getErrorIcon(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Icons.lock_outline;
      case ContextualReservationError:
        return Icons.event_busy;
      case ContextualPaymentError:
        return Icons.payment;
      case ContextualValidationError:
        return Icons.warning_outlined;
      case ContextualNetworkError:
        return Icons.wifi_off;
      case ContextualServerError:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}
