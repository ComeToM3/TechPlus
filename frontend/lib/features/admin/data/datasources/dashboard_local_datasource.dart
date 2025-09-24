import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/dashboard_metrics.dart';

/// Data source local pour le cache des métriques du dashboard
class DashboardLocalDataSource {
  static const String _metricsKey = 'dashboard_metrics';
  static const String _reservationTrendsKey = 'reservation_trends';
  static const String _revenueTrendsKey = 'revenue_trends';
  static const String _tableOccupancyKey = 'table_occupancy';
  static const String _popularTimeSlotsKey = 'popular_time_slots';
  static const String _customerSegmentsKey = 'customer_segments';
  static const String _lastUpdateKey = 'dashboard_last_update';

  final SharedPreferences _prefs;

  DashboardLocalDataSource(this._prefs);

  /// Sauvegarder les métriques du dashboard
  Future<void> saveDashboardMetrics(DashboardMetrics metrics) async {
    try {
      await _prefs.setString(_metricsKey, jsonEncode(metrics.toJson()));
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to save dashboard metrics: $e');
    }
  }

  /// Récupérer les métriques du dashboard
  Future<DashboardMetrics?> getDashboardMetrics() async {
    try {
      final metricsJson = _prefs.getString(_metricsKey);
      if (metricsJson == null) return null;
      
      final metricsMap = jsonDecode(metricsJson) as Map<String, dynamic>;
      return DashboardMetrics.fromJson(metricsMap);
    } catch (e) {
      throw Exception('Failed to get dashboard metrics: $e');
    }
  }

  /// Sauvegarder les tendances des réservations
  Future<void> saveReservationTrends(List<ReservationTrend> trends) async {
    try {
      final trendsJson = trends.map((e) => e.toJson()).toList();
      await _prefs.setString(_reservationTrendsKey, jsonEncode(trendsJson));
    } catch (e) {
      throw Exception('Failed to save reservation trends: $e');
    }
  }

  /// Récupérer les tendances des réservations
  Future<List<ReservationTrend>?> getReservationTrends() async {
    try {
      final trendsJson = _prefs.getString(_reservationTrendsKey);
      if (trendsJson == null) return null;
      
      final trendsList = jsonDecode(trendsJson) as List<dynamic>;
      return trendsList.map((e) => ReservationTrend.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get reservation trends: $e');
    }
  }

  /// Sauvegarder les tendances des revenus
  Future<void> saveRevenueTrends(List<RevenueTrend> trends) async {
    try {
      final trendsJson = trends.map((e) => e.toJson()).toList();
      await _prefs.setString(_revenueTrendsKey, jsonEncode(trendsJson));
    } catch (e) {
      throw Exception('Failed to save revenue trends: $e');
    }
  }

  /// Récupérer les tendances des revenus
  Future<List<RevenueTrend>?> getRevenueTrends() async {
    try {
      final trendsJson = _prefs.getString(_revenueTrendsKey);
      if (trendsJson == null) return null;
      
      final trendsList = jsonDecode(trendsJson) as List<dynamic>;
      return trendsList.map((e) => RevenueTrend.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get revenue trends: $e');
    }
  }

  /// Sauvegarder l'occupation des tables
  Future<void> saveTableOccupancy(List<TableOccupancy> occupancy) async {
    try {
      final occupancyJson = occupancy.map((e) => e.toJson()).toList();
      await _prefs.setString(_tableOccupancyKey, jsonEncode(occupancyJson));
    } catch (e) {
      throw Exception('Failed to save table occupancy: $e');
    }
  }

  /// Récupérer l'occupation des tables
  Future<List<TableOccupancy>?> getTableOccupancy() async {
    try {
      final occupancyJson = _prefs.getString(_tableOccupancyKey);
      if (occupancyJson == null) return null;
      
      final occupancyList = jsonDecode(occupancyJson) as List<dynamic>;
      return occupancyList.map((e) => TableOccupancy.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get table occupancy: $e');
    }
  }

  /// Sauvegarder les créneaux horaires populaires
  Future<void> savePopularTimeSlots(List<PopularTimeSlot> timeSlots) async {
    try {
      final timeSlotsJson = timeSlots.map((e) => e.toJson()).toList();
      await _prefs.setString(_popularTimeSlotsKey, jsonEncode(timeSlotsJson));
    } catch (e) {
      throw Exception('Failed to save popular time slots: $e');
    }
  }

  /// Récupérer les créneaux horaires populaires
  Future<List<PopularTimeSlot>?> getPopularTimeSlots() async {
    try {
      final timeSlotsJson = _prefs.getString(_popularTimeSlotsKey);
      if (timeSlotsJson == null) return null;
      
      final timeSlotsList = jsonDecode(timeSlotsJson) as List<dynamic>;
      return timeSlotsList.map((e) => PopularTimeSlot.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get popular time slots: $e');
    }
  }

  /// Sauvegarder les segments de clients
  Future<void> saveCustomerSegments(List<CustomerSegment> segments) async {
    try {
      final segmentsJson = segments.map((e) => e.toJson()).toList();
      await _prefs.setString(_customerSegmentsKey, jsonEncode(segmentsJson));
    } catch (e) {
      throw Exception('Failed to save customer segments: $e');
    }
  }

  /// Récupérer les segments de clients
  Future<List<CustomerSegment>?> getCustomerSegments() async {
    try {
      final segmentsJson = _prefs.getString(_customerSegmentsKey);
      if (segmentsJson == null) return null;
      
      final segmentsList = jsonDecode(segmentsJson) as List<dynamic>;
      return segmentsList.map((e) => CustomerSegment.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customer segments: $e');
    }
  }

  /// Vérifier si les données sont à jour
  bool isDataUpToDate({Duration maxAge = const Duration(minutes: 5)}) {
    try {
      final lastUpdateStr = _prefs.getString(_lastUpdateKey);
      if (lastUpdateStr == null) return false;
      
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      
      return now.difference(lastUpdate) < maxAge;
    } catch (e) {
      return false;
    }
  }

  /// Nettoyer le cache
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_metricsKey);
      await _prefs.remove(_reservationTrendsKey);
      await _prefs.remove(_revenueTrendsKey);
      await _prefs.remove(_tableOccupancyKey);
      await _prefs.remove(_popularTimeSlotsKey);
      await _prefs.remove(_customerSegmentsKey);
      await _prefs.remove(_lastUpdateKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
