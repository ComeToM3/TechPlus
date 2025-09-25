import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_metrics.dart' as entities;
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/dashboard_api.dart';

/// Widget pour afficher les tables les plus populaires
class TopTablesWidget extends ConsumerWidget {
  final entities.DashboardMetrics metrics;
  final VoidCallback? onViewAll;

  const TopTablesWidget({
    super.key,
    required this.metrics,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return FutureBuilder<List<TopTableData>>(
      future: _loadTopTablesData(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final topTables = snapshot.data ?? [];

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
                          Icons.star,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.topTables,
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
                const SizedBox(height: 16),
                
                // Liste des tables populaires
                ...topTables.asMap().entries.map((entry) {
                  final index = entry.key;
                  final table = entry.value;
                  return _buildTableItem(
                    context,
                    index + 1,
                    table,
                    theme,
                  );
                }).toList(),
                
                const SizedBox(height: 16),
                
                // Statistiques des tables
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_chart,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.topTablesSummary,
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
      },
    );
  }

  Widget _buildTableItem(
    BuildContext context,
    int rank,
    TopTableData table,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(rank, theme),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Icône de table
          Icon(
            Icons.table_restaurant,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          
          // Informations de la table
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${table.capacity} ${AppLocalizations.of(context)!.seats}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Statistiques
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${table.reservations}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.reservations,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank, ThemeData theme) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return theme.colorScheme.primary;
    }
  }

  Future<List<TopTableData>> _loadTopTablesData(WidgetRef ref) async {
    try {
      // Appeler l'API réelle pour obtenir les tables populaires
      final dashboardApi = ref.read(dashboardApiProvider);
      return await dashboardApi.getTopTables();
    } catch (e) {
      // En cas d'erreur, retourner une liste vide
      return [];
    }
  }
}

