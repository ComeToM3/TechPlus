import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bouton de navigation vers la page publique pour l'interface admin
class PublicNavigationButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const PublicNavigationButton({
    super.key,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      icon: Icon(
        Icons.restaurant,
        color: iconColor ?? theme.colorScheme.primary,
        size: iconSize ?? 28,
      ),
      onPressed: () => context.go('/'),
      tooltip: tooltip ?? 'Aller à la page publique',
    );
  }
}

/// Version compacte pour les AppBar
class CompactPublicNavigationButton extends StatelessWidget {
  const CompactPublicNavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicNavigationButton(
      iconSize: 24,
    );
  }
}
