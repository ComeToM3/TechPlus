import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../datasources/dashboard_local_datasource.dart';

/// Implémentation du repository pour les métriques du dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final DashboardLocalDataSource _localDataSource;

  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
    required DashboardLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<DashboardMetrics> getDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Essayer d'abord de récupérer depuis le cache si les données sont récentes
      if (_localDataSource.isDataUpToDate()) {
        final cachedMetrics = await _localDataSource.getDashboardMetrics();
        if (cachedMetrics != null) {
          return cachedMetrics;
        }
      }

      // Récupérer depuis l'API
      final metrics = await _remoteDataSource.getDashboardMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      // Sauvegarder en cache
      await _localDataSource.saveDashboardMetrics(metrics);

      return metrics;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedMetrics = await _localDataSource.getDashboardMetrics();
      if (cachedMetrics != null) {
        return cachedMetrics;
      }
      rethrow;
    }
  }

  @override
  Stream<DashboardMetrics> getRealtimeMetrics() async* {
    // Utiliser WebSocket ou Server-Sent Events pour les métriques temps réel
    // Pour l'instant, on utilise un polling avec l'API réelle
    while (true) {
      try {
        final metrics = await getDashboardMetrics();
        yield metrics;
        await Future.delayed(const Duration(seconds: 30)); // Mise à jour toutes les 30 secondes
      } catch (e) {
        // En cas d'erreur, attendre un peu avant de réessayer
        await Future.delayed(const Duration(seconds: 60));
      }
    }
  }

  @override
  Future<List<ReservationTrend>> getReservationTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final trends = await _remoteDataSource.getReservationTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      // Sauvegarder en cache
      await _localDataSource.saveReservationTrends(trends);

      return trends;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedTrends = await _localDataSource.getReservationTrends();
      if (cachedTrends != null) {
        return cachedTrends;
      }
      rethrow;
    }
  }

  @override
  Future<List<RevenueTrend>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final trends = await _remoteDataSource.getRevenueTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      // Sauvegarder en cache
      await _localDataSource.saveRevenueTrends(trends);

      return trends;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedTrends = await _localDataSource.getRevenueTrends();
      if (cachedTrends != null) {
        return cachedTrends;
      }
      rethrow;
    }
  }

  @override
  Future<List<TableOccupancy>> getTableOccupancy() async {
    try {
      final occupancy = await _remoteDataSource.getTableOccupancy();

      // Sauvegarder en cache
      await _localDataSource.saveTableOccupancy(occupancy);

      return occupancy;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedOccupancy = await _localDataSource.getTableOccupancy();
      if (cachedOccupancy != null) {
        return cachedOccupancy;
      }
      rethrow;
    }
  }

  @override
  Future<List<PopularTimeSlot>> getPopularTimeSlots({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final timeSlots = await _remoteDataSource.getPopularTimeSlots(
        startDate: startDate,
        endDate: endDate,
      );

      // Sauvegarder en cache
      await _localDataSource.savePopularTimeSlots(timeSlots);

      return timeSlots;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedTimeSlots = await _localDataSource.getPopularTimeSlots();
      if (cachedTimeSlots != null) {
        return cachedTimeSlots;
      }
      rethrow;
    }
  }

  @override
  Future<List<CustomerSegment>> getCustomerSegments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final segments = await _remoteDataSource.getCustomerSegments(
        startDate: startDate,
        endDate: endDate,
      );

      // Sauvegarder en cache
      await _localDataSource.saveCustomerSegments(segments);

      return segments;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner les données en cache
      final cachedSegments = await _localDataSource.getCustomerSegments();
      if (cachedSegments != null) {
        return cachedSegments;
      }
      rethrow;
    }
  }

  @override
  Future<void> refreshMetrics() async {
    try {
      // Nettoyer le cache
      await _localDataSource.clearCache();
      
      // Récupérer les nouvelles données
      await getDashboardMetrics();
    } catch (e) {
      throw Exception('Failed to refresh metrics: $e');
    }
  }
}
