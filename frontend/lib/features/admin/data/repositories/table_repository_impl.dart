import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_remote_datasource.dart';
import '../datasources/table_local_datasource.dart';

/// Implémentation du repository pour la gestion des tables
class TableRepositoryImpl implements TableRepository {
  final TableRemoteDataSource _remoteDataSource;
  final TableLocalDataSource _localDataSource;

  const TableRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<List<TableEntity>> getAllTables() async {
    try {
      // Essayer d'abord le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null && cachedTables.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateCacheInBackground();
        return cachedTables;
      }

      // Récupérer depuis l'API
      final tables = await _remoteDataSource.getAllTables();
      await _localDataSource.cacheTables(tables);
      return tables;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null) {
        return cachedTables;
      }
      rethrow;
    }
  }

  @override
  Future<TableEntity?> getTableById(String id) async {
    try {
      return await _remoteDataSource.getTableById(id);
    } catch (e) {
      // Essayer de trouver dans le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null) {
        try {
          return cachedTables.firstWhere((table) => table.id == id);
        } catch (e) {
          return null;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<TableEntity>> getTablesByStatus(TableStatus status) async {
    try {
      return await _remoteDataSource.getTablesByStatus(status);
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null) {
        return cachedTables.where((table) => table.status == status).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<TableEntity>> getAvailableTables() async {
    try {
      return await _remoteDataSource.getAvailableTables();
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null) {
        return cachedTables
            .where((table) => 
                table.status == TableStatus.available && 
                table.isActive)
            .toList();
      }
      rethrow;
    }
  }

  @override
  Future<TableEntity> createTable(CreateTableRequest request) async {
    try {
      final newTable = await _remoteDataSource.createTable(request);
      // Mettre à jour le cache local
      await _updateCacheAfterModification();
      return newTable;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TableEntity> updateTable(String id, UpdateTableRequest request) async {
    try {
      final updatedTable = await _remoteDataSource.updateTable(id, request);
      // Mettre à jour le cache local
      await _updateCacheAfterModification();
      return updatedTable;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      await _remoteDataSource.deleteTable(id);
      // Mettre à jour le cache local
      await _updateCacheAfterModification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TableEntity> updateTableStatus(String id, TableStatus status) async {
    try {
      final updatedTable = await _remoteDataSource.updateTableStatus(id, status);
      // Mettre à jour le cache local
      await _updateCacheAfterModification();
      return updatedTable;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TableStats?> getTableStats(String id) async {
    try {
      return await _remoteDataSource.getTableStats(id);
    } catch (e) {
      // Essayer le cache local
      final cachedStats = await _localDataSource.getCachedTableStats();
      if (cachedStats != null) {
        try {
          return cachedStats.firstWhere((stat) => stat.tableId == id);
        } catch (e) {
          return null;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<TableStats>> getAllTableStats() async {
    try {
      // Essayer d'abord le cache local
      final cachedStats = await _localDataSource.getCachedTableStats();
      if (cachedStats != null && cachedStats.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateStatsCacheInBackground();
        return cachedStats;
      }

      // Récupérer depuis l'API
      final stats = await _remoteDataSource.getAllTableStats();
      await _localDataSource.cacheTableStats(stats);
      return stats;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedStats = await _localDataSource.getCachedTableStats();
      if (cachedStats != null) {
        return cachedStats;
      }
      rethrow;
    }
  }

  @override
  Future<bool> isTableAvailable(String id, DateTime date, String time) async {
    try {
      return await _remoteDataSource.isTableAvailable(id, date, time);
    } catch (e) {
      // En cas d'erreur réseau, supposer que la table n'est pas disponible
      return false;
    }
  }

  @override
  Future<List<TableEntity>> getAvailableTablesForDateTime(
    DateTime date,
    String time,
    int partySize,
  ) async {
    try {
      return await _remoteDataSource.getAvailableTablesForDateTime(date, time, partySize);
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedTables = await _localDataSource.getCachedTables();
      if (cachedTables != null) {
        return cachedTables
            .where((table) => 
                table.status == TableStatus.available && 
                table.isActive &&
                table.capacity >= partySize)
            .toList();
      }
      rethrow;
    }
  }

  @override
  Future<RestaurantLayout> getRestaurantLayout() async {
    try {
      // Essayer d'abord le cache local
      final cachedLayout = await _localDataSource.getCachedRestaurantLayout();
      if (cachedLayout != null) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateLayoutCacheInBackground();
        return cachedLayout;
      }

      // Récupérer depuis l'API
      final layout = await _remoteDataSource.getRestaurantLayout();
      await _localDataSource.cacheRestaurantLayout(layout);
      return layout;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedLayout = await _localDataSource.getCachedRestaurantLayout();
      if (cachedLayout != null) {
        return cachedLayout;
      }
      rethrow;
    }
  }

  @override
  Future<RestaurantLayout> updateRestaurantLayout(RestaurantLayout layout) async {
    try {
      final updatedLayout = await _remoteDataSource.updateRestaurantLayout(layout);
      await _localDataSource.cacheRestaurantLayout(updatedLayout);
      return updatedLayout;
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour le cache en arrière-plan
  void _updateCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final tables = await _remoteDataSource.getAllTables();
        await _localDataSource.cacheTables(tables);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache après modification
  Future<void> _updateCacheAfterModification() async {
    try {
      final tables = await _remoteDataSource.getAllTables();
      await _localDataSource.cacheTables(tables);
    } catch (e) {
      // Ignore cache update errors
    }
  }

  /// Mettre à jour le cache des statistiques en arrière-plan
  void _updateStatsCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final stats = await _remoteDataSource.getAllTableStats();
        await _localDataSource.cacheTableStats(stats);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache du plan en arrière-plan
  void _updateLayoutCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final layout = await _remoteDataSource.getRestaurantLayout();
        await _localDataSource.cacheRestaurantLayout(layout);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }
}

