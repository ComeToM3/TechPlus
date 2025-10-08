import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_state.dart';
import '../errors/app_errors.dart';
import '../../features/admin/domain/entities/table_entity.dart';
import '../../features/admin/data/repositories/table_repository.dart' as data;
import '../../core/network/standard_table_api.dart';
import '../../core/network/api_providers.dart';


/// État unifié pour les tables
class TableState extends BaseListState<TableEntity> {
  final TableEntity? selectedTable;
  final String? selectedStatus;
  final Map<String, TableStats> tableStats;

  const TableState({
    super.items = const [],
    super.isLoading = false,
    super.error,
    this.selectedTable,
    this.selectedStatus,
    this.tableStats = const {},
  });

  @override
  TableState copyWith({
    List<TableEntity>? items,
    bool? isLoading,
    String? error,
    TableEntity? selectedTable,
    String? selectedStatus,
    Map<String, TableStats>? tableStats,
  }) {
    return TableState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTable: selectedTable ?? this.selectedTable,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      tableStats: tableStats ?? this.tableStats,
    );
  }
}

/// Notifier unifié pour la gestion des tables
class TableNotifier extends StateNotifier<TableState> {
  final data.TableRepository _repository;

  TableNotifier({required data.TableRepository repository})
      : _repository = repository,
        super(const TableState());

  /// Charger toutes les tables
  Future<void> loadTables({String? token}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tables = await _repository.getAllTables();
      state = state.copyWith(
        items: tables,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Charger les statistiques des tables
  Future<void> loadStatistics({String? token}) async {
    // Cette méthode peut être implémentée plus tard si nécessaire
    // Pour l'instant, on ne fait rien
  }

  /// Créer une nouvelle table
  Future<void> createTable({
    required String token,
    required int number,
    required int capacity,
    String? position,
    required String status,
  }) async {
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.createTable(
        number: number,
        capacity: capacity,
        position: position,
        status: status,
      );
      // Recharger les tables après création
      await loadTables(token: token);
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Mettre à jour une table
  Future<void> updateTable({
    required String token,
    required String tableId,
    String? name,
    int? capacity,
    String? status,
    String? description,
    String? position,
  }) async {
    if (kDebugMode) {
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (kDebugMode) {
      }
      await _repository.updateTable(
        id: tableId,
        name: name,
        capacity: capacity,
        status: status,
        description: description,
        position: position,
      );
      if (kDebugMode) {
      }
      // Recharger les tables après mise à jour
      await loadTables(token: token);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Supprimer une table
  Future<void> deleteTable({
    required String token,
    required String tableId,
  }) async {
    if (kDebugMode) {
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (kDebugMode) {
      }
      await _repository.deleteTable(tableId);
      if (kDebugMode) {
      }
      // Recharger les tables après suppression
      await loadTables(token: token);
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Rafraîchir les tables
  Future<void> refreshTables({String? token}) async {
    await loadTables(token: token);
  }

  /// Charger les tables par statut
  Future<void> loadTablesByStatus(TableStatus status) async {
    state = state.copyWith(isLoading: true, error: null, selectedStatus: status.name);
    
    try {
      final tables = await _repository.getTablesByStatus(status);
      state = state.copyWith(
        items: tables,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Charger les tables disponibles
  Future<void> loadAvailableTables() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tables = await _repository.getAvailableTables();
      state = state.copyWith(
        items: tables,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Charger les statistiques d'une table spécifique
  Future<void> loadTableStats(String tableId) async {
    try {
      final statsData = await _repository.getTableStats(tableId);
      if (statsData != null) {
        // Convertir Map<String, dynamic> en TableStats
        final stats = TableStats(
          tableId: statsData['tableId'] ?? tableId,
          totalReservations: statsData['totalReservations'] ?? 0,
          averageOccupancy: (statsData['averageOccupancy'] ?? 0.0).toDouble(),
          revenue: (statsData['revenue'] ?? 0.0).toDouble(),
          totalGuests: statsData['totalGuests'] ?? 0,
          lastReservation: DateTime.tryParse(statsData['lastReservation'] ?? '') ?? DateTime.now(),
        );
        final statsMap = Map<String, TableStats>.from(state.tableStats);
        statsMap[tableId] = stats;
        state = state.copyWith(tableStats: statsMap);
      }
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(error: error.message);
    }
  }

  /// Sélectionner une table
  void selectTable(TableEntity table) {
    state = state.copyWith(selectedTable: table);
  }

  /// Réinitialiser l'état
  void reset() {
    state = const TableState();
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}


/// Provider unifié pour l'état des tables
final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  final apiClient = ref.watch(standardApiClientProvider);
  final tableApi = StandardTableApi(apiClient);
  final repository = data.TableRepository(tableApi);
  
  // Utiliser directement le repository de données
  return TableNotifier(repository: repository);
});

/// Provider pour une table spécifique
final tableByIdProvider = FutureProvider.family<TableEntity?, String>((ref, id) async {
  final apiClient = ref.watch(standardApiClientProvider);
  final tableApi = StandardTableApi(apiClient);
  final repository = data.TableRepository(tableApi);
  return await repository.getTableById(id);
});

/// Provider pour les tables disponibles
final availableTablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final apiClient = ref.watch(standardApiClientProvider);
  final tableApi = StandardTableApi(apiClient);
  final repository = data.TableRepository(tableApi);
  return await repository.getAvailableTables();
});

/// Provider pour les tables (compatibilité)
final tablesProvider = Provider<List<TableEntity>>((ref) {
  final tableState = ref.watch(tableProvider);
  return tableState.items;
});

/// Provider pour l'état de chargement des tables
final tableLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tableProvider).isLoading;
});

/// Provider pour l'erreur des tables
final tableErrorProvider = Provider<String?>((ref) {
  return ref.watch(tableProvider).error;
});

/// Provider pour les statistiques d'une table spécifique
final tableStatsByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, tableId) async {
  final apiClient = ref.watch(standardApiClientProvider);
  final tableApi = StandardTableApi(apiClient);
  final repository = data.TableRepository(tableApi);
  return await repository.getTableStats(tableId);
});
