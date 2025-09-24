import 'package:flutter/material.dart';

/// Widget de carte Bento pour un design moderne et modulaire
class BentoCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const BentoCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.shadow,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = child;
    
    // Ajouter le titre et sous-titre si fournis
    if (title != null || subtitle != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      );
    }
    
    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: showBorder
            ? Border.all(
                color: borderColor ?? theme.colorScheme.outline.withOpacity(0.2),
                width: borderWidth ?? 1.0,
              )
            : null,
        boxShadow: shadow != null
            ? [shadow!]
            : elevation != null
                ? [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: elevation!,
                      offset: Offset(0, elevation! / 2),
                    ),
                  ]
                : null,
      ),
      child: content,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}
