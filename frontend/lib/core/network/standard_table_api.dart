import 'package:dio/dio.dart';
import '../../features/admin/domain/entities/table_entity.dart';
import '../../features/admin/domain/entities/restaurant_layout_entity.dart';
import 'standard_api_client.dart';

/// API standardisée pour la gestion des tables
/// Utilise StandardApiClient pour une architecture unifiée
class StandardTableApi {
  final StandardApiClient _client;

  StandardTableApi(this._client);

  /// Obtenir toutes les tables (version légère pour la liste)
  Future<List<TableEntity>> getAllTables({bool includeReservations = false}) async {
    try {
      print('🔍 [DEBUG] StandardTableApi.getAllTables appelé');
      print('  - URL: /api/admin/tables');
      print('  - includeReservations: $includeReservations');
      
      final response = await _client.get('/api/admin/tables', queryParameters: {
        'includeReservations': includeReservations,
      });
      
      print('✅ [DEBUG] StandardTableApi.getAllTables - Réponse reçue:');
      print('  - Status: ${response.statusCode}');
      print('  - Data type: ${response.data.runtimeType}');
      print('  - Data: ${response.data}');
      
      // Le backend retourne {success: true, data: [...]}
      final responseData = response.data as Map<String, dynamic>;
      final tablesList = responseData['data'] as List;
      print('  - Tables count: ${tablesList.length}');
      
      final tables = tablesList
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
          
      print('✅ [DEBUG] StandardTableApi.getAllTables - Tables parsées: ${tables.length}');
      for (final table in tables) {
        print('  - Table ${table.number}: ${table.capacity} places, active: ${table.isActive}');
      }
      
      return tables;
    } catch (e) {
      print('❌ [DEBUG] StandardTableApi.getAllTables - Erreur: $e');
      throw Exception('Failed to fetch tables: $e');
    }
  }

