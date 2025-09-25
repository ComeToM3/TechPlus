import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/models/base_state.dart';
import '../../../../shared/errors/app_errors.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';

/// Provider pour l'état des réservations
final reservationStateProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return ReservationNotifier(apiService);
    });

/// État des réservations
class ReservationState extends BaseListState<Reservation> {
  final Reservation? selectedReservation;

  const ReservationState({
    super.items = const [],
    super.isLoading = false,
    super.error,
    this.selectedReservation,
  });

  @override
  ReservationState copyWith({
    List<Reservation>? items,
    bool? isLoading,
    String? error,
    Reservation? selectedReservation,
  }) {
    return ReservationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedReservation: selectedReservation ?? this.selectedReservation,
    );
  }
}

/// Notifier pour la gestion des réservations
class ReservationNotifier extends StateNotifier<ReservationState> {
  final ApiService _apiService;

  ReservationNotifier(this._apiService) : super(const ReservationState());

  /// Charger les réservations
  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour charger les réservations
      final reservations = await _apiService.getReservations();

      state = state.copyWith(items: reservations, isLoading: false);
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  /// Créer une réservation
  Future<void> createReservation(Reservation reservation) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour créer la réservation
      final newReservation = await _apiService.createReservation(reservation);

      state = state.copyWith(
        items: [...state.items, newReservation],
        isLoading: false,
      );
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  /// Mettre à jour une réservation
  Future<void> updateReservation(
    String id,
    Reservation updatedReservation,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour mettre à jour la réservation
      final updatedReservationFromApi = await _apiService.updateReservation(id, updatedReservation);

      final reservations = state.items.map((r) {
        return r.id == id ? updatedReservationFromApi : r;
      }).toList();

      state = state.copyWith(items: reservations, isLoading: false);
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Appeler l'API backend pour annuler la réservation
      await _apiService.cancelReservation(id);

      final reservations = state.items.map((r) {
        return r.id == id ? r.copyWith(status: 'CANCELLED') : r;
      }).toList();

      state = state.copyWith(items: reservations, isLoading: false);
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  /// Sélectionner une réservation
  void selectReservation(Reservation reservation) {
    state = state.copyWith(selectedReservation: reservation);
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}