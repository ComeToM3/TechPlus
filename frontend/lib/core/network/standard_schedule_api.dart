import '../../features/admin/domain/entities/schedule_entity.dart';
import 'standard_api_client.dart';

/// API standardisée pour la gestion des créneaux horaires
/// Utilise le client API centralisé avec authentification automatique
class StandardScheduleApi {
  final StandardApiClient _client;

  StandardScheduleApi(this._client);

  /// Obtenir la configuration des créneaux
  Future<ScheduleConfig?> getScheduleConfig(String restaurantId) async {
    try {
      final response = await _client.get('/api/admin/schedule');

      if (response.statusCode == 200) {
        return ScheduleConfig.fromJson(response.data['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch schedule config');
      }
    } catch (e) {
      throw Exception('Error fetching schedule config: $e');
    }
  }

  /// Créer ou mettre à jour la configuration des créneaux
  Future<ScheduleConfig> saveScheduleConfig(String restaurantId, ScheduleConfig config) async {
    try {
      final response = await _client.post(
        '/api/admin/schedule',
        data: config.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ScheduleConfig.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to save schedule config');
      }
    } catch (e) {
      throw Exception('Error saving schedule config: $e');
    }
  }

  // NOTE: Les méthodes individuelles pour les créneaux ont été supprimées
  // car elles utilisaient des routes qui n'existent pas dans le backend.
  // Toutes les opérations se font maintenant via saveScheduleConfig()

  /// Obtenir les créneaux disponibles pour une date
  Future<List<TimeSlot>> getAvailableSlots(String restaurantId, DateTime date, int partySize) async {
    try {
      final response = await _client.get(
        '/api/admin/schedule/availability',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> slotsData = response.data['data']['slots'];
        return slotsData.map((slot) => TimeSlot.fromJson(slot)).toList();
      } else {
        throw Exception('Failed to fetch available slots');
      }
    } catch (e) {
      throw Exception('Error fetching available slots: $e');
    }
  }

  // NOTE: validateScheduleConfig supprimée car la route n'existe pas dans le backend

  /// Valider si une réservation est possible
  Future<Map<String, dynamic>> validateReservation(String restaurantId, DateTime date, String time, int partySize) async {
    try {
      final response = await _client.post(
        '/api/admin/schedule/validate',
        data: {
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to validate reservation');
      }
    } catch (e) {
      throw Exception('Error validating reservation: $e');
    }
  }

  // NOTE: getScheduleStats supprimée car la route n'existe pas dans le backend
}
