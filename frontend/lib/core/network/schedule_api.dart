import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../../features/admin/domain/entities/schedule_entity.dart';

/// API pour la gestion des créneaux horaires
class ScheduleApi {
  final Dio _dio;
  final String _baseUrl;

  ScheduleApi(this._dio, this._baseUrl);

  /// Obtenir la configuration des créneaux
  Future<ScheduleConfig?> getScheduleConfig(String restaurantId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/restaurants/$restaurantId/schedule');

      if (response.statusCode == 200) {
        return ScheduleConfig.fromJson(response.data['schedule']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch schedule config');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching schedule config: $e');
    }
  }

  /// Créer ou mettre à jour la configuration des créneaux
  Future<ScheduleConfig> saveScheduleConfig(String restaurantId, ScheduleConfig config) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule',
        data: config.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ScheduleConfig.fromJson(response.data['schedule']);
      } else {
        throw Exception('Failed to save schedule config');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error saving schedule config: $e');
    }
  }

  /// Mettre à jour les créneaux d'un jour spécifique
  Future<DaySchedule> updateDaySchedule(String restaurantId, String dayOfWeek, DaySchedule daySchedule) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/$dayOfWeek',
        data: daySchedule.toJson(),
      );

      if (response.statusCode == 200) {
        return DaySchedule.fromJson(response.data['daySchedule']);
      } else {
        throw Exception('Failed to update day schedule');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating day schedule: $e');
    }
  }

  /// Ajouter un créneau horaire à un jour
  Future<TimeSlot> addTimeSlot(String restaurantId, String dayOfWeek, TimeSlot timeSlot) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/$dayOfWeek/slots',
        data: timeSlot.toJson(),
      );

      if (response.statusCode == 201) {
        return TimeSlot.fromJson(response.data['timeSlot']);
      } else {
        throw Exception('Failed to add time slot');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error adding time slot: $e');
    }
  }

  /// Mettre à jour un créneau horaire
  Future<TimeSlot> updateTimeSlot(String restaurantId, String dayOfWeek, String time, TimeSlot timeSlot) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/$dayOfWeek/slots/$time',
        data: timeSlot.toJson(),
      );

      if (response.statusCode == 200) {
        return TimeSlot.fromJson(response.data['timeSlot']);
      } else {
        throw Exception('Failed to update time slot');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating time slot: $e');
    }
  }

  /// Supprimer un créneau horaire
  Future<void> deleteTimeSlot(String restaurantId, String dayOfWeek, String time) async {
    try {
      final response = await _dio.delete('$_baseUrl/api/admin/restaurants/$restaurantId/schedule/$dayOfWeek/slots/$time');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete time slot');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting time slot: $e');
    }
  }

  /// Mettre à jour les paramètres des créneaux
  Future<TimeSlotSettings> updateTimeSlotSettings(String restaurantId, TimeSlotSettings settings) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/settings',
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        return TimeSlotSettings.fromJson(response.data['settings']);
      } else {
        throw Exception('Failed to update time slot settings');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating time slot settings: $e');
    }
  }

  /// Obtenir les créneaux disponibles pour une date
  Future<List<TimeSlot>> getAvailableSlots(String restaurantId, DateTime date, int partySize) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/admin/restaurants/$restaurantId/availability',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> slotsData = response.data['slots'];
        return slotsData.map((slot) => TimeSlot.fromJson(slot)).toList();
      } else {
        throw Exception('Failed to fetch available slots');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching available slots: $e');
    }
  }

  /// Valider la configuration des créneaux
  Future<Map<String, dynamic>> validateScheduleConfig(String restaurantId, ScheduleConfig config) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/validate',
        data: config.toJson(),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to validate schedule config');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error validating schedule config: $e');
    }
  }

  /// Obtenir les statistiques des créneaux
  Future<Map<String, dynamic>> getScheduleStats(String restaurantId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/admin/restaurants/$restaurantId/schedule/stats',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch schedule stats');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching schedule stats: $e');
    }
  }
}
