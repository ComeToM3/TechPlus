import '../entities/reservation_calendar.dart';

/// Repository abstrait pour la gestion des réservations du calendrier
abstract class ReservationCalendarRepository {
  /// Récupère les réservations pour une période donnée
  Future<List<ReservationCalendar>> getReservationsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    CalendarFilters? filters,
  });

  /// Récupère les réservations pour une date spécifique
  Future<List<ReservationCalendar>> getReservationsForDate(DateTime date);

  /// Récupère une réservation par son ID
  Future<ReservationCalendar?> getReservationById(String id);

  /// Crée une nouvelle réservation
  Future<ReservationCalendar> createReservation(ReservationCalendar reservation);

  /// Met à jour une réservation existante
  Future<ReservationCalendar> updateReservation(ReservationCalendar reservation);

  /// Supprime une réservation
  Future<void> deleteReservation(String id);

  /// Met à jour le statut d'une réservation
  Future<ReservationCalendar> updateReservationStatus({
    required String id,
    required ReservationStatus status,
    String? notes,
  });

  /// Met à jour la table assignée à une réservation
  Future<ReservationCalendar> updateReservationTable({
    required String id,
    required String tableNumber,
  });

  /// Récupère les disponibilités pour une date et heure
  Future<List<String>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
    String? excludeReservationId,
  });

  /// Récupère les statistiques pour une période
  Future<Map<String, dynamic>> getStatisticsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });
}
