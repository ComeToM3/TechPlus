import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';

/// Carte de métrique pour le dashboard
class MetricsCard extends ConsumerWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isPositiveTrend;

  const MetricsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.scaleIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 24,
                  ),
                  if (showTrend && trendValue != null)
                    _buildTrendIndicator(theme),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(ThemeData theme) {
    final isPositive = isPositiveTrend;
    final color = isPositive 
        ? Colors.green 
        : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${trendValue!.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de métrique spécialisée pour les réservations
class ReservationMetricsCard extends ConsumerWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const ReservationMetricsCard({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return MetricsCard(
      title: label,
      value: count.toString(),
      icon: icon,
      iconColor: color ?? theme.colorScheme.primary,
      onTap: onTap,
    );
  }
}

/// Carte de métrique spécialisée pour les revenus
class RevenueMetricsCard extends ConsumerWidget {
  final double amount;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isPositiveTrend;

  const RevenueMetricsCard({
    super.key,
    required this.amount,
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return MetricsCard(
      title: label,
      value: '€${amount.toStringAsFixed(2)}',
      icon: icon,
      iconColor: color ?? theme.colorScheme.primary,
      onTap: onTap,
      showTrend: showTrend,
      trendValue: trendValue,
      isPositiveTrend: isPositiveTrend,
    );
  }
}

/// Carte de métrique spécialisée pour l'occupation
class OccupancyMetricsCard extends ConsumerWidget {
  final int occupied;
  final int total;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const OccupancyMetricsCard({
    super.key,
    required this.occupied,
    required this.total,
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (occupied / total * 100) : 0.0;
    
    return MetricsCard(
      title: label,
      value: '$occupied/$total',
      subtitle: '${percentage.toStringAsFixed(1)}% occupé',
      icon: icon,
      iconColor: color ?? theme.colorScheme.primary,
      onTap: onTap,
    );
  }
}
