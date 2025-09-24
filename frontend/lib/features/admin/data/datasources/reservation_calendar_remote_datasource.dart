import '../../../../core/network/api_client.dart';
import '../../domain/entities/reservation_calendar.dart';

/// Data source distant pour les réservations du calendrier
class ReservationCalendarRemoteDataSource {
  final ApiClient _apiClient;

  const ReservationCalendarRemoteDataSource(this._apiClient);

  /// Récupère les réservations pour une période donnée
  Future<List<ReservationCalendar>> getReservationsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    CalendarFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (filters != null) {
        if (filters.statusFilter.isNotEmpty) {
          queryParams['status'] = filters.statusFilter.map((s) => s.value).join(',');
        }
        if (filters.tableFilter.isNotEmpty) {
          queryParams['tables'] = filters.tableFilter.join(',');
        }
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          queryParams['search'] = filters.searchQuery;
        }
      }

      final response = await _apiClient.get(
        '/api/admin/reservations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ReservationCalendar.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reservations: $e');
    }
  }

  /// Récupère les réservations pour une date spécifique
  Future<List<ReservationCalendar>> getReservationsForDate(DateTime date) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/reservations',
        queryParameters: {
          'date': date.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ReservationCalendar.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations for date: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reservations for date: $e');
    }
  }

  /// Récupère une réservation par son ID
  Future<ReservationCalendar?> getReservationById(String id) async {
    try {
      final response = await _apiClient.get('/api/admin/reservations/$id');

      if (response.statusCode == 200) {
        return ReservationCalendar.fromJson(response.data['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reservation: $e');
    }
  }

  /// Crée une nouvelle réservation
  Future<ReservationCalendar> createReservation(ReservationCalendar reservation) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reservations',
        data: reservation.toJson(),
      );

      if (response.statusCode == 201) {
        return ReservationCalendar.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating reservation: $e');
    }
  }

  /// Met à jour une réservation existante
  Future<ReservationCalendar> updateReservation(ReservationCalendar reservation) async {
    try {
      final response = await _apiClient.put(
        '/api/admin/reservations/${reservation.id}',
        data: reservation.toJson(),
      );

      if (response.statusCode == 200) {
        return ReservationCalendar.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }

  /// Supprime une réservation
  Future<void> deleteReservation(String id) async {
    try {
      final response = await _apiClient.delete('/api/admin/reservations/$id');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting reservation: $e');
    }
  }

  /// Met à jour le statut d'une réservation
  Future<ReservationCalendar> updateReservationStatus({
    required String id,
    required ReservationStatus status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/admin/reservations/$id/status',
        data: {
          'status': status.value,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return ReservationCalendar.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update reservation status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating reservation status: $e');
    }
  }

  /// Met à jour la table assignée à une réservation
  Future<ReservationCalendar> updateReservationTable({
    required String id,
    required String tableNumber,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/admin/reservations/$id/table',
        data: {
          'tableNumber': tableNumber,
        },
      );

      if (response.statusCode == 200) {
        return ReservationCalendar.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update reservation table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating reservation table: $e');
    }
  }

  /// Récupère les disponibilités pour une date et heure
  Future<List<String>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
    String? excludeReservationId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'date': date.toIso8601String(),
        'time': time,
        'partySize': partySize.toString(),
      };

      if (excludeReservationId != null) {
        queryParams['excludeReservationId'] = excludeReservationId;
      }

      final response = await _apiClient.get(
        '/api/admin/availability/tables',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<String>();
      } else {
        throw Exception('Failed to load available tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching available tables: $e');
    }
  }

  /// Récupère les statistiques pour une période
  Future<Map<String, dynamic>> getStatisticsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/reservations/statistics',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? {};
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }
}
