import '../entities/analytics_entity.dart';

/// Repository pour les analytics et rapports
abstract class AnalyticsRepository {
  /// Récupère les KPIs principaux
  Future<MainKPIs> getMainKPIs(AnalyticsFilters filters);

  /// Récupère les métriques d'évolution
  Future<List<AnalyticsMetrics>> getEvolutionMetrics(AnalyticsFilters filters);

  /// Récupère les données pour les graphiques
  Future<List<ChartData>> getChartData(String chartType, AnalyticsFilters filters);

  /// Récupère les données de comparaison
  Future<List<ComparisonData>> getComparisonData(AnalyticsFilters filters);

  /// Récupère les prédictions
  Future<List<PredictionData>> getPredictions(AnalyticsFilters filters);

  /// Récupère les métriques par période
  Future<Map<String, List<AnalyticsMetrics>>> getMetricsByPeriod(AnalyticsFilters filters);

  /// Récupère les top performers
  Future<List<ChartData>> getTopPerformers(String metric, AnalyticsFilters filters);

  /// Récupère les tendances
  Future<List<ChartData>> getTrends(String metric, AnalyticsFilters filters);

  /// Exporte les données analytics
  Future<String> exportAnalytics(AnalyticsFilters filters, String format);

  /// Récupère les métriques en temps réel
  Future<MainKPIs> getRealTimeMetrics();

  /// Récupère l'historique des métriques
  Future<List<AnalyticsMetrics>> getMetricsHistory(String metric, AnalyticsFilters filters);
}

