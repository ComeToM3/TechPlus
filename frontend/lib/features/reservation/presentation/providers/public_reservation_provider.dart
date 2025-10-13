import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/public_reservation_service.dart';
import '../../../../core/network/api_service_provider.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/errors/contextual_errors.dart';

/// État des réservations publiques
class PublicReservationState {
  final bool isLoading;
  final String? error;
  final List<String> availableTimes;
  final List<Map<String, dynamic>> availableTables;
  final Reservation? currentReservation;
  final bool isCreating;
  final String? creationError;

  const PublicReservationState({
    this.isLoading = false,
    this.error,
    this.availableTimes = const [],
    this.availableTables = const [],
    this.currentReservation,
    this.isCreating = false,
    this.creationError,
  });

  PublicReservationState copyWith({
    bool? isLoading,
    String? error,
    List<String>? availableTimes,
    List<Map<String, dynamic>>? availableTables,
    Reservation? currentReservation,
    bool? isCreating,
    String? creationError,
  }) {
    return PublicReservationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableTimes: availableTimes ?? this.availableTimes,
      availableTables: availableTables ?? this.availableTables,
      currentReservation: currentReservation ?? this.currentReservation,
      isCreating: isCreating ?? this.isCreating,
      creationError: creationError,
    );
  }
}

/// Provider pour le service de réservation publique
final publicReservationServiceProvider = Provider<PublicReservationService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PublicReservationService(apiService);
});

/// Provider pour l'état des réservations publiques
final publicReservationProvider = StateNotifierProvider<PublicReservationNotifier, PublicReservationState>((ref) {
  final service = ref.read(publicReservationServiceProvider);
  return PublicReservationNotifier(service);
});

/// Notifier pour gérer l'état des réservations publiques
class PublicReservationNotifier extends StateNotifier<PublicReservationState> {
  final PublicReservationService _service;

  PublicReservationNotifier(this._service) : super(const PublicReservationState());

  /// Charger les créneaux disponibles
  Future<void> loadAvailableTimes(DateTime date, int partySize) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final times = await _service.getAvailableTimeSlots(date, partySize);
      state = state.copyWith(
        availableTimes: times,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Charger les tables disponibles
  Future<void> loadAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tables = await _service.getAvailableTables(
        date: date,
        time: time,
        partySize: partySize,
      );
      state = state.copyWith(
        availableTables: tables,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Vérifier la disponibilité d'un créneau
  Future<bool> checkSlotAvailability({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      return await _service.checkSlotAvailability(
        date: date,
        time: time,
        partySize: partySize,
      );
    } catch (e) {
      return false;
    }
  }

  /// Créer une réservation publique
  Future<Reservation?> createPublicReservation(Reservation reservation) async {
    state = state.copyWith(isCreating: true, creationError: null);

    try {
      final createdReservation = await _service.createPublicReservation(reservation);
      
      // Envoyer l'email de confirmation si possible
      if (reservation.clientEmail != null) {
        try {
          await _service.sendConfirmationEmail(
            reservationId: createdReservation.id,
            clientEmail: reservation.clientEmail!,
          );
        } catch (e) {
          // L'email est optionnel, ne pas faire échouer la réservation
        }
      }

      state = state.copyWith(
        currentReservation: createdReservation,
        isCreating: false,
      );

      return createdReservation;
    } catch (e) {
      state = state.copyWith(
        creationError: e.toString(),
        isCreating: false,
      );
      return null;
    }
  }

  /// Charger une réservation par ID
  Future<void> loadReservation(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reservation = await _service.getReservation(id);
      state = state.copyWith(
        currentReservation: reservation,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Modifier une réservation avec token
  Future<Reservation?> updateReservationWithToken(String token, Reservation reservation) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedReservation = await _service.updateReservationWithToken(token, reservation);
      state = state.copyWith(
        currentReservation: updatedReservation,
        isLoading: false,
      );
      return updatedReservation;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  /// Annuler une réservation avec token
  Future<bool> cancelReservationWithToken(String token, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.cancelReservationWithToken(token, reason: reason);
      state = state.copyWith(
        currentReservation: null,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Valider un token de gestion
  Future<Reservation?> validateManagementToken(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reservation = await _service.validateManagementToken(token);
      state = state.copyWith(
        currentReservation: reservation,
        isLoading: false,
      );
      return reservation;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const PublicReservationState();
  }

  /// Effacer les erreurs
  void clearErrors() {
    state = state.copyWith(
      error: null,
      creationError: null,
    );
  }
}
