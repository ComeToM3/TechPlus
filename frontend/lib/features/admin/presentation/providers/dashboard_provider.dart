import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/di/injection_container.dart';

/// État du dashboard
class DashboardState {
  final DashboardMetrics? metrics;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const DashboardState({
    this.metrics,
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardMetrics? metrics,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier pour la gestion du dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository? _repository;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    if (_repository != null) {
      loadDashboardMetrics();
    }
  }

  /// Charger les métriques du dashboard
  Future<void> loadDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Repository not available',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final metrics = await _repository!.getDashboardMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        metrics: metrics,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Rafraîchir les métriques
  Future<void> refreshMetrics() async {
    if (_repository == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Repository not available',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository!.refreshMetrics();
      await loadDashboardMetrics();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Charger les tendances des réservations
  Future<List<ReservationTrend>> loadReservationTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    if (_repository == null) {
      throw Exception('Repository not available');
    }
    
    try {
      return await _repository!.getReservationTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
    } catch (e) {
      throw Exception('Failed to load reservation trends: $e');
    }
  }

  /// Charger les tendances des revenus
  Future<List<RevenueTrend>> loadRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    if (_repository == null) {
      throw Exception('Repository not available');
    }
    
    try {
      return await _repository!.getRevenueTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
    } catch (e) {
      throw Exception('Failed to load revenue trends: $e');
    }
  }

  /// Charger l'occupation des tables
  Future<List<TableOccupancy>> loadTableOccupancy() async {
    if (_repository == null) {
      throw Exception('Repository not available');
    }
    
    try {
      return await _repository!.getTableOccupancy();
    } catch (e) {
      throw Exception('Failed to load table occupancy: $e');
    }
  }

  /// Charger les créneaux horaires populaires
  Future<List<PopularTimeSlot>> loadPopularTimeSlots({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_repository == null) {
      throw Exception('Repository not available');
    }
    
    try {
      return await _repository!.getPopularTimeSlots(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to load popular time slots: $e');
    }
  }

  /// Charger les segments de clients
  Future<List<CustomerSegment>> loadCustomerSegments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_repository == null) {
      throw Exception('Repository not available');
    }
    
    try {
      return await _repository!.getCustomerSegments(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to load customer segments: $e');
    }
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider pour le repository du dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository?>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider).value;
  
  if (sharedPreferences == null) {
    return null; // Retourner null au lieu de lancer une exception
  }

  final remoteDataSource = DashboardRemoteDataSource(apiClient);
  final localDataSource = DashboardLocalDataSource(sharedPreferences);
  
  return DashboardRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Provider pour le notifier du dashboard
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

/// Provider pour les métriques du dashboard
final dashboardMetricsProvider = Provider<DashboardMetrics?>((ref) {
  return ref.watch(dashboardProvider).metrics;
});

/// Provider pour l'état de chargement du dashboard
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

/// Provider pour l'erreur du dashboard
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardProvider).errorMessage;
});

/// Provider pour la dernière mise à jour du dashboard
final dashboardLastUpdatedProvider = Provider<DateTime?>((ref) {
  return ref.watch(dashboardProvider).lastUpdated;
});
