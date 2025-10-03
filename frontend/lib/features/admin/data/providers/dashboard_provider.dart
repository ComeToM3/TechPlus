import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_metrics_model.dart';
import '../repositories/dashboard_repository.dart';
import '../../../../core/network/dashboard_api_service.dart';
import '../../../../core/network/api_service_provider.dart';

/// État du dashboard
class DashboardState {
  final DashboardMetricsModel? metrics;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const DashboardState({
    this.metrics,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardMetricsModel? metrics,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier pour le dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState());

  /// Charge les métriques du dashboard
  Future<void> loadDashboardMetrics({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final metrics = await _repository.getDashboardMetrics(token: token);
      state = state.copyWith(
        metrics: metrics,
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

  /// Rafraîchit les métriques
  Future<void> refreshMetrics({required String token}) async {
    await loadDashboardMetrics(token: token);
  }

  /// Charge les analytics détaillées
  Future<DashboardMetricsModel?> loadAnalytics({
    required String token,
    String period = '30d',
  }) async {
    try {
      return await _repository.getDashboardAnalytics(
        token: token,
        period: period,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final dashboardApiServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return DashboardApiService(dio, ref.read(apiBaseUrlProvider));
});

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref.read(dashboardApiServiceProvider)));

/// Provider pour le dashboard
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(ref.read(dashboardRepositoryProvider)),
);

/// Provider pour les métriques du dashboard
final dashboardMetricsProvider = Provider<DashboardMetricsModel?>((ref) {
  return ref.watch(dashboardProvider).metrics;
});

/// Provider pour l'état de chargement
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

/// Provider pour l'erreur
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardProvider).error;
});
