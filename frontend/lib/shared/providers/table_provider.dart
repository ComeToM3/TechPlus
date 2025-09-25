import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_state.dart';
import '../errors/app_errors.dart';
import '../../core/network/api_client.dart';
import '../../features/admin/domain/entities/table_entity.dart';
import '../../features/admin/domain/repositories/table_repository.dart';
import '../../features/admin/data/datasources/table_remote_datasource.dart';
import '../../features/admin/data/datasources/table_local_datasource.dart';
import '../../features/admin/data/repositories/table_repository_impl.dart';
import 'core_providers.dart';

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
  final TableRepository _repository;

  TableNotifier({required TableRepository repository})
      : _repository = repository,
        super(const TableState());

  /// Charger toutes les tables
  Future<void> loadTables() async {
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
      final stats = await _repository.getTableStats(tableId);
      if (stats != null) {
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

/// Provider pour la source de données distante des tables
final tableRemoteDataSourceProvider = Provider<TableRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TableRemoteDataSource(apiClient);
});

/// Provider pour la source de données locale des tables
final tableLocalDataSourceProvider = Provider<TableLocalDataSource>((ref) {
  return TableLocalDataSource();
});

/// Provider pour le repository des tables
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final remoteDataSource = ref.watch(tableRemoteDataSourceProvider);
  final localDataSource = ref.watch(tableLocalDataSourceProvider);
  return TableRepositoryImpl(remoteDataSource, localDataSource);
});

/// Provider unifié pour l'état des tables
final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return TableNotifier(repository: repository);
});

/// Provider pour une table spécifique
final tableByIdProvider = FutureProvider.family<TableEntity?, String>((ref, id) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getTableById(id);
});

/// Provider pour les tables disponibles
final availableTablesProvider = FutureProvider<List<TableEntity>>((ref) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getAvailableTables();
});

/// Provider pour les statistiques d'une table spécifique
final tableStatsProvider = FutureProvider.family<TableStats?, String>((ref, tableId) async {
  final repository = ref.watch(tableRepositoryProvider);
  return await repository.getTableStats(tableId);
});
