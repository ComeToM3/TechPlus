import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../../features/admin/domain/entities/table_entity.dart';

/// API pour la gestion des tables
class TablesApi {
  final Dio _dio;
  final String _baseUrl;

  TablesApi(this._dio, this._baseUrl);

  /// Obtenir toutes les tables
  Future<List<TableEntity>> getTables({
    String? restaurantId,
    bool? isActive,
    TableStatus? status,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/admin/tables',
        queryParameters: {
          if (restaurantId != null) 'restaurantId': restaurantId,
          if (isActive != null) 'isActive': isActive,
          if (status != null) 'status': status.name,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> tablesData = response.data['tables'];
        return tablesData.map((table) => TableEntity.fromJson(table)).toList();
      } else {
        throw Exception('Failed to fetch tables');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching tables: $e');
    }
  }

  /// Obtenir une table par ID
  Future<TableEntity?> getTableById(String tableId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/tables/$tableId');

      if (response.statusCode == 200) {
        return TableEntity.fromJson(response.data['table']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch table');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching table: $e');
    }
  }

  /// Créer une nouvelle table
  Future<TableEntity> createTable(CreateTableRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/admin/tables',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return TableEntity.fromJson(response.data['table']);
      } else {
        throw Exception('Failed to create table');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating table: $e');
    }
  }

  /// Mettre à jour une table
  Future<TableEntity> updateTable(String tableId, UpdateTableRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/admin/tables/$tableId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return TableEntity.fromJson(response.data['table']);
      } else {
        throw Exception('Failed to update table');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating table: $e');
    }
  }

  /// Supprimer une table
  Future<void> deleteTable(String tableId) async {
    try {
      final response = await _dio.delete('$_baseUrl/api/admin/tables/$tableId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete table');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting table: $e');
    }
  }

  /// Obtenir les statistiques d'une table
  Future<TableStats> getTableStats(String tableId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/tables/$tableId/stats');

      if (response.statusCode == 200) {
        return TableStats.fromJson(response.data['stats']);
      } else {
        throw Exception('Failed to fetch table stats');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching table stats: $e');
    }
  }

  /// Obtenir le plan du restaurant
  Future<List<TableEntity>> getRestaurantLayout(String restaurantId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/admin/restaurants/$restaurantId/layout');

      if (response.statusCode == 200) {
        final List<dynamic> tablesData = response.data['tables'];
        return tablesData.map((table) => TableEntity.fromJson(table)).toList();
      } else {
        throw Exception('Failed to fetch restaurant layout');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching restaurant layout: $e');
    }
  }

  /// Mettre à jour le statut d'une table
  Future<TableEntity> updateTableStatus(String tableId, TableStatus status) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/api/admin/tables/$tableId/status',
        data: {'status': status.name},
      );

      if (response.statusCode == 200) {
        return TableEntity.fromJson(response.data['table']);
      } else {
        throw Exception('Failed to update table status');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating table status: $e');
    }
  }
}
