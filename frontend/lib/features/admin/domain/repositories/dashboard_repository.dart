import '../entities/dashboard_metrics.dart';

/// Repository pour les métriques du dashboard admin
abstract class DashboardRepository {
  /// Récupérer les métriques du dashboard
  Future<DashboardMetrics> getDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Récupérer les métriques en temps réel
  Stream<DashboardMetrics> getRealtimeMetrics();

  /// Récupérer les tendances des réservations
  Future<List<ReservationTrend>> getReservationTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period, // 'day', 'week', 'month'
  });

  /// Récupérer les tendances des revenus
  Future<List<RevenueTrend>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  });

  /// Récupérer l'occupation des tables en temps réel
  Future<List<TableOccupancy>> getTableOccupancy();

  /// Récupérer les créneaux horaires populaires
  Future<List<PopularTimeSlot>> getPopularTimeSlots({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Récupérer les segments de clients
  Future<List<CustomerSegment>> getCustomerSegments({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Rafraîchir les métriques
  Future<void> refreshMetrics();
}
