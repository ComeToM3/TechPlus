import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Layout responsive avancé avec adaptation automatique
class ResponsiveLayoutAdvanced extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final bool showSidebar;
  final Widget? sidebar;
  final bool showBottomNavigation;
  final Widget? bottomNavigation;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool centerContent;
  final double? maxContentWidth;

  const ResponsiveLayoutAdvanced({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.showSidebar = false,
    this.sidebar,
    this.showBottomNavigation = false,
    this.bottomNavigation,
    this.showAppBar = true,
    this.appBar,
    this.backgroundColor,
    this.padding,
    this.centerContent = true,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveUtils.getScreenType(constraints.maxWidth);
        
        return Scaffold(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
          appBar: showAppBar ? _buildAppBar(context, screenType) : null,
          drawer: _shouldShowDrawer(screenType) ? sidebar : null,
          body: _buildBody(context, screenType),
          bottomNavigationBar: _shouldShowBottomNavigation(screenType) 
              ? bottomNavigation 
              : null,
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, ScreenType screenType) {
    if (appBar != null) return appBar;
    
    return AppBar(
      title: Text(
        'TechPlus',
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, 20),
        ),
      ),
      elevation: ResponsiveUtils.isMobile(context) ? 0 : 1,
      centerTitle: ResponsiveUtils.isMobile(context),
    );
  }

  bool _shouldShowDrawer(ScreenType screenType) {
    return showSidebar && 
           (screenType == ScreenType.mobile || screenType == ScreenType.tablet);
  }

  bool _shouldShowBottomNavigation(ScreenType screenType) {
    return showBottomNavigation && screenType == ScreenType.mobile;
  }

  Widget _buildBody(BuildContext context, ScreenType screenType) {
    Widget content = _getContentForScreenType(screenType);
    
    if (centerContent && maxContentWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxContentWidth!,
          ),
          child: content,
        ),
      );
    }

    if (showSidebar && _shouldShowSidebar(screenType)) {
      return Row(
        children: [
          SizedBox(
            width: ResponsiveUtils.getSidebarWidth(context),
            child: sidebar,
          ),
          Expanded(child: content),
        ],
      );
    }

    return Padding(
      padding: padding ?? ResponsiveUtils.getPadding(context),
      child: content,
    );
  }

  bool _shouldShowSidebar(ScreenType screenType) {
    return showSidebar && 
           (screenType == ScreenType.desktop || screenType == ScreenType.largeDesktop);
  }

  Widget _getContentForScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Widget pour adapter le contenu selon la taille d'écran
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveUtils.getScreenType(constraints.maxWidth);
        
        switch (screenType) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? mobile;
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Widget pour créer une grille responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(context);
        final gridSpacing = spacing ?? ResponsiveUtils.getGridSpacing(context);
        final gridRunSpacing = runSpacing ?? gridSpacing;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridRunSpacing,
            childAspectRatio: _getChildAspectRatio(context),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  double _getChildAspectRatio(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return 1.2;
    if (ResponsiveUtils.isTablet(context)) return 1.1;
    return 1.0;
  }
}

/// Widget pour créer une liste responsive
class ResponsiveList extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveList({
    super.key,
    required this.children,
    this.spacing,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final listSpacing = spacing ?? ResponsiveUtils.getSpacing(context);
    
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: listSpacing),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Widget pour créer un conteneur responsive
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final Alignment? alignment;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final containerWidth = width ?? ResponsiveUtils.getMaxContentWidth(context);
    final containerPadding = padding ?? ResponsiveUtils.getPadding(context);
    
    Widget content = Container(
      width: containerWidth,
      height: height,
      padding: containerPadding,
      margin: margin,
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Widget pour créer un formulaire responsive
class ResponsiveForm extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Decoration? decoration;

  const ResponsiveForm({
    super.key,
    required this.child,
    this.width,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final formWidth = width ?? ResponsiveUtils.getFormWidth(context);
    final formPadding = padding ?? ResponsiveUtils.getPadding(context);
    
    return Center(
      child: Container(
        width: formWidth,
        padding: formPadding,
        margin: margin,
        color: backgroundColor,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

/// Widget pour créer une carte responsive
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final VoidCallback? onTap;
  final CardSize size;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.onTap,
    this.size = CardSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? ResponsiveUtils.getCardWidth(context);
    final cardHeight = height ?? ResponsiveUtils.getCardHeight(context, size);
    final cardPadding = padding ?? ResponsiveUtils.getPadding(context);
    final borderRadius = ResponsiveUtils.getBorderRadius(context, 12.0);
    
    Widget card = Container(
      width: cardWidth,
      height: cardHeight,
      padding: cardPadding,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}
