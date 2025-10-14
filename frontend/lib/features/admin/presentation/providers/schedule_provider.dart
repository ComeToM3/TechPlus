import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/standard_schedule_api.dart';
import '../../domain/entities/schedule_entity.dart';

/// Provider principal pour la gestion des horaires
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return ScheduleNotifier(scheduleApi);
});

/// Provider pour la configuration des créneaux - SUPPRIMÉ pour éviter les conflits
/// Utiliser scheduleProvider à la place
// final scheduleConfigProvider = FutureProvider.family<ScheduleConfig?, String>((ref, restaurantId) async {
//   final scheduleApi = ref.watch(scheduleApiProvider);
//   return await scheduleApi.getScheduleConfig(restaurantId);
// });

/// Provider pour les créneaux disponibles
final availableSlotsProvider = FutureProvider.family<List<TimeSlot>, AvailableSlotsParams>((ref, params) async {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return await scheduleApi.getAvailableSlots(params.restaurantId, params.date, params.partySize);
});

/// Provider pour valider une réservation
final validateReservationProvider = FutureProvider.family<Map<String, dynamic>, ValidateReservationParams>((ref, params) async {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return await scheduleApi.validateReservation(params.restaurantId, params.date, params.time, params.partySize);
});

// NOTE: scheduleStatsProvider supprimé car la méthode getScheduleStats n'existe plus

/// État principal des horaires
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

/// Notifier principal pour la gestion des horaires
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final StandardScheduleApi _scheduleApi;
  bool _isLoading = false;

  ScheduleNotifier(this._scheduleApi) : super(const ScheduleState());

  /// Charge la configuration des horaires
  Future<void> loadScheduleConfig({String? token}) async {
    if (_isLoading) {
      print('🔍 [ScheduleProvider] Already loading, skipping');
      return; // Éviter les appels multiples
    }
    
    // Éviter les rechargements si les données sont déjà présentes
    if (state.config != null && !state.isLoading) {
      print('🔍 [ScheduleProvider] Data already loaded, skipping');
      return;
    }
    
    // Protection supplémentaire : vérifier si on a déjà des daySchedules
    if (state.config != null && state.config!['daySchedules'] != null && (state.config!['daySchedules'] as List).isNotEmpty) {
      print('🔍 [ScheduleProvider] daySchedules already present, skipping');
      return;
    }
    
    print('🔍 [ScheduleProvider] Loading schedule config...');
    
    _isLoading = true;
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Utiliser un restaurantId par défaut ou récupérer depuis l'API
      final config = await _scheduleApi.getScheduleConfig('default');
      
      state = state.copyWith(
        config: config?.toJson(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Sauvegarde la configuration des horaires
  Future<void> saveScheduleConfig({
    String? token,
    required Map<String, dynamic> scheduleData,
  }) async {
    if (_isLoading) return; // Éviter les appels multiples
    
    _isLoading = true;
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final scheduleConfig = ScheduleConfig.fromJson(scheduleData);
      final config = await _scheduleApi.saveScheduleConfig('default', scheduleConfig);
      state = state.copyWith(
        config: config.toJson(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Met à jour la configuration des horaires
  Future<void> updateScheduleConfig({
    String? token,
    required Map<String, dynamic> scheduleData,
  }) async {
    if (_isLoading) return; // Éviter les appels multiples
    
    _isLoading = true;
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Mettre à jour l'état local immédiatement pour un feedback visuel
      state = state.copyWith(
        config: scheduleData,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      
      // Ensuite sauvegarder sur le serveur
      final scheduleConfig = ScheduleConfig.fromJson(scheduleData);
      final config = await _scheduleApi.saveScheduleConfig('default', scheduleConfig);
      
      // Mettre à jour avec la réponse du serveur
      state = state.copyWith(
        config: config.toJson(),
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // En cas d'erreur, recharger depuis le serveur pour restaurer l'état
      await loadScheduleConfig(token: token);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Rafraîchit la configuration
  Future<void> refreshScheduleConfig({required String token}) async {
    // Forcer le rechargement même si déjà en cours
    _isLoading = false;
    await loadScheduleConfig(token: token);
  }

  /// Vérifie si les données sont déjà chargées
  bool get hasData => state.config != null && !state.isLoading;

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Réinitialise complètement l'état
  void reset() {
    _isLoading = false;
    state = const ScheduleState();
  }
}

/// Paramètres pour les créneaux disponibles
class AvailableSlotsParams {
  final String restaurantId;
  final DateTime date;
  final int partySize;

  const AvailableSlotsParams({
    required this.restaurantId,
    required this.date,
    required this.partySize,
  });
}

/// Paramètres pour valider une réservation
class ValidateReservationParams {
  final String restaurantId;
  final DateTime date;
  final String time;
  final int partySize;

  const ValidateReservationParams({
    required this.restaurantId,
    required this.date,
    required this.time,
    required this.partySize,
  });
}

// NOTE: ScheduleStatsParams supprimé car scheduleStatsProvider n'existe plus
