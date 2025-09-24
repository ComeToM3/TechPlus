import '../../../../core/network/api_client.dart';
import '../../domain/entities/analytics_entity.dart';

/// Data source distant pour les analytics
class AnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  const AnalyticsRemoteDataSource(this._apiClient);

  /// Récupère les KPIs principaux
  Future<MainKPIs> getMainKPIs(AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/kpis',
        queryParameters: filters.toJson(),
      );
      return MainKPIs.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des KPIs: $e');
    }
  }

  /// Récupère les métriques d'évolution
  Future<List<AnalyticsMetrics>> getEvolutionMetrics(AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/evolution',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métriques d\'évolution: $e');
    }
  }

  /// Récupère les données pour les graphiques
  Future<List<ChartData>> getChartData(String chartType, AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/charts/$chartType',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((c) => ChartData.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données de graphique: $e');
    }
  }

  /// Récupère les données de comparaison
  Future<List<ComparisonData>> getComparisonData(AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/comparisons',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((c) => ComparisonData.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données de comparaison: $e');
    }
  }

  /// Récupère les prédictions
  Future<List<PredictionData>> getPredictions(AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/predictions',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((p) => PredictionData.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des prédictions: $e');
    }
  }

  /// Récupère les métriques par période
  Future<Map<String, List<AnalyticsMetrics>>> getMetricsByPeriod(AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/metrics-by-period',
        queryParameters: filters.toJson(),
      );
      
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final Map<String, List<AnalyticsMetrics>> result = {};
      
      data.forEach((key, value) {
        result[key] = (value as List)
            .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
            .toList();
      });
      
      return result;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métriques par période: $e');
    }
  }

  /// Récupère les top performers
  Future<List<ChartData>> getTopPerformers(String metric, AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/top-performers/$metric',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((p) => ChartData.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des top performers: $e');
    }
  }

  /// Récupère les tendances
  Future<List<ChartData>> getTrends(String metric, AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/trends/$metric',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((t) => ChartData.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tendances: $e');
    }
  }

  /// Exporte les données analytics
  Future<String> exportAnalytics(AnalyticsFilters filters, String format) async {
    try {
      final response = await _apiClient.post(
        '/api/analytics/export',
        data: {
          ...filters.toJson(),
          'format': format,
        },
      );
      return response.data['downloadUrl'] as String;
    } catch (e) {
      throw Exception('Erreur lors de l\'export des analytics: $e');
    }
  }

  /// Récupère les métriques en temps réel
  Future<MainKPIs> getRealTimeMetrics() async {
    try {
      final response = await _apiClient.get('/api/analytics/real-time');
      return MainKPIs.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métriques temps réel: $e');
    }
  }

  /// Récupère l'historique des métriques
  Future<List<AnalyticsMetrics>> getMetricsHistory(String metric, AnalyticsFilters filters) async {
    try {
      final response = await _apiClient.get(
        '/api/analytics/history/$metric',
        queryParameters: filters.toJson(),
      );
      return (response.data as List)
          .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique des métriques: $e');
    }
  }
}

