import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/schedule_repository.dart';
import '../../../../core/network/schedule_api_service.dart';
import '../../../../core/network/api_service_provider.dart';

/// État de la configuration des horaires
class ScheduleState {
  final Map<String, dynamic>? config;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const ScheduleState({
    this.config,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  ScheduleState copyWith({
    Map<String, dynamic>? config,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ScheduleState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier pour la gestion des horaires
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const ScheduleState());

  /// Charge la configuration des horaires
  Future<void> loadScheduleConfig({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final config = await _repository.getScheduleConfig(token: token);
      state = state.copyWith(
        config: config,
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

  /// Sauvegarde la configuration des horaires
  Future<void> saveScheduleConfig({
    required String token,
    required Map<String, dynamic> scheduleData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final config = await _repository.saveScheduleConfig(
        token: token,
        scheduleData: scheduleData,
      );
      state = state.copyWith(
        config: config,
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

  /// Met à jour la configuration des horaires
  Future<void> updateScheduleConfig({
    required String token,
    required Map<String, dynamic> scheduleData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final config = await _repository.updateScheduleConfig(
        token: token,
        scheduleData: scheduleData,
      );
      state = state.copyWith(
        config: config,
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

  /// Supprime la configuration des horaires
  Future<void> deleteScheduleConfig({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.deleteScheduleConfig(token: token);
      state = state.copyWith(
        config: null,
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

  /// Rafraîchit la configuration
  Future<void> refreshScheduleConfig({required String token}) async {
    await loadScheduleConfig(token: token);
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final scheduleApiServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return ScheduleApiService(dio, ref.read(apiBaseUrlProvider));
});

final scheduleRepositoryProvider = Provider((ref) => ScheduleRepository(ref.read(scheduleApiServiceProvider)));

/// Provider pour la gestion des horaires
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(ref.read(scheduleRepositoryProvider)),
);

/// Provider pour la configuration des horaires
final scheduleConfigProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(scheduleProvider).config;
});

/// Provider pour l'état de chargement
final scheduleLoadingProvider = Provider<bool>((ref) {
  return ref.watch(scheduleProvider).isLoading;
});

/// Provider pour l'erreur
final scheduleErrorProvider = Provider<String?>((ref) {
  return ref.watch(scheduleProvider).error;
});
