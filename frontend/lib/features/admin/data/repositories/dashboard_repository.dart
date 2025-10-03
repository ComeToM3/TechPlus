import '../../../../core/network/dashboard_api_service.dart';
import '../models/dashboard_metrics_model.dart';

/// Repository pour les données du dashboard administratif
class DashboardRepository {
  final DashboardApiService _apiService;

  DashboardRepository(this._apiService);

  /// Récupère les métriques du dashboard
  Future<DashboardMetricsModel> getDashboardMetrics({
    required String token,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/dashboard/metrics',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return DashboardMetricsModel.fromJson(response['data']);
      } else {
        throw Exception('Erreur lors de la récupération des métriques: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métriques: $e');
    }
  }

  /// Récupère les analytics détaillées
  Future<DashboardMetricsModel> getDashboardAnalytics({
    required String token,
    String period = '30d',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/dashboard/analytics?period=$period',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return DashboardMetricsModel.fromJson(response['data']);
      } else {
        throw Exception('Erreur lors de la récupération des analytics: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des analytics: $e');
    }
  }

  /// Récupère les réservations
  Future<List<Map<String, dynamic>>> getReservations({
    required String token,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String endpoint = '/api/admin/reservations';
      final Map<String, dynamic> queryParams = {};
      
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await _apiService.get(endpoint, token: token);

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Erreur lors de la récupération des réservations: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  /// Met à jour le statut d'une réservation
  Future<Map<String, dynamic>> updateReservationStatus({
    required String token,
    required String reservationId,
    required String status,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/admin/reservations/$reservationId/status',
        {'status': status},
        token: token,
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Récupère les tables
  Future<List<Map<String, dynamic>>> getTables({
    required String token,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/tables',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Erreur lors de la récupération des tables: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables: $e');
    }
  }

  /// Met à jour le statut d'une table
  Future<Map<String, dynamic>> updateTableStatus({
    required String token,
    required String tableId,
    required String status,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/admin/tables/$tableId/status',
        {'status': status},
        token: token,
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la mise à jour: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de la table: $e');
    }
  }

  /// Récupère les rapports
  Future<List<Map<String, dynamic>>> getReports({
    required String token,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String endpoint = '/api/admin/reports';
      final Map<String, dynamic> queryParams = {};
      
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await _apiService.get(endpoint, token: token);

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        throw Exception('Erreur lors de la récupération des rapports: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des rapports: $e');
    }
  }
}