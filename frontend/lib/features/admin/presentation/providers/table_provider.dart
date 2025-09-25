import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/tables_api.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/restaurant_layout_entity.dart';

/// Provider pour la liste des tables
final tablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final tablesApi = ref.watch(tablesApiProvider);
  return await tablesApi.getTables();
});

/// Provider pour une table spécifique
final tableProvider = FutureProvider.family<TableEntity?, String>((ref, id) async {
  final tablesApi = ref.watch(tablesApiProvider);
  return await tablesApi.getTableById(id);
});

/// Provider pour les tables par statut
final tablesByStatusProvider = FutureProvider.family<List<TableEntity>, TableStatus>((ref, status) async {
  final tablesApi = ref.watch(tablesApiProvider);
  return await tablesApi.getTables(status: status);
});

/// Provider pour les tables disponibles
final availableTablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final tablesApi = ref.watch(tablesApiProvider);
  return await tablesApi.getTables(status: TableStatus.available);
});

/// Provider pour les statistiques d'une table spécifique
final tableStatsByIdProvider = FutureProvider.family<TableStats?, String>((ref, id) async {
  final tablesApi = ref.watch(tablesApiProvider);
  return await tablesApi.getTableStats(id);
});

/// Provider pour toutes les statistiques des tables
final tableStatsProvider = FutureProvider<List<TableStats>>((ref) async {
  final tablesApi = ref.watch(tablesApiProvider);
  final tables = await tablesApi.getTables();
  final stats = <TableStats>[];
  for (final table in tables) {
    try {
      final tableStats = await tablesApi.getTableStats(table.id);
      if (tableStats != null) {
        stats.add(tableStats);
      }
    } catch (e) {
      // Ignorer les erreurs pour les statistiques individuelles
    }
  }
  return stats;
});

/// Provider pour le plan du restaurant
final restaurantLayoutProvider = FutureProvider<RestaurantLayout>((ref) async {
  final tablesApi = ref.watch(tablesApiProvider);
  final tables = await tablesApi.getRestaurantLayout('restaurant_1'); // TODO: Récupérer l'ID du restaurant depuis l'état
  return RestaurantLayout.fromTables(tables);
});

/// Provider pour l'état de chargement des tables
final tablesLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'état d'erreur des tables
final tablesErrorProvider = StateProvider<String?>((ref) => null);

/// Provider pour les actions sur les tables
final tableActionsProvider = StateNotifierProvider<TableActionsNotifier, TableActionsState>((ref) {
  final tablesApi = ref.watch(tablesApiProvider);
  return TableActionsNotifier(tablesApi);
});

/// État des actions sur les tables
class TableActionsState {
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final String? successMessage;

  const TableActionsState({
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.successMessage,
  });

  TableActionsState copyWith({
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    String? successMessage,
  }) {
    return TableActionsState(
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Notifier pour les actions sur les tables
class TableActionsNotifier extends StateNotifier<TableActionsState> {
  final TablesApi _tablesApi;

  TableActionsNotifier(this._tablesApi) : super(const TableActionsState());

  /// Créer une nouvelle table
  Future<TableEntity?> createTable(CreateTableRequest request) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      final newTable = await _tablesApi.createTable(request);
      state = state.copyWith(
        isCreating: false,
        successMessage: 'Table créée avec succès',
      );
      return newTable;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erreur lors de la création de la table: $e',
      );
      return null;
    }
  }

  /// Mettre à jour une table
  Future<TableEntity?> updateTable(String id, UpdateTableRequest request) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedTable = await _tablesApi.updateTable(id, request);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Table mise à jour avec succès',
      );
      return updatedTable;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour de la table: $e',
      );
      return null;
    }
  }

  /// Supprimer une table
  Future<bool> deleteTable(String id) async {
    state = state.copyWith(isDeleting: true, error: null);
    
    try {
      await _tablesApi.deleteTable(id);
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Table supprimée avec succès',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erreur lors de la suppression de la table: $e',
      );
      return false;
    }
  }

  /// Changer le statut d'une table
  Future<TableEntity?> updateTableStatus(String id, TableStatus status) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedTable = await _tablesApi.updateTableStatus(id, status);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Statut de la table mis à jour',
      );
      return updatedTable;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour du statut: $e',
      );
      return null;
    }
  }

  /// Mettre à jour le plan du restaurant
  Future<RestaurantLayout?> updateRestaurantLayout(RestaurantLayout layout) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      // Pour l'instant, on simule la mise à jour
      // TODO: Implémenter la mise à jour du plan via l'API
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Plan du restaurant mis à jour',
      );
      return layout;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour du plan: $e',
      );
      return null;
    }
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

