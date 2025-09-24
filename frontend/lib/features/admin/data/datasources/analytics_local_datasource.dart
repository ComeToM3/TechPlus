import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/analytics_entity.dart';

/// Data source local pour les analytics
class AnalyticsLocalDataSource {
  final SharedPreferences _prefs;

  const AnalyticsLocalDataSource(this._prefs);

  /// Sauvegarde les KPIs principaux
  Future<void> saveMainKPIs(MainKPIs kpis) async {
    await _prefs.setString('analytics_main_kpis', jsonEncode(kpis.toJson()));
  }

  /// Récupère les KPIs principaux
  Future<MainKPIs?> getMainKPIs() async {
    final String? data = _prefs.getString('analytics_main_kpis');
    if (data == null) return null;
    
    try {
      return MainKPIs.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les métriques d'évolution
  Future<void> saveEvolutionMetrics(List<AnalyticsMetrics> metrics) async {
    final List<Map<String, dynamic>> data = metrics.map((m) => m.toJson()).toList();
    await _prefs.setString('analytics_evolution_metrics', jsonEncode(data));
  }

  /// Récupère les métriques d'évolution
  Future<List<AnalyticsMetrics>?> getEvolutionMetrics() async {
    final String? data = _prefs.getString('analytics_evolution_metrics');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les données de graphique
  Future<void> saveChartData(String chartType, List<ChartData> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((c) => c.toJson()).toList();
    await _prefs.setString('analytics_chart_$chartType', jsonEncode(jsonData));
  }

  /// Récupère les données de graphique
  Future<List<ChartData>?> getChartData(String chartType) async {
    final String? data = _prefs.getString('analytics_chart_$chartType');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((c) => ChartData.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les données de comparaison
  Future<void> saveComparisonData(List<ComparisonData> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((c) => c.toJson()).toList();
    await _prefs.setString('analytics_comparison_data', jsonEncode(jsonData));
  }

  /// Récupère les données de comparaison
  Future<List<ComparisonData>?> getComparisonData() async {
    final String? data = _prefs.getString('analytics_comparison_data');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((c) => ComparisonData.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les prédictions
  Future<void> savePredictions(List<PredictionData> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((p) => p.toJson()).toList();
    await _prefs.setString('analytics_predictions', jsonEncode(jsonData));
  }

  /// Récupère les prédictions
  Future<List<PredictionData>?> getPredictions() async {
    final String? data = _prefs.getString('analytics_predictions');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((p) => PredictionData.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les métriques par période
  Future<void> saveMetricsByPeriod(Map<String, List<AnalyticsMetrics>> data) async {
    final Map<String, dynamic> jsonData = {};
    data.forEach((key, value) {
      jsonData[key] = value.map((m) => m.toJson()).toList();
    });
    await _prefs.setString('analytics_metrics_by_period', jsonEncode(jsonData));
  }

  /// Récupère les métriques par période
  Future<Map<String, List<AnalyticsMetrics>>?> getMetricsByPeriod() async {
    final String? data = _prefs.getString('analytics_metrics_by_period');
    if (data == null) return null;
    
    try {
      final Map<String, dynamic> jsonData = jsonDecode(data) as Map<String, dynamic>;
      final Map<String, List<AnalyticsMetrics>> result = {};
      
      jsonData.forEach((key, value) {
        result[key] = (value as List<dynamic>)
            .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
            .toList();
      });
      
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les top performers
  Future<void> saveTopPerformers(String metric, List<ChartData> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((p) => p.toJson()).toList();
    await _prefs.setString('analytics_top_performers_$metric', jsonEncode(jsonData));
  }

  /// Récupère les top performers
  Future<List<ChartData>?> getTopPerformers(String metric) async {
    final String? data = _prefs.getString('analytics_top_performers_$metric');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((p) => ChartData.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les tendances
  Future<void> saveTrends(String metric, List<ChartData> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((t) => t.toJson()).toList();
    await _prefs.setString('analytics_trends_$metric', jsonEncode(jsonData));
  }

  /// Récupère les tendances
  Future<List<ChartData>?> getTrends(String metric) async {
    final String? data = _prefs.getString('analytics_trends_$metric');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((t) => ChartData.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde l'historique des métriques
  Future<void> saveMetricsHistory(String metric, List<AnalyticsMetrics> data) async {
    final List<Map<String, dynamic>> jsonData = data.map((m) => m.toJson()).toList();
    await _prefs.setString('analytics_history_$metric', jsonEncode(jsonData));
  }

  /// Récupère l'historique des métriques
  Future<List<AnalyticsMetrics>?> getMetricsHistory(String metric) async {
    final String? data = _prefs.getString('analytics_history_$metric');
    if (data == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((m) => AnalyticsMetrics.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les métriques temps réel
  Future<void> saveRealTimeMetrics(MainKPIs kpis) async {
    await _prefs.setString('analytics_real_time', jsonEncode(kpis.toJson()));
  }

  /// Récupère les métriques temps réel
  Future<MainKPIs?> getRealTimeMetrics() async {
    final String? data = _prefs.getString('analytics_real_time');
    if (data == null) return null;
    
    try {
      return MainKPIs.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Nettoie le cache des analytics
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('analytics_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// Nettoie le cache d'un type spécifique
  Future<void> clearCacheByType(String type) async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('analytics_$type'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

