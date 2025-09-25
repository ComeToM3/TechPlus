import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour les statistiques d'utilisation des tables
class TableStatisticsWidget extends ConsumerStatefulWidget {
  final List<TableEntity> tables;
  final VoidCallback? onRefresh;

  const TableStatisticsWidget({
    super.key,
    required this.tables,
    this.onRefresh,
  });

  @override
  ConsumerState<TableStatisticsWidget> createState() => _TableStatisticsWidgetState();
}

class _TableStatisticsWidgetState extends ConsumerState<TableStatisticsWidget> {
  String _selectedPeriod = 'week';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        children: [
          // En-tête avec contrôles
          _buildHeader(theme, l10n),
          const SizedBox(height: 16),

          // Statistiques générales
          _buildGeneralStats(theme, l10n),
          const SizedBox(height: 16),

          // Statistiques par table
          _buildTableStats(theme, l10n),
          const SizedBox(height: 16),

          // Graphiques d'utilisation
          _buildUsageCharts(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.tableStatistics,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sélecteur de période
          DropdownButton<String>(
            value: _selectedPeriod,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPeriod = newValue;
                });
              }
            },
            items: [
              DropdownMenuItem(
                value: 'day',
                child: Text(l10n.today),
              ),
              DropdownMenuItem(
                value: 'week',
                child: Text(l10n.thisWeek),
              ),
              DropdownMenuItem(
                value: 'month',
                child: Text(l10n.thisMonth),
              ),
            ],
          ),
          const SizedBox(width: 8),
          SimpleButton(
            onPressed: widget.onRefresh,
            text: l10n.refresh,
            type: ButtonType.secondary,
            size: ButtonSize.small,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralStats(ThemeData theme, AppLocalizations l10n) {
    final totalTables = widget.tables.length;
    final activeTables = widget.tables.where((t) => t.isActive).length;
    final occupiedTables = widget.tables.where((t) => t.status == TableStatus.occupied).length;
    final availableTables = widget.tables.where((t) => t.status == TableStatus.available).length;
    final totalCapacity = widget.tables.fold(0, (sum, table) => sum + table.capacity);

    return BentoCard(
      title: l10n.generalStatistics,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  l10n.totalTables,
                  totalTables.toString(),
                  Icons.table_restaurant,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  l10n.activeTables,
                  activeTables.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  l10n.occupiedTables,
                  occupiedTables.toString(),
                  Icons.people,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  l10n.availableTables,
                  availableTables.toString(),
                  Icons.event_available,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            theme,
            l10n.totalCapacity,
            totalCapacity.toString(),
            Icons.people_outline,
            theme.colorScheme.secondary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildTableStats(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: l10n.tablePerformance,
      child: Column(
        children: [
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.table,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.capacity,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.status,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.occupancy,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Lignes du tableau
          ...widget.tables.map((table) {
            final occupancy = _calculateOccupancy(table);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.table} ${table.number}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${table.capacity}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(table.status, theme),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(table.status, l10n),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${(occupancy * 100).toInt()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getOccupancyColor(occupancy, theme),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUsageCharts(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: l10n.usageCharts,
      child: Column(
        children: [
          // Graphique en barres simple (placeholder)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chartsComingSoon,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chartsDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOccupancy(TableEntity table) {
    // Simulation du taux d'occupation
    // Dans une vraie implémentation, ceci viendrait des données de réservations
    switch (table.status) {
      case TableStatus.occupied:
        return 1.0;
      case TableStatus.reserved:
        return 0.8;
      case TableStatus.available:
        return 0.0;
      case TableStatus.maintenance:
        return 0.0;
      case TableStatus.outOfOrder:
        return 0.0;
    }
  }

  Color _getStatusColor(TableStatus status, ThemeData theme) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.grey;
      case TableStatus.outOfOrder:
        return Colors.red.shade700;
    }
  }

  String _getStatusLabel(TableStatus status, AppLocalizations l10n) {
    switch (status) {
      case TableStatus.available:
        return l10n.available;
      case TableStatus.occupied:
        return l10n.occupied;
      case TableStatus.reserved:
        return l10n.reserved;
      case TableStatus.maintenance:
        return l10n.maintenance;
      case TableStatus.outOfOrder:
        return l10n.outOfOrder;
    }
  }

  Color _getOccupancyColor(double occupancy, ThemeData theme) {
    if (occupancy >= 0.8) return Colors.red;
    if (occupancy >= 0.5) return Colors.orange;
    if (occupancy > 0) return Colors.green;
    return theme.colorScheme.onSurfaceVariant;
  }
}
