import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour afficher les revenus
class RevenueWidget extends ConsumerWidget {
  final DashboardMetrics metrics;
  final VoidCallback? onViewAll;

  const RevenueWidget({
    super.key,
    required this.metrics,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final revenueGrowth = _calculateRevenueGrowth(metrics);

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        onTap: onViewAll ?? () => context.go('/admin/analytics/revenue'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.euro,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.revenue,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Revenus du jour
            _buildRevenueSection(
              context,
              l10n.todayRevenue,
              metrics.todayRevenue,
              Icons.today,
              Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Revenus totaux
            _buildRevenueSection(
              context,
              l10n.totalRevenue,
              metrics.totalRevenue,
              Icons.account_balance_wallet,
              theme.colorScheme.primary,
            ),
            
            const SizedBox(height: 16),
            
            // Revenus moyens
            _buildRevenueSection(
              context,
              l10n.averageRevenue,
              metrics.averageRevenue,
              Icons.trending_up,
              Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Indicateur de croissance
            if (revenueGrowth != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (revenueGrowth > 0 ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      revenueGrowth > 0 ? Icons.trending_up : Icons.trending_down,
                      color: revenueGrowth > 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        revenueGrowth > 0 
                            ? l10n.revenueGrowthPositive(revenueGrowth.abs().toStringAsFixed(1))
                            : l10n.revenueGrowthNegative(revenueGrowth.abs().toStringAsFixed(1)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: revenueGrowth > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Résumé des revenus
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.revenueSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '€${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double? _calculateRevenueGrowth(DashboardMetrics metrics) {
    // Simulation de calcul de croissance (dans une vraie app, ce serait calculé depuis les données historiques)
    if (metrics.todayRevenue > 0 && metrics.averageRevenue > 0) {
      return ((metrics.todayRevenue - metrics.averageRevenue) / metrics.averageRevenue) * 100;
    }
    return null;
  }
}
