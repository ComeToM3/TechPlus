import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/datasources/analytics_local_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_entity.dart';

/// Provider pour le repository analytics
final analyticsRepositoryProvider = Provider<AnalyticsRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  
  return sharedPreferences.when(
    data: (prefs) => AnalyticsRepositoryImpl(
      AnalyticsRemoteDataSource(apiClient),
      AnalyticsLocalDataSource(prefs),
    ),
    loading: () => throw Exception('SharedPreferences not available'),
    error: (error, stack) => throw Exception('SharedPreferences error: $error'),
  );
});

/// Provider pour les KPIs principaux
final mainKPIsProvider = FutureProvider.family<MainKPIs, AnalyticsFilters>((ref, filters) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMainKPIs(filters);
});

/// Provider pour les métriques d'évolution
final evolutionMetricsProvider = FutureProvider.family<List<AnalyticsMetrics>, AnalyticsFilters>((ref, filters) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getEvolutionMetrics(filters);
});

/// Provider pour les données de graphique
final chartDataProvider = FutureProvider.family<List<ChartData>, ({String chartType, AnalyticsFilters filters})>((ref, params) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getChartData(params.chartType, params.filters);
});

/// Provider pour les données de comparaison
final comparisonDataProvider = FutureProvider.family<List<ComparisonData>, AnalyticsFilters>((ref, filters) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getComparisonData(filters);
});

/// Provider pour les prédictions
final predictionsProvider = FutureProvider.family<List<PredictionData>, AnalyticsFilters>((ref, filters) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getPredictions(filters);
});

/// Provider pour les métriques par période
final metricsByPeriodProvider = FutureProvider.family<Map<String, List<AnalyticsMetrics>>, AnalyticsFilters>((ref, filters) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMetricsByPeriod(filters);
});

/// Provider pour les top performers
final topPerformersProvider = FutureProvider.family<List<ChartData>, ({String metric, AnalyticsFilters filters})>((ref, params) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTopPerformers(params.metric, params.filters);
});

/// Provider pour les tendances
final trendsProvider = FutureProvider.family<List<ChartData>, ({String metric, AnalyticsFilters filters})>((ref, params) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTrends(params.metric, params.filters);
});

/// Provider pour les métriques temps réel
final realTimeMetricsProvider = FutureProvider<MainKPIs>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getRealTimeMetrics();
});

/// Provider pour l'historique des métriques
final metricsHistoryProvider = FutureProvider.family<List<AnalyticsMetrics>, ({String metric, AnalyticsFilters filters})>((ref, params) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMetricsHistory(params.metric, params.filters);
});

/// Provider pour l'export des analytics
final exportAnalyticsProvider = FutureProvider.family<String, ({AnalyticsFilters filters, String format})>((ref, params) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.exportAnalytics(params.filters, params.format);
});

/// Provider pour le cache analytics
final analyticsCacheProvider = Provider<AnalyticsRepositoryImpl>((ref) {
  return ref.watch(analyticsRepositoryProvider);
});

/// Provider pour les filtres analytics
final analyticsFiltersProvider = StateProvider<AnalyticsFilters>((ref) {
  return AnalyticsFilters(
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now(),
    timeRange: TimeRange.last30Days,
    metric: 'revenue',
    groupBy: 'day',
  );
});

/// Provider pour le type de graphique sélectionné
final selectedChartTypeProvider = StateProvider<String>((ref) {
  return 'revenue';
});

/// Provider pour la métrique sélectionnée
final selectedMetricProvider = StateProvider<String>((ref) {
  return 'revenue';
});

/// Provider pour le format d'export
final exportFormatProvider = StateProvider<String>((ref) {
  return 'csv';
});

/// Provider pour l'état de chargement des analytics
final analyticsLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider pour l'erreur des analytics
final analyticsErrorProvider = StateProvider<String?>((ref) {
  return null;
});

/// Provider pour le refresh des analytics
final refreshAnalyticsProvider = Provider<void Function()>((ref) {
  return () {
    // Invalider tous les providers analytics
    ref.invalidate(mainKPIsProvider);
    ref.invalidate(evolutionMetricsProvider);
    ref.invalidate(chartDataProvider);
    ref.invalidate(comparisonDataProvider);
    ref.invalidate(predictionsProvider);
    ref.invalidate(metricsByPeriodProvider);
    ref.invalidate(topPerformersProvider);
    ref.invalidate(trendsProvider);
    ref.invalidate(realTimeMetricsProvider);
    ref.invalidate(metricsHistoryProvider);
  };
});

/// Provider pour le clear du cache analytics
final clearAnalyticsCacheProvider = Provider<void Function()>((ref) {
  return () async {
    final repository = ref.read(analyticsRepositoryProvider);
    await repository.clearCache();
    
    // Invalider tous les providers analytics
    ref.invalidate(mainKPIsProvider);
    ref.invalidate(evolutionMetricsProvider);
    ref.invalidate(chartDataProvider);
    ref.invalidate(comparisonDataProvider);
    ref.invalidate(predictionsProvider);
    ref.invalidate(metricsByPeriodProvider);
    ref.invalidate(topPerformersProvider);
    ref.invalidate(trendsProvider);
    ref.invalidate(realTimeMetricsProvider);
    ref.invalidate(metricsHistoryProvider);
  };
});

/// Provider pour le clear du cache par type
final clearAnalyticsCacheByTypeProvider = Provider<void Function(String)>((ref) {
  return (String type) async {
    final repository = ref.read(analyticsRepositoryProvider);
    await repository.clearCacheByType(type);
    
    // Invalider les providers correspondants
    switch (type) {
      case 'kpis':
        ref.invalidate(mainKPIsProvider);
        ref.invalidate(realTimeMetricsProvider);
        break;
      case 'evolution':
        ref.invalidate(evolutionMetricsProvider);
        break;
      case 'charts':
        ref.invalidate(chartDataProvider);
        break;
      case 'comparison':
        ref.invalidate(comparisonDataProvider);
        break;
      case 'predictions':
        ref.invalidate(predictionsProvider);
        break;
      case 'metrics':
        ref.invalidate(metricsByPeriodProvider);
        ref.invalidate(metricsHistoryProvider);
        break;
      case 'performers':
        ref.invalidate(topPerformersProvider);
        break;
      case 'trends':
        ref.invalidate(trendsProvider);
        break;
    }
  };
});
