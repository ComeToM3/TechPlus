import '../../../../core/network/standard_table_api.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/restaurant_layout_entity.dart';

/// Repository pour la gestion des tables
class TableRepository {
  final StandardTableApi _apiService;

  TableRepository(this._apiService);

  /// Récupère toutes les tables
  Future<List<TableEntity>> getAllTables() async {
    try {
      final tables = await _apiService.getAllTables();
      return tables;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables: $e');
    }
  }

  /// Récupère une table par son ID
  Future<TableEntity?> getTableById(String id) async {
    try {
      return await _apiService.getTableById(id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la table: $e');
    }
  }

  /// Crée une nouvelle table
  Future<TableEntity> createTable({
    required int number,
    required int capacity,
    String? position,
    required String status,
  }) async {
    try {
      final tableData = {
        'number': number,
        'capacity': capacity,
        if (position != null) 'position': position,
        'status': status,
      };
      
      
      final result = await _apiService.createTable(tableData);
      
      
      return result;
    } catch (e) {
      throw Exception('Erreur lors de la création de la table: $e');
    }
  }

  /// Met à jour une table
  Future<TableEntity> updateTable({
    required String id,
    String? name,
    int? capacity,
    String? status,
    String? description,
    String? position,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['number'] = name; // Le backend attend 'number', pas 'name'
      if (capacity != null) updateData['capacity'] = capacity;
      if (status != null) {
        // Le backend attend 'isActive' (boolean) pour le statut
        updateData['isActive'] = status == 'available';
      }
      if (description != null) updateData['description'] = description;
      if (position != null) updateData['position'] = position;
      
      return await _apiService.updateTable(id, updateData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la table: $e');
    }
  }

  /// Supprime une table
  Future<void> deleteTable(String id) async {
    try {
      await _apiService.deleteTable(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la table: $e');
    }
  }

  /// Récupère les statistiques des tables
  Future<Map<String, dynamic>> getTableStatistics() async {
    try {
      return await _apiService.getTableStatistics();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  /// Récupère la disposition du restaurant
  Future<RestaurantLayout> getRestaurantLayout() async {
    try {
      return await _apiService.getRestaurantLayout();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la disposition: $e');
    }
  }

  /// Met à jour la disposition du restaurant
  Future<RestaurantLayout> updateRestaurantLayout(RestaurantLayout layout) async {
    try {
      return await _apiService.updateRestaurantLayout(layout.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la disposition: $e');
    }
  }

  /// Récupère les tables par statut
  Future<List<TableEntity>> getTablesByStatus(TableStatus status) async {
    try {
      final allTables = await getAllTables();
      return allTables.where((table) => table.status == status).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables par statut: $e');
    }
  }

  /// Récupère les tables disponibles (toutes les tables actives)
  Future<List<TableEntity>> getAvailableTables() async {
    try {
      final allTables = await getAllTables();
      return allTables.where((table) => table.isActive).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables disponibles: $e');
    }
  }

  /// Récupère les statistiques d'une table spécifique
  Future<Map<String, dynamic>> getTableStats(String tableId) async {
    try {
      return await _apiService.getTableStats(tableId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques de la table: $e');
    }
  }
}