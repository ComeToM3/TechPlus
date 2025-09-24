import '../../domain/entities/reservation_calendar.dart';
import '../../domain/repositories/reservation_calendar_repository.dart';
import '../datasources/reservation_calendar_remote_datasource.dart';
import '../datasources/reservation_calendar_local_datasource.dart';

/// Implémentation du repository pour les réservations du calendrier
class ReservationCalendarRepositoryImpl implements ReservationCalendarRepository {
  final ReservationCalendarRemoteDataSource _remoteDataSource;
  final ReservationCalendarLocalDataSource _localDataSource;

  const ReservationCalendarRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<List<ReservationCalendar>> getReservationsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    CalendarFilters? filters,
  }) async {
    try {
      // Essaie d'abord le cache si valide
      if (_localDataSource.isCacheValid()) {
        final cachedReservations = await _localDataSource.getCachedReservationsForPeriod(
          startDate: startDate,
          endDate: endDate,
        );
        
        if (cachedReservations.isNotEmpty) {
          return _applyFilters(cachedReservations, filters);
        }
      }

      // Sinon, récupère depuis l'API
      final reservations = await _remoteDataSource.getReservationsForPeriod(
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );

      // Met en cache les résultats
      await _localDataSource.cacheReservations(reservations);

      return reservations;
    } catch (e) {
      // En cas d'erreur, essaie le cache même s'il n'est pas valide
      final cachedReservations = await _localDataSource.getCachedReservationsForPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (cachedReservations.isNotEmpty) {
        return _applyFilters(cachedReservations, filters);
      }
      
      rethrow;
    }
  }

  @override
  Future<List<ReservationCalendar>> getReservationsForDate(DateTime date) async {
    try {
      // Essaie d'abord le cache si valide
      if (_localDataSource.isCacheValid()) {
        final cachedReservations = await _localDataSource.getCachedReservationsForDate(date);
        if (cachedReservations.isNotEmpty) {
          return cachedReservations;
        }
      }

      // Sinon, récupère depuis l'API
      final reservations = await _remoteDataSource.getReservationsForDate(date);

      // Met en cache les résultats
      await _localDataSource.cacheReservations(reservations);

      return reservations;
    } catch (e) {
      // En cas d'erreur, essaie le cache même s'il n'est pas valide
      final cachedReservations = await _localDataSource.getCachedReservationsForDate(date);
      if (cachedReservations.isNotEmpty) {
        return cachedReservations;
      }
      
      rethrow;
    }
  }

  @override
  Future<ReservationCalendar?> getReservationById(String id) async {
    try {
      // Essaie d'abord le cache
      final cachedReservations = await _localDataSource.getCachedReservations() ?? [];
      final cachedReservation = cachedReservations.where((r) => r.id == id).firstOrNull;
      
      if (cachedReservation != null && _localDataSource.isCacheValid()) {
        return cachedReservation;
      }

      // Sinon, récupère depuis l'API
      final reservation = await _remoteDataSource.getReservationById(id);
      
      if (reservation != null) {
        // Met en cache la réservation
        await _localDataSource.cacheReservation(reservation);
      }

      return reservation;
    } catch (e) {
      // En cas d'erreur, essaie le cache même s'il n'est pas valide
      final cachedReservations = await _localDataSource.getCachedReservations() ?? [];
      return cachedReservations.where((r) => r.id == id).firstOrNull;
    }
  }

  @override
  Future<ReservationCalendar> createReservation(ReservationCalendar reservation) async {
    try {
      final createdReservation = await _remoteDataSource.createReservation(reservation);
      
      // Met en cache la nouvelle réservation
      await _localDataSource.cacheReservation(createdReservation);
      
      return createdReservation;
    } catch (e) {
      throw Exception('Error creating reservation: $e');
    }
  }

  @override
  Future<ReservationCalendar> updateReservation(ReservationCalendar reservation) async {
    try {
      final updatedReservation = await _remoteDataSource.updateReservation(reservation);
      
      // Met à jour le cache
      await _localDataSource.cacheReservation(updatedReservation);
      
      return updatedReservation;
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }

  @override
  Future<void> deleteReservation(String id) async {
    try {
      await _remoteDataSource.deleteReservation(id);
      
      // Supprime du cache
      await _localDataSource.removeReservationFromCache(id);
    } catch (e) {
      throw Exception('Error deleting reservation: $e');
    }
  }

  @override
  Future<ReservationCalendar> updateReservationStatus({
    required String id,
    required ReservationStatus status,
    String? notes,
  }) async {
    try {
      final updatedReservation = await _remoteDataSource.updateReservationStatus(
        id: id,
        status: status,
        notes: notes,
      );
      
      // Met à jour le cache
      await _localDataSource.cacheReservation(updatedReservation);
      
      return updatedReservation;
    } catch (e) {
      throw Exception('Error updating reservation status: $e');
    }
  }

  @override
  Future<ReservationCalendar> updateReservationTable({
    required String id,
    required String tableNumber,
  }) async {
    try {
      final updatedReservation = await _remoteDataSource.updateReservationTable(
        id: id,
        tableNumber: tableNumber,
      );
      
      // Met à jour le cache
      await _localDataSource.cacheReservation(updatedReservation);
      
      return updatedReservation;
    } catch (e) {
      throw Exception('Error updating reservation table: $e');
    }
  }

  @override
  Future<List<String>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
    String? excludeReservationId,
  }) async {
    try {
      return await _remoteDataSource.getAvailableTables(
        date: date,
        time: time,
        partySize: partySize,
        excludeReservationId: excludeReservationId,
      );
    } catch (e) {
      throw Exception('Error fetching available tables: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatisticsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Essaie d'abord le cache
      final cachedStatistics = await _localDataSource.getCachedStatistics();
      if (cachedStatistics != null && _localDataSource.isCacheValid()) {
        return cachedStatistics;
      }

      // Sinon, récupère depuis l'API
      final statistics = await _remoteDataSource.getStatisticsForPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      // Met en cache les statistiques
      await _localDataSource.cacheStatistics(statistics);

      return statistics;
    } catch (e) {
      // En cas d'erreur, essaie le cache même s'il n'est pas valide
      final cachedStatistics = await _localDataSource.getCachedStatistics();
      if (cachedStatistics != null) {
        return cachedStatistics;
      }
      
      rethrow;
    }
  }

  /// Applique les filtres aux réservations
  List<ReservationCalendar> _applyFilters(
    List<ReservationCalendar> reservations,
    CalendarFilters? filters,
  ) {
    if (filters == null) return reservations;

    var filteredReservations = reservations;

    // Filtre par statut
    if (filters.statusFilter.isNotEmpty) {
      filteredReservations = filteredReservations.where((reservation) {
        return filters.statusFilter.any((status) => 
          reservation.status == status.value);
      }).toList();
    }

    // Filtre par table
    if (filters.tableFilter.isNotEmpty) {
      filteredReservations = filteredReservations.where((reservation) {
        return reservation.tableNumber != null && 
               filters.tableFilter.contains(reservation.tableNumber);
      }).toList();
    }

    // Filtre par recherche
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final query = filters.searchQuery!.toLowerCase();
      filteredReservations = filteredReservations.where((reservation) {
        return reservation.clientName.toLowerCase().contains(query) ||
               reservation.clientEmail.toLowerCase().contains(query) ||
               (reservation.clientPhone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filteredReservations;
  }
}
