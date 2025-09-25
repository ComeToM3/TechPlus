import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_providers.dart';
import '../../domain/entities/schedule_entity.dart';

/// Provider pour la configuration des créneaux
final scheduleConfigProvider = FutureProvider.family<ScheduleConfig?, String>((ref, restaurantId) async {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return await scheduleApi.getScheduleConfig(restaurantId);
});

/// Provider pour les créneaux disponibles
final availableSlotsProvider = FutureProvider.family<List<TimeSlot>, AvailableSlotsParams>((ref, params) async {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return await scheduleApi.getAvailableSlots(params.restaurantId, params.date, params.partySize);
});

/// Provider pour les statistiques des créneaux
final scheduleStatsProvider = FutureProvider.family<Map<String, dynamic>, ScheduleStatsParams>((ref, params) async {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return await scheduleApi.getScheduleStats(params.restaurantId, startDate: params.startDate, endDate: params.endDate);
});

/// Provider pour l'état de chargement des créneaux
final scheduleLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'état d'erreur des créneaux
final scheduleErrorProvider = StateProvider<String?>((ref) => null);

/// Provider pour les actions sur les créneaux
final scheduleActionsProvider = StateNotifierProvider<ScheduleActionsNotifier, ScheduleActionsState>((ref) {
  final scheduleApi = ref.watch(scheduleApiProvider);
  return ScheduleActionsNotifier(scheduleApi);
});

/// État des actions sur les créneaux
class ScheduleActionsState {
  final bool isSaving;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final String? successMessage;

  const ScheduleActionsState({
    this.isSaving = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.successMessage,
  });

  ScheduleActionsState copyWith({
    bool? isSaving,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    String? successMessage,
  }) {
    return ScheduleActionsState(
      isSaving: isSaving ?? this.isSaving,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Notifier pour les actions sur les créneaux
class ScheduleActionsNotifier extends StateNotifier<ScheduleActionsState> {
  final ScheduleApi _scheduleApi;

  ScheduleActionsNotifier(this._scheduleApi) : super(const ScheduleActionsState());

  /// Sauvegarder la configuration des créneaux
  Future<ScheduleConfig?> saveScheduleConfig(String restaurantId, ScheduleConfig config) async {
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      final savedConfig = await _scheduleApi.saveScheduleConfig(restaurantId, config);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Configuration des créneaux sauvegardée',
      );
      return savedConfig;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Erreur lors de la sauvegarde: $e',
      );
      return null;
    }
  }

  /// Mettre à jour les créneaux d'un jour
  Future<DaySchedule?> updateDaySchedule(String restaurantId, String dayOfWeek, DaySchedule daySchedule) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedDaySchedule = await _scheduleApi.updateDaySchedule(restaurantId, dayOfWeek, daySchedule);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Créneaux du $dayOfWeek mis à jour',
      );
      return updatedDaySchedule;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour: $e',
      );
      return null;
    }
  }

  /// Ajouter un créneau horaire
  Future<TimeSlot?> addTimeSlot(String restaurantId, String dayOfWeek, TimeSlot timeSlot) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final newTimeSlot = await _scheduleApi.addTimeSlot(restaurantId, dayOfWeek, timeSlot);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Créneau horaire ajouté',
      );
      return newTimeSlot;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de l\'ajout du créneau: $e',
      );
      return null;
    }
  }

  /// Mettre à jour un créneau horaire
  Future<TimeSlot?> updateTimeSlot(String restaurantId, String dayOfWeek, String time, TimeSlot timeSlot) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedTimeSlot = await _scheduleApi.updateTimeSlot(restaurantId, dayOfWeek, time, timeSlot);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Créneau horaire mis à jour',
      );
      return updatedTimeSlot;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour du créneau: $e',
      );
      return null;
    }
  }

  /// Supprimer un créneau horaire
  Future<bool> deleteTimeSlot(String restaurantId, String dayOfWeek, String time) async {
    state = state.copyWith(isDeleting: true, error: null);
    
    try {
      await _scheduleApi.deleteTimeSlot(restaurantId, dayOfWeek, time);
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Créneau horaire supprimé',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erreur lors de la suppression: $e',
      );
      return false;
    }
  }

  /// Mettre à jour les paramètres des créneaux
  Future<TimeSlotSettings?> updateTimeSlotSettings(String restaurantId, TimeSlotSettings settings) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedSettings = await _scheduleApi.updateTimeSlotSettings(restaurantId, settings);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Paramètres mis à jour',
      );
      return updatedSettings;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour des paramètres: $e',
      );
      return null;
    }
  }

  /// Valider la configuration
  Future<Map<String, dynamic>?> validateScheduleConfig(String restaurantId, ScheduleConfig config) async {
    try {
      return await _scheduleApi.validateScheduleConfig(restaurantId, config);
    } catch (e) {
      state = state.copyWith(error: 'Erreur de validation: $e');
      return null;
    }
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
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

/// Paramètres pour les statistiques des créneaux
class ScheduleStatsParams {
  final String restaurantId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScheduleStatsParams({
    required this.restaurantId,
    this.startDate,
    this.endDate,
  });
}
