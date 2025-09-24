import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../../data/datasources/table_remote_datasource.dart';
import '../../data/datasources/table_local_datasource.dart';
import '../../data/repositories/table_repository_impl.dart';

/// Provider pour l'ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  return ApiClient(dio);
});

/// Provider pour le data source distant
final tableRemoteDataSourceProvider = Provider<TableRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TableRemoteDataSource(apiClient);
});

/// Provider pour le data source local
final tableLocalDataSourceProvider = Provider<TableLocalDataSource>((ref) {
  return const TableLocalDataSource();
});

/// Provider pour le repository
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final remoteDataSource = ref.watch(tableRemoteDataSourceProvider);
  final localDataSource = ref.watch(tableLocalDataSourceProvider);
  return TableRepositoryImpl(remoteDataSource, localDataSource);
});

/// Provider pour la liste des tables
final tablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getAllTables();
});

/// Provider pour une table spécifique
final tableProvider = FutureProvider.family<TableEntity?, String>((ref, id) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getTableById(id);
});

/// Provider pour les tables par statut
final tablesByStatusProvider = FutureProvider.family<List<TableEntity>, TableStatus>((ref, status) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getTablesByStatus(status);
});

/// Provider pour les tables disponibles
final availableTablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getAvailableTables();
});

/// Provider pour les statistiques des tables
final tableStatsProvider = FutureProvider<List<TableStats>>((ref) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getAllTableStats();
});

/// Provider pour les statistiques d'une table spécifique
final tableStatsByIdProvider = FutureProvider.family<TableStats?, String>((ref, id) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getTableStats(id);
});

/// Provider pour le plan du restaurant
final restaurantLayoutProvider = FutureProvider<RestaurantLayout>((ref) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getRestaurantLayout();
});

/// Provider pour la disponibilité d'une table
final tableAvailabilityProvider = FutureProvider.family<bool, TableAvailabilityParams>((ref, params) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.isTableAvailable(params.tableId, params.date, params.time);
});

/// Provider pour les tables disponibles pour une date/heure
final availableTablesForDateTimeProvider = FutureProvider.family<List<TableEntity>, DateTimeParams>((ref, params) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getAvailableTablesForDateTime(params.date, params.time, params.partySize);
});

/// Provider pour l'état de chargement des tables
final tablesLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'état d'erreur des tables
final tablesErrorProvider = StateProvider<String?>((ref) => null);

/// Provider pour les actions sur les tables
final tableActionsProvider = StateNotifierProvider<TableActionsNotifier, TableActionsState>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return TableActionsNotifier(repository);
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
  final TableRepository _repository;

  TableActionsNotifier(this._repository) : super(const TableActionsState());

  /// Créer une nouvelle table
  Future<TableEntity?> createTable(CreateTableRequest request) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      final newTable = await _repository.createTable(request);
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
      final updatedTable = await _repository.updateTable(id, request);
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
      await _repository.deleteTable(id);
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
      final updatedTable = await _repository.updateTableStatus(id, status);
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
      final updatedLayout = await _repository.updateRestaurantLayout(layout);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Plan du restaurant mis à jour',
      );
      return updatedLayout;
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

/// Paramètres pour la disponibilité d'une table
class TableAvailabilityParams {
  final String tableId;
  final DateTime date;
  final String time;

  const TableAvailabilityParams({
    required this.tableId,
    required this.date,
    required this.time,
  });
}

/// Paramètres pour les tables disponibles à une date/heure
class DateTimeParams {
  final DateTime date;
  final String time;
  final int partySize;

  const DateTimeParams({
    required this.date,
    required this.time,
    required this.partySize,
  });
}

