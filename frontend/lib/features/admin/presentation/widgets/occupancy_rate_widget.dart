import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour afficher le taux d'occupation des tables
class OccupancyRateWidget extends ConsumerWidget {
  final DashboardMetrics metrics;
  final VoidCallback? onViewAll;

  const OccupancyRateWidget({
    super.key,
    required this.metrics,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final occupancyRate = metrics.totalTables > 0 
        ? (metrics.occupiedTables / metrics.totalTables * 100) 
        : 0.0;
    
    final occupancyColor = _getOccupancyColor(occupancyRate, theme);

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        onTap: onViewAll ?? () => context.go('/admin/tables'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.tableOccupancy,
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
            
            // Indicateur circulaire du taux d'occupation
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // Cercle de fond
                    CircularProgressIndicator(
                      value: occupancyRate / 100,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                    ),
                    // Texte au centre
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${occupancyRate.toStringAsFixed(1)}%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: occupancyColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.occupied,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Détails des tables
            Row(
              children: [
                Expanded(
                  child: _buildTableInfo(
                    context,
                    l10n.occupied,
                    metrics.occupiedTables,
                    occupancyColor,
                    Icons.table_restaurant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTableInfo(
                    context,
                    l10n.available,
                    metrics.totalTables - metrics.occupiedTables,
                    Colors.green,
                    Icons.table_bar,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Barre de progression horizontale
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalTables,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${metrics.occupiedTables}/${metrics.totalTables}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: occupancyRate / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Message de statut
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: occupancyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getOccupancyIcon(occupancyRate),
                    color: occupancyColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getOccupancyMessage(occupancyRate, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: occupancyColor,
                        fontWeight: FontWeight.w500,
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

  Widget _buildTableInfo(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
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
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getOccupancyColor(double rate, ThemeData theme) {
    if (rate >= 80) return Colors.red;
    if (rate >= 60) return Colors.orange;
    if (rate >= 40) return Colors.blue;
    return Colors.green;
  }

  IconData _getOccupancyIcon(double rate) {
    if (rate >= 80) return Icons.warning;
    if (rate >= 60) return Icons.info;
    if (rate >= 40) return Icons.check_circle;
    return Icons.check_circle_outline;
  }

  String _getOccupancyMessage(double rate, AppLocalizations l10n) {
    if (rate >= 80) return l10n.highOccupancy;
    if (rate >= 60) return l10n.goodOccupancy;
    if (rate >= 40) return l10n.moderateOccupancy;
    return l10n.lowOccupancy;
  }
}
