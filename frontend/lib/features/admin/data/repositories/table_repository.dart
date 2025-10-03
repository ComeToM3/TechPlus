import '../../../../core/network/table_api_service.dart';

/// Repository pour la gestion des tables
class TableRepository {
  final TableApiService _apiService;

  TableRepository(this._apiService);

  /// Récupère toutes les tables
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

  /// Récupère une table par son ID
  Future<Map<String, dynamic>> getTableById({
    required String token,
    required String tableId,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/tables/$tableId',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la récupération de la table: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la table: $e');
    }
  }

  /// Crée une nouvelle table
  Future<Map<String, dynamic>> createTable({
    required String token,
    required Map<String, dynamic> tableData,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/admin/tables',
        tableData,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la création de la table: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la table: $e');
    }
  }

  /// Met à jour une table
  Future<Map<String, dynamic>> updateTable({
    required String token,
    required String tableId,
    required Map<String, dynamic> tableData,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/admin/tables/$tableId',
        tableData,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la mise à jour de la table: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la table: $e');
    }
  }

  /// Supprime une table
  Future<void> deleteTable({
    required String token,
    required String tableId,
  }) async {
    try {
      final response = await _apiService.delete(
        '/api/admin/tables/$tableId',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception('Erreur lors de la suppression de la table: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la table: $e');
    }
  }

  /// Met à jour le statut d'une table
  Future<Map<String, dynamic>> updateTableStatus({
    required String token,
    required String tableId,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/admin/tables/$tableId/status',
        {'isActive': isActive},
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la mise à jour du statut: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de la table: $e');
    }
  }

  /// Récupère les statistiques des tables
  Future<Map<String, dynamic>> getTableStatistics({
    required String token,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/admin/tables/statistics',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Erreur lors de la récupération des statistiques: ${response['message'] ?? 'Erreur inconnue'}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
