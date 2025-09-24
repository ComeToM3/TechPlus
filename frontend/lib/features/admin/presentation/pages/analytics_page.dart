import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../domain/entities/analytics_entity.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics/kpis_widget.dart';
import '../widgets/analytics/evolution_chart_widget.dart';
import '../widgets/analytics/comparison_widget.dart';
import '../widgets/analytics/predictions_widget.dart';

/// Page principale des analytics
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  late AnalyticsFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = AnalyticsFilters(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      timeRange: TimeRange.last30Days,
      metric: 'revenue',
      groupBy: 'day',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          // Bouton de refresh
          IconButton(
            onPressed: _refreshAnalytics,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
          // Bouton d'export
          IconButton(
            onPressed: _exportAnalytics,
            icon: const Icon(Icons.download),
            tooltip: l10n.export,
          ),
          // Bouton de filtres
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec filtres
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            
            // KPIs principaux
            KPIsWidget(filters: _filters),
            const SizedBox(height: 24),
            
            // Graphiques d'évolution
            EvolutionChartWidget(filters: _filters),
            const SizedBox(height: 24),
            
            // Données de comparaison
            ComparisonWidget(filters: _filters),
            const SizedBox(height: 24),
            
            // Prédictions
            PredictionsWidget(filters: _filters),
            const SizedBox(height: 24),
            
            // Actions rapides
            _buildQuickActions(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analyticsOverview,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.analyticsOverviewDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // Filtres actuels
            Row(
              children: [
                _buildFilterChip(l10n, 'Période', _getPeriodText()),
                const SizedBox(width: 8),
                _buildFilterChip(l10n, 'Métrique', _filters.metric ?? ''),
                const SizedBox(width: 8),
                _buildFilterChip(l10n, 'Grouper par', _filters.groupBy ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(AppLocalizations l10n, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getPeriodText() {
    switch (_filters.timeRange) {
      case TimeRange.today:
        return 'Aujourd\'hui';
      case TimeRange.yesterday:
        return 'Hier';
      case TimeRange.last7Days:
        return '7 derniers jours';
      case TimeRange.last30Days:
        return '30 derniers jours';
      case TimeRange.last90Days:
        return '90 derniers jours';
      case TimeRange.lastYear:
        return 'Dernière année';
      case TimeRange.custom:
        return 'Personnalisé';
      case null:
        return 'Non défini';
    }
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exportAnalytics,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.exportData),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _refreshAnalytics,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.refreshData),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearCache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.clearCache),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.configureFilters),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _refreshAnalytics() {
    ref.invalidate(mainKPIsProvider);
    ref.invalidate(evolutionMetricsProvider);
    ref.invalidate(comparisonDataProvider);
    ref.invalidate(predictionsProvider);
  }

  void _exportAnalytics() {
    // TODO: Implémenter l'export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.exportInProgress),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFiltersSheet(context),
    );
  }

  Widget _buildFiltersSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.configureFilters,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Implémenter les filtres
          Text(
            'Filtres à implémenter',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SimpleButton(
                  onPressed: () => Navigator.pop(context),
                  text: l10n.cancel,
                  type: ButtonType.secondary,
                  size: ButtonSize.medium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SimpleButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Appliquer les filtres
                  },
                  text: l10n.apply,
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ref.read(clearAnalyticsCacheProvider)();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.cacheCleared),
        backgroundColor: Colors.green,
      ),
    );
  }
}
