import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reservation_calendar.dart';

/// Data source local pour le cache des réservations du calendrier
class ReservationCalendarLocalDataSource {
  final SharedPreferences _prefs;

  const ReservationCalendarLocalDataSource(this._prefs);

  static const String _reservationsKey = 'cached_reservations';
  static const String _lastUpdateKey = 'reservations_last_update';
  static const String _statisticsKey = 'cached_statistics';

  /// Sauvegarde les réservations en cache
  Future<void> cacheReservations(List<ReservationCalendar> reservations) async {
    try {
      final reservationsJson = reservations.map((r) => r.toJson()).toList();
      await _prefs.setString(_reservationsKey, jsonEncode(reservationsJson));
      await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Error caching reservations: $e');
    }
  }

  /// Récupère les réservations du cache
  Future<List<ReservationCalendar>?> getCachedReservations() async {
    try {
      final reservationsJson = _prefs.getString(_reservationsKey);
      if (reservationsJson == null) return null;

      final List<dynamic> data = jsonDecode(reservationsJson);
      return data.map((json) => ReservationCalendar.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si le cache est valide (moins de 5 minutes)
  bool isCacheValid() {
    try {
      final lastUpdateStr = _prefs.getString(_lastUpdateKey);
      if (lastUpdateStr == null) return false;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      return now.difference(lastUpdate).inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  /// Sauvegarde les statistiques en cache
  Future<void> cacheStatistics(Map<String, dynamic> statistics) async {
    try {
      await _prefs.setString(_statisticsKey, jsonEncode(statistics));
    } catch (e) {
      throw Exception('Error caching statistics: $e');
    }
  }

  /// Récupère les statistiques du cache
  Future<Map<String, dynamic>?> getCachedStatistics() async {
    try {
      final statisticsJson = _prefs.getString(_statisticsKey);
      if (statisticsJson == null) return null;

      return jsonDecode(statisticsJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Supprime le cache
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_reservationsKey);
      await _prefs.remove(_lastUpdateKey);
      await _prefs.remove(_statisticsKey);
    } catch (e) {
      throw Exception('Error clearing cache: $e');
    }
  }

  /// Sauvegarde une réservation spécifique en cache
  Future<void> cacheReservation(ReservationCalendar reservation) async {
    try {
      final cachedReservations = await getCachedReservations() ?? [];
      
      // Trouve l'index de la réservation existante ou ajoute une nouvelle
      final existingIndex = cachedReservations.indexWhere((r) => r.id == reservation.id);
      
      if (existingIndex >= 0) {
        cachedReservations[existingIndex] = reservation;
      } else {
        cachedReservations.add(reservation);
      }

      await cacheReservations(cachedReservations);
    } catch (e) {
      throw Exception('Error caching reservation: $e');
    }
  }

  /// Supprime une réservation du cache
  Future<void> removeReservationFromCache(String reservationId) async {
    try {
      final cachedReservations = await getCachedReservations() ?? [];
      cachedReservations.removeWhere((r) => r.id == reservationId);
      await cacheReservations(cachedReservations);
    } catch (e) {
      throw Exception('Error removing reservation from cache: $e');
    }
  }

  /// Récupère les réservations pour une date spécifique du cache
  Future<List<ReservationCalendar>> getCachedReservationsForDate(DateTime date) async {
    try {
      final cachedReservations = await getCachedReservations() ?? [];
      return cachedReservations.where((reservation) {
        return reservation.date.year == date.year &&
               reservation.date.month == date.month &&
               reservation.date.day == date.day;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupère les réservations pour une période du cache
  Future<List<ReservationCalendar>> getCachedReservationsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final cachedReservations = await getCachedReservations() ?? [];
      return cachedReservations.where((reservation) {
        return reservation.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               reservation.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