  /// Obtenir une table par ID
  Future<TableEntity?> getTableById(String id) async {
    try {
      final response = await _client.get('/api/admin/tables/$id');
      
      // Le backend retourne {success: true, data: {...}}
      final responseData = response.data as Map<String, dynamic>;
      final tableData = responseData['data'] as Map<String, dynamic>;
      
      return TableEntity.fromJson(tableData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch table: $e');
    }
  }

  /// Créer une nouvelle table
  Future<TableEntity> createTable(Map<String, dynamic> tableData) async {
    try {
      print('🔍 [DEBUG] StandardTableApi.createTable appelé avec:');
      print('  - URL: /api/admin/tables');
      print('  - Data: $tableData');
      
      final response = await _client.post('/api/admin/tables', data: tableData);
      
      print('✅ [DEBUG] StandardTableApi.createTable - Réponse reçue:');
      print('  - Status: ${response.statusCode}');
      print('  - Data: ${response.data}');
      
      // Le backend retourne {success: true, data: {...}}
      final responseData = response.data as Map<String, dynamic>;
      final createdTableData = responseData['data'] as Map<String, dynamic>;
      
      return TableEntity.fromJson(createdTableData);
    } catch (e) {
      print('❌ [DEBUG] Erreur dans StandardTableApi.createTable: $e');
      throw Exception('Failed to create table: $e');
    }
  }

  /// Mettre à jour une table
  Future<TableEntity> updateTable(String id, Map<String, dynamic> tableData) async {
    try {
      final response = await _client.put('/api/admin/tables/$id', data: tableData);
      
      // Le backend retourne {success: true, data: {...}}
      final responseData = response.data as Map<String, dynamic>;
      final updatedTableData = responseData['data'] as Map<String, dynamic>;
      
      return TableEntity.fromJson(updatedTableData);
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  /// Supprimer une table
  Future<void> deleteTable(String id) async {
    try {
      await _client.delete('/api/admin/tables/$id');
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  /// Obtenir les tables disponibles
  Future<List<TableEntity>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      final response = await _client.get('/api/admin/tables/available', queryParameters: {
        'date': date.toIso8601String().split('T')[0],
        'time': time,
        'partySize': partySize,
      });
      return (response.data as List)
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available tables: $e');
    }
  }

  /// Obtenir les statistiques des tables
  Future<Map<String, dynamic>> getTableStats(String tableId) async {
    try {
      final response = await _client.get('/api/admin/tables/$tableId/stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch table stats: $e');
    }
  }

  /// Obtenir les statistiques générales des tables
  Future<Map<String, dynamic>> getTableStatistics() async {
    try {
      final response = await _client.get('/api/admin/tables/statistics');
      
      // Le backend retourne {success: true, data: {...}}
      final responseData = response.data as Map<String, dynamic>;
      return responseData['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch table statistics: $e');
    }
  }

  /// Mettre à jour le statut d'une table
  Future<void> updateTableStatus(String id, String status) async {
    try {
      await _client.patch('/api/admin/tables/$id/status', data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  /// Obtenir la disponibilité d'une table
  Future<Map<String, dynamic>> getTableAvailability(String id, DateTime date) async {
    try {
      final response = await _client.get('/api/admin/tables/$id/availability', queryParameters: {
        'date': date.toIso8601String().split('T')[0],
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch table availability: $e');
    }
  }

  /// Obtenir la configuration du restaurant
  Future<RestaurantLayout> getRestaurantLayout() async {
    try {
      final response = await _client.get('/api/admin/restaurant/layout');
      return RestaurantLayout.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch restaurant layout: $e');
    }
  }

  /// Mettre à jour la configuration du restaurant
  Future<RestaurantLayout> updateRestaurantLayout(Map<String, dynamic> layoutData) async {
    try {
      final response = await _client.put('/api/admin/restaurant/layout', data: layoutData);
      return RestaurantLayout.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update restaurant layout: $e');
    }
  }

  // ===== ENDPOINTS OPTIMISÉS POUR ÉVITER L'ENVOI DE TOUTES LES DONNÉES =====

  /// Mettre à jour seulement le statut d'une table (PATCH optimisé)
  Future<void> patchTableStatus(String id, String status) async {
    try {
      await _client.patch('/api/admin/tables/$id/status', data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  /// Mettre à jour seulement la capacité d'une table (PATCH optimisé)
  Future<void> patchTableCapacity(String id, int capacity) async {
    try {
      await _client.patch('/api/admin/tables/$id/capacity', data: {'capacity': capacity});
    } catch (e) {
      throw Exception('Failed to update table capacity: $e');
    }
  }

  /// Mettre à jour seulement la position d'une table (PATCH optimisé)
  Future<void> patchTablePosition(String id, double x, double y) async {
    try {
      await _client.patch('/api/admin/tables/$id/position', data: {
        'x': x,
        'y': y,
      });
    } catch (e) {
      throw Exception('Failed to update table position: $e');
    }
  }

  /// Mettre à jour seulement le nom d'une table (PATCH optimisé)
  Future<void> patchTableName(String id, String name) async {
    try {
      await _client.patch('/api/admin/tables/$id/name', data: {'name': name});
    } catch (e) {
      throw Exception('Failed to update table name: $e');
    }
  }

  /// Mettre à jour seulement la description d'une table (PATCH optimisé)
  Future<void> patchTableDescription(String id, String description) async {
    try {
      await _client.patch('/api/admin/tables/$id/description', data: {'description': description});
    } catch (e) {
      throw Exception('Failed to update table description: $e');
    }
  }

  /// Mettre à jour seulement l'état actif d'une table (PATCH optimisé)
  Future<void> patchTableActive(String id, bool isActive) async {
    try {
      await _client.patch('/api/admin/tables/$id/active', data: {'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to update table active status: $e');
    }
  }

  /// Obtenir seulement les métadonnées des tables (sans réservations)
  Future<List<Map<String, dynamic>>> getTablesMetadata() async {
    try {
      final response = await _client.get('/api/admin/tables/metadata');
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch tables metadata: $e');
    }
  }

  /// Obtenir seulement les statistiques d'une table
  Future<Map<String, dynamic>> getTableStatsOnly(String id) async {
    try {
      final response = await _client.get('/api/admin/tables/$id/stats-only');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch table stats: $e');
    }
  }

  /// Mise à jour en lot optimisée (pour plusieurs tables)
  Future<void> batchUpdateTables(List<Map<String, dynamic>> updates) async {
    try {
      await _client.patch('/api/admin/tables/batch', data: {'updates': updates});
    } catch (e) {
      throw Exception('Failed to batch update tables: $e');
    }
  }
}
