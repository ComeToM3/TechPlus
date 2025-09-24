import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../datasources/analytics_local_datasource.dart';

/// Implémentation du repository analytics
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;
  final AnalyticsLocalDataSource _localDataSource;

  const AnalyticsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<MainKPIs> getMainKPIs(AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedKPIs = await _localDataSource.getMainKPIs();
      if (cachedKPIs != null) {
        // Retourner les données en cache en arrière-plan
        _refreshMainKPIs(filters);
        return cachedKPIs;
      }
      
      // Récupérer depuis l'API
      final kpis = await _remoteDataSource.getMainKPIs(filters);
      await _localDataSource.saveMainKPIs(kpis);
      return kpis;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedKPIs = await _localDataSource.getMainKPIs();
      if (cachedKPIs != null) {
        return cachedKPIs;
      }
      rethrow;
    }
  }

  @override
  Future<List<AnalyticsMetrics>> getEvolutionMetrics(AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedMetrics = await _localDataSource.getEvolutionMetrics();
      if (cachedMetrics != null) {
        // Retourner les données en cache en arrière-plan
        _refreshEvolutionMetrics(filters);
        return cachedMetrics;
      }
      
      // Récupérer depuis l'API
      final metrics = await _remoteDataSource.getEvolutionMetrics(filters);
      await _localDataSource.saveEvolutionMetrics(metrics);
      return metrics;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedMetrics = await _localDataSource.getEvolutionMetrics();
      if (cachedMetrics != null) {
        return cachedMetrics;
      }
      rethrow;
    }
  }

  @override
  Future<List<ChartData>> getChartData(String chartType, AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getChartData(chartType);
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshChartData(chartType, filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getChartData(chartType, filters);
      await _localDataSource.saveChartData(chartType, data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getChartData(chartType);
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<List<ComparisonData>> getComparisonData(AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getComparisonData();
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshComparisonData(filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getComparisonData(filters);
      await _localDataSource.saveComparisonData(data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getComparisonData();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<List<PredictionData>> getPredictions(AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getPredictions();
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshPredictions(filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getPredictions(filters);
      await _localDataSource.savePredictions(data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getPredictions();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, List<AnalyticsMetrics>>> getMetricsByPeriod(AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getMetricsByPeriod();
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshMetricsByPeriod(filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getMetricsByPeriod(filters);
      await _localDataSource.saveMetricsByPeriod(data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getMetricsByPeriod();
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<List<ChartData>> getTopPerformers(String metric, AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getTopPerformers(metric);
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshTopPerformers(metric, filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getTopPerformers(metric, filters);
      await _localDataSource.saveTopPerformers(metric, data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getTopPerformers(metric);
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<List<ChartData>> getTrends(String metric, AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getTrends(metric);
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshTrends(metric, filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getTrends(metric, filters);
      await _localDataSource.saveTrends(metric, data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getTrends(metric);
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<String> exportAnalytics(AnalyticsFilters filters, String format) async {
    return await _remoteDataSource.exportAnalytics(filters, format);
  }

  @override
  Future<MainKPIs> getRealTimeMetrics() async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedKPIs = await _localDataSource.getRealTimeMetrics();
      if (cachedKPIs != null) {
        // Retourner les données en cache en arrière-plan
        _refreshRealTimeMetrics();
        return cachedKPIs;
      }
      
      // Récupérer depuis l'API
      final kpis = await _remoteDataSource.getRealTimeMetrics();
      await _localDataSource.saveRealTimeMetrics(kpis);
      return kpis;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedKPIs = await _localDataSource.getRealTimeMetrics();
      if (cachedKPIs != null) {
        return cachedKPIs;
      }
      rethrow;
    }
  }

  @override
  Future<List<AnalyticsMetrics>> getMetricsHistory(String metric, AnalyticsFilters filters) async {
    try {
      // Essayer de récupérer depuis le cache local
      final cachedData = await _localDataSource.getMetricsHistory(metric);
      if (cachedData != null) {
        // Retourner les données en cache en arrière-plan
        _refreshMetricsHistory(metric, filters);
        return cachedData;
      }
      
      // Récupérer depuis l'API
      final data = await _remoteDataSource.getMetricsHistory(metric, filters);
      await _localDataSource.saveMetricsHistory(metric, data);
      return data;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer depuis le cache
      final cachedData = await _localDataSource.getMetricsHistory(metric);
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<void> clearCacheByType(String type) async {
    await _localDataSource.clearCacheByType(type);
  }

  // Méthodes privées pour le refresh en arrière-plan
  Future<void> _refreshMainKPIs(AnalyticsFilters filters) async {
    try {
      final kpis = await _remoteDataSource.getMainKPIs(filters);
      await _localDataSource.saveMainKPIs(kpis);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshEvolutionMetrics(AnalyticsFilters filters) async {
    try {
      final metrics = await _remoteDataSource.getEvolutionMetrics(filters);
      await _localDataSource.saveEvolutionMetrics(metrics);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshChartData(String chartType, AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getChartData(chartType, filters);
      await _localDataSource.saveChartData(chartType, data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshComparisonData(AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getComparisonData(filters);
      await _localDataSource.saveComparisonData(data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshPredictions(AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getPredictions(filters);
      await _localDataSource.savePredictions(data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshMetricsByPeriod(AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getMetricsByPeriod(filters);
      await _localDataSource.saveMetricsByPeriod(data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshTopPerformers(String metric, AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getTopPerformers(metric, filters);
      await _localDataSource.saveTopPerformers(metric, data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshTrends(String metric, AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getTrends(metric, filters);
      await _localDataSource.saveTrends(metric, data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshRealTimeMetrics() async {
    try {
      final kpis = await _remoteDataSource.getRealTimeMetrics();
      await _localDataSource.saveRealTimeMetrics(kpis);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }

  Future<void> _refreshMetricsHistory(String metric, AnalyticsFilters filters) async {
    try {
      final data = await _remoteDataSource.getMetricsHistory(metric, filters);
      await _localDataSource.saveMetricsHistory(metric, data);
    } catch (e) {
      // Ignorer les erreurs de refresh en arrière-plan
    }
  }
}

