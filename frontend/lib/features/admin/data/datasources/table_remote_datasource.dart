import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';

/// Data source distant pour la gestion des tables
class TableRemoteDataSource {
  final ApiClient _apiClient;

  const TableRemoteDataSource(this._apiClient);

  /// Récupérer toutes les tables
  Future<List<TableEntity>> getAllTables() async {
    try {
      final response = await _apiClient.get('/api/admin/tables');
      return (response.data as List)
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tables: $e');
    }
  }

  /// Récupérer une table par ID
  Future<TableEntity?> getTableById(String id) async {
    try {
      final response = await _apiClient.get('/api/admin/tables/$id');
      return TableEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch table: $e');
    }
  }

  /// Récupérer les tables par statut
  Future<List<TableEntity>> getTablesByStatus(TableStatus status) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/tables',
        queryParameters: {'status': status.name},
      );
      return (response.data as List)
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tables by status: $e');
    }
  }

  /// Récupérer les tables disponibles
  Future<List<TableEntity>> getAvailableTables() async {
    try {
      final response = await _apiClient.get('/api/admin/tables/available');
      return (response.data as List)
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available tables: $e');
    }
  }

  /// Créer une nouvelle table
  Future<TableEntity> createTable(CreateTableRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/tables',
        data: request.toJson(),
      );
      return TableEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create table: $e');
    }
  }

  /// Mettre à jour une table
  Future<TableEntity> updateTable(String id, UpdateTableRequest request) async {
    try {
      final response = await _apiClient.put(
        '/api/admin/tables/$id',
        data: request.toJson(),
      );
      return TableEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update table: $e');
    }
  }

  /// Supprimer une table
  Future<void> deleteTable(String id) async {
    try {
      await _apiClient.delete('/api/admin/tables/$id');
    } catch (e) {
      throw Exception('Failed to delete table: $e');
    }
  }

  /// Changer le statut d'une table
  Future<TableEntity> updateTableStatus(String id, TableStatus status) async {
    try {
      final response = await _apiClient.patch(
        '/api/admin/tables/$id/status',
        data: {'status': status.name},
      );
      return TableEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }

  /// Récupérer les statistiques d'une table
  Future<TableStats?> getTableStats(String id) async {
    try {
      final response = await _apiClient.get('/api/admin/tables/$id/stats');
      return TableStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch table stats: $e');
    }
  }

  /// Récupérer les statistiques de toutes les tables
  Future<List<TableStats>> getAllTableStats() async {
    try {
      final response = await _apiClient.get('/api/admin/tables/stats');
      return (response.data as List)
          .map((json) => TableStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all table stats: $e');
    }
  }

  /// Vérifier la disponibilité d'une table
  Future<bool> isTableAvailable(String id, DateTime date, String time) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/tables/$id/availability',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'time': time,
        },
      );
      return response.data['available'] as bool;
    } catch (e) {
      throw Exception('Failed to check table availability: $e');
    }
  }

  /// Récupérer les tables disponibles pour une date/heure
  Future<List<TableEntity>> getAvailableTablesForDateTime(
    DateTime date,
    String time,
    int partySize,
  ) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/tables/available',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          'partySize': partySize,
        },
      );
      return (response.data as List)
          .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available tables for date/time: $e');
    }
  }

  /// Récupérer le plan du restaurant
  Future<RestaurantLayout> getRestaurantLayout() async {
    try {
      final response = await _apiClient.get('/api/admin/restaurant/layout');
      return RestaurantLayout.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch restaurant layout: $e');
    }
  }

  /// Mettre à jour le plan du restaurant
  Future<RestaurantLayout> updateRestaurantLayout(RestaurantLayout layout) async {
    try {
      final response = await _apiClient.put(
        '/api/admin/restaurant/layout',
        data: layout.toJson(),
      );
      return RestaurantLayout.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update restaurant layout: $e');
    }
  }
}

