import 'package:flutter/material.dart';

/// Layout responsive qui s'adapte à la taille de l'écran
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double? maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          // Desktop
          return _buildDesktopLayout(context, constraints);
        } else if (constraints.maxWidth >= 768) {
          // Tablet
          return _buildTabletLayout(context, constraints);
        } else {
          // Mobile
          return mobile;
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    final content = desktop ?? tablet ?? mobile;
    
    if (maxWidth != null && constraints.maxWidth > maxWidth!) {
      return Center(
        child: Container(
          width: maxWidth,
          child: content,
        ),
      );
    }
    
    return content;
  }

  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    final content = tablet ?? mobile;
    
    if (maxWidth != null && constraints.maxWidth > maxWidth!) {
      return Center(
        child: Container(
          width: maxWidth,
          child: content,
        ),
      );
    }
    
    return content;
  }
}

/// Container avec contraintes de largeur maximale
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Layout en grille responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        
        if (constraints.maxWidth >= 1200) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= 768) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: (constraints.maxWidth - (spacing * (columns - 1))) / columns,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Layout en colonnes responsive
class ResponsiveColumns extends StatelessWidget {
  final Widget leftColumn;
  final Widget rightColumn;
  final double? leftColumnWidth;
  final double? rightColumnWidth;
  final double spacing;
  final bool reverseOnMobile;

  const ResponsiveColumns({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
    this.leftColumnWidth,
    this.rightColumnWidth,
    this.spacing = 24,
    this.reverseOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          // Mobile: colonnes empilées
          return Column(
            children: reverseOnMobile 
                ? [rightColumn, SizedBox(height: spacing), leftColumn]
                : [leftColumn, SizedBox(height: spacing), rightColumn],
          );
        } else {
          // Desktop/Tablet: colonnes côte à côte
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: leftColumnWidth?.toInt() ?? 1,
                child: leftColumn,
              ),
              SizedBox(width: spacing),
              Expanded(
                flex: rightColumnWidth?.toInt() ?? 1,
                child: rightColumn,
              ),
            ],
          );
        }
      },
    );
  }
}

/// Layout de section avec titre et contenu
class SectionLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Widget? action;

  const SectionLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 24),
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: backgroundColor == null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contenu
          content,
        ],
      ),
    );
  }
}

/// Layout de carte avec en-tête et contenu
class CardLayout extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget content;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CardLayout({
    super.key,
    this.title,
    this.subtitle,
    required this.content,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête personnalisé ou par défaut
                if (header != null) ...[
                  header!,
                  const SizedBox(height: 16),
                ] else if (title != null) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                
                // Contenu
                content,
                
                // Pied de page
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout de liste avec séparateurs
class ListLayout extends StatelessWidget {
  final List<Widget> children;
  final Widget? separator;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const ListLayout({
    super.key,
    required this.children,
    this.separator,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin,
      padding: padding,
      decoration: backgroundColor != null ? BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ) : null,
      child: Column(
        children: children.expand((child) {
          final index = children.indexOf(child);
          if (index == 0) return [child];
          
          return [
            separator ?? Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            child,
          ];
        }).toList(),
      ),
    );
  }
}
