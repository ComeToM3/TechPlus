import 'package:flutter/material.dart';
import '../../errors/app_errors.dart';

/// Widget pour afficher les erreurs de manière cohérente
class ErrorDisplay extends StatelessWidget {
  final AppError? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIcon;
  final bool showRetryButton;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;

  const ErrorDisplay({
    super.key,
    this.error,
    this.onRetry,
    this.retryText,
    this.showIcon = true,
    this.showRetryButton = true,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: textColor ?? colorScheme.error,
              size: 24,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            error!.message,
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: textColor ?? colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(retryText ?? 'Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour afficher les erreurs dans une liste
class ErrorListTile extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorListTile({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: Icon(
        Icons.error_outline,
        color: colorScheme.error,
      ),
      title: Text(
        error.message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.error,
        ),
      ),
      trailing: onRetry != null
          ? TextButton(
              onPressed: onRetry,
              child: Text(retryText ?? 'Réessayer'),
            )
          : null,
    );
  }
}

/// Widget pour afficher les erreurs dans un SnackBar
class ErrorSnackBar extends StatelessWidget {
  final AppError error;
  final VoidCallback? onAction;
  final String? actionText;

  const ErrorSnackBar({
    super.key,
    required this.error,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(error.message),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
      action: onAction != null
          ? SnackBarAction(
              label: actionText ?? 'Fermer',
              textColor: Colors.white,
              onPressed: onAction!,
            )
          : null,
    );
  }
}

/// Widget pour afficher les erreurs dans une boîte de dialogue
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final String? title;
  final List<Widget>? actions;

  const ErrorDialog({
    super.key,
    required this.error,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Erreur'),
      content: Text(error.message),
      actions: actions ?? [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

/// Widget pour afficher les erreurs dans un card
class ErrorCard extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryText;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ErrorCard({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: margin ?? const EdgeInsets.all(16),
      color: colorScheme.errorContainer,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: Text(retryText ?? 'Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
