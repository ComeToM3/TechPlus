import 'package:flutter/material.dart';
import '../buttons/animated_button.dart';

/// Dialogue personnalisé avec actions
class CustomDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;
  final Color? iconColor;
  final bool isLoading;
  final bool showCloseButton;

  const CustomDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.icon,
    this.iconColor,
    this.isLoading = false,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            _buildHeader(theme),
            
            const SizedBox(height: 20),
            
            // Contenu
            if (content != null) ...[
              content!,
              const SizedBox(height: 20),
            ],
            
            // Actions
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
        ],
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        if (showCloseButton)
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    if (primaryButtonText == null && secondaryButtonText == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (secondaryButtonText != null) ...[
          Expanded(
            child: AnimatedButton(
              onPressed: isLoading ? null : onSecondaryPressed,
              text: secondaryButtonText!,
              type: ButtonType.secondary,
              size: ButtonSize.medium,
            ),
          ),
          if (primaryButtonText != null) const SizedBox(width: 12),
        ],
        
        if (primaryButtonText != null)
          Expanded(
            child: AnimatedButton(
              onPressed: isLoading ? null : onPrimaryPressed,
              text: primaryButtonText!,
              type: ButtonType.primary,
              size: ButtonSize.medium,
              isLoading: isLoading,
            ),
          ),
      ],
    );
  }
}

/// Dialogue de confirmation
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: onConfirm ?? () => Navigator.of(context).pop(true),
      onSecondaryPressed: onCancel ?? () => Navigator.of(context).pop(false),
      icon: icon ?? (isDestructive ? Icons.warning : Icons.help_outline),
      iconColor: iconColor ?? (isDestructive ? Colors.red : null),
    );
  }
}

/// Dialogue d'information
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      primaryButtonText: buttonText,
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
      icon: icon ?? Icons.info_outline,
      iconColor: iconColor,
    );
  }
}

/// Dialogue d'erreur
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final String? errorCode;

  const ErrorDialog({
    super.key,
    this.title = 'Erreur',
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: Column(
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (errorCode != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Code d\'erreur: $errorCode',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
      primaryButtonText: buttonText,
      onPrimaryPressed: onPressed ?? () => Navigator.of(context).pop(),
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }
}

/// Dialogue de chargement
class LoadingDialog extends StatelessWidget {
  final String title;
  final String? message;
  final bool canCancel;

  const LoadingDialog({
    super.key,
    this.title = 'Chargement...',
    this.message,
    this.canCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de chargement
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            
            const SizedBox(height: 20),
            
            // Titre
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Bouton d'annulation
            if (canCancel) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialogue de sélection
class SelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<SelectionItem<T>> items;
  final T? selectedValue;
  final Function(T) onSelected;
  final String? searchHint;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.items,
    this.selectedValue,
    required this.onSelected,
    this.searchHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Liste des éléments
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.value == selectedValue;
                  
                  return ListTile(
                    leading: item.icon != null ? Icon(item.icon) : null,
                    title: Text(item.title),
                    subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                    trailing: isSelected 
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      onSelected(item.value);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  SelectionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
