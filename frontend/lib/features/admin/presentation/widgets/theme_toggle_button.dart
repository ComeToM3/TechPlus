import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';

/// Bouton de basculement de thème pour l'interface admin
class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.padding,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (showLabel) {
      return InkWell(
        onTap: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: iconColor ?? theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isDark ? 'Mode clair' : 'Mode sombre',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: iconColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: iconColor ?? theme.colorScheme.onSurface,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: isDark ? 'Passer au thème clair' : 'Passer au thème sombre',
    );
  }
}

/// Widget compact pour les AppBar
class CompactThemeToggle extends ConsumerWidget {
  const CompactThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: theme.colorScheme.onSurface,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: isDark ? 'Passer au thème clair' : 'Passer au thème sombre',
    );
  }
}
