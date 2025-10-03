import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/table_repository.dart';
import '../../../../core/network/table_api_service.dart';
import '../../../../core/network/api_service_provider.dart';

/// État des tables
class TableState {
  final List<Map<String, dynamic>>? tables;
  final Map<String, dynamic>? statistics;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const TableState({
    this.tables,
    this.statistics,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  TableState copyWith({
    List<Map<String, dynamic>>? tables,
    Map<String, dynamic>? statistics,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier pour la gestion des tables
class TableNotifier extends StateNotifier<TableState> {
  final TableRepository _repository;

  TableNotifier(this._repository) : super(const TableState());

  /// Charge toutes les tables
  Future<void> loadTables({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tables = await _repository.getTables(token: token);
      state = state.copyWith(
        tables: tables,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charge les statistiques des tables
  Future<void> loadStatistics({required String token}) async {
    try {
      final statistics = await _repository.getTableStatistics(token: token);
      state = state.copyWith(
        statistics: statistics,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Crée une nouvelle table
  Future<void> createTable({
    required String token,
    required Map<String, dynamic> tableData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newTable = await _repository.createTable(
        token: token,
        tableData: tableData,
      );
      
      final updatedTables = [...(state.tables ?? []), newTable];
      state = state.copyWith(
        tables: updatedTables.cast<Map<String, dynamic>>(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Met à jour une table
  Future<void> updateTable({
    required String token,
    required String tableId,
    required Map<String, dynamic> tableData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedTable = await _repository.updateTable(
        token: token,
        tableId: tableId,
        tableData: tableData,
      );
      
      final updatedTables = (state.tables ?? []).map((table) {
        if (table['id'] == tableId) {
          return updatedTable;
        }
        return table;
      }).toList();
      
      state = state.copyWith(
        tables: updatedTables.cast<Map<String, dynamic>>(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Supprime une table
  Future<void> deleteTable({
    required String token,
    required String tableId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.deleteTable(
        token: token,
        tableId: tableId,
      );
      
      final updatedTables = (state.tables ?? []).where((table) => table['id'] != tableId).toList();
      state = state.copyWith(
        tables: updatedTables.cast<Map<String, dynamic>>(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Met à jour le statut d'une table
  Future<void> updateTableStatus({
    required String token,
    required String tableId,
    required bool isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedTable = await _repository.updateTableStatus(
        token: token,
        tableId: tableId,
        isActive: isActive,
      );
      
      final updatedTables = (state.tables ?? []).map((table) {
        if (table['id'] == tableId) {
          return updatedTable;
        }
        return table;
      }).toList();
      
      state = state.copyWith(
        tables: updatedTables.cast<Map<String, dynamic>>(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rafraîchit les données
  Future<void> refreshTables({required String token}) async {
    await loadTables(token: token);
    await loadStatistics(token: token);
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final tableApiServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return TableApiService(dio, ref.read(apiBaseUrlProvider));
});

final tableRepositoryProvider = Provider((ref) => TableRepository(ref.read(tableApiServiceProvider)));

/// Provider pour la gestion des tables
final tableProvider = StateNotifierProvider<TableNotifier, TableState>(
  (ref) => TableNotifier(ref.read(tableRepositoryProvider)),
);

/// Provider pour la liste des tables
final tablesProvider = Provider<List<Map<String, dynamic>>?>((ref) {
  return ref.watch(tableProvider).tables;
});

/// Provider pour les statistiques des tables
final tableStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(tableProvider).statistics;
});

/// Provider pour l'état de chargement
final tableLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tableProvider).isLoading;
});

/// Provider pour l'erreur
final tableErrorProvider = Provider<String?>((ref) {
  return ref.watch(tableProvider).error;
});
