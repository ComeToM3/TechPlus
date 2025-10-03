import '../../../../core/network/schedule_api_service.dart';

/// Repository pour la gestion des horaires
class ScheduleRepository {
  final ScheduleApiService _apiService;

  ScheduleRepository(this._apiService);

  /// Récupère la configuration des horaires
  Future<Map<String, dynamic>> getScheduleConfig({
    required String token,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/schedule',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la récupération de la configuration: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la configuration: $e');
    }
  }

  /// Sauvegarde la configuration des horaires
  Future<Map<String, dynamic>> saveScheduleConfig({
    required String token,
    required Map<String, dynamic> scheduleData,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/admin/schedule',
        scheduleData,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la sauvegarde: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la configuration: $e');
    }
  }

  /// Met à jour la configuration des horaires
  Future<Map<String, dynamic>> updateScheduleConfig({
    required String token,
    required Map<String, dynamic> scheduleData,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/admin/schedule',
        scheduleData,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la configuration: $e');
    }
  }

  /// Supprime la configuration des horaires
  Future<void> deleteScheduleConfig({
    required String token,
  }) async {
    try {
      final response = await _apiService.delete(
        '/api/admin/schedule',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception('Erreur lors de la suppression: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la configuration: $e');
    }
  }
}
