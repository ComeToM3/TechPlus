import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/errors/app_errors.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';

/// État pour la gestion des réservations par les guests
class GuestManagementState {
  final String? token;
  final String? reservationId;
  final bool isLoading;
  final bool isTokenValid;
  final bool isReservationLoaded;
  final String? error;
  
  // Données de la réservation
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final DateTime? reservationDate;
  final String? reservationTime;
  final int? partySize;
  final String? specialRequests;
  final String? status;
  final double? depositAmount;
  final bool? isPaymentCompleted;
  final Map<String, dynamic>? reservationDetails;
  
  // Actions disponibles
  final bool canModify;
  final bool canCancel;
  final String? cancellationPolicy;

  GuestManagementState({
    this.token,
    this.reservationId,
    this.isLoading = false,
    this.isTokenValid = false,
    this.isReservationLoaded = false,
    this.error,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.reservationDate,
    this.reservationTime,
    this.partySize,
    this.specialRequests,
    this.status,
    this.depositAmount,
    this.isPaymentCompleted,
    this.reservationDetails,
    this.canModify = false,
    this.canCancel = false,
    this.cancellationPolicy,
  });

  GuestManagementState copyWith({
    String? token,
    String? reservationId,
    bool? isLoading,
    bool? isTokenValid,
    bool? isReservationLoaded,
    String? error,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? reservationDate,
    String? reservationTime,
    int? partySize,
    String? specialRequests,
    String? status,
    double? depositAmount,
    bool? isPaymentCompleted,
    Map<String, dynamic>? reservationDetails,
    bool? canModify,
    bool? canCancel,
    String? cancellationPolicy,
  }) {
    return GuestManagementState(
      token: token ?? this.token,
      reservationId: reservationId ?? this.reservationId,
      isLoading: isLoading ?? this.isLoading,
      isTokenValid: isTokenValid ?? this.isTokenValid,
      isReservationLoaded: isReservationLoaded ?? this.isReservationLoaded,
      error: error,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      reservationDate: reservationDate ?? this.reservationDate,
      reservationTime: reservationTime ?? this.reservationTime,
      partySize: partySize ?? this.partySize,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      depositAmount: depositAmount ?? this.depositAmount,
      isPaymentCompleted: isPaymentCompleted ?? this.isPaymentCompleted,
      reservationDetails: reservationDetails ?? this.reservationDetails,
      canModify: canModify ?? this.canModify,
      canCancel: canCancel ?? this.canCancel,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
    );
  }

  bool get hasValidToken => token != null && token!.isNotEmpty;
  bool get hasReservationData => isReservationLoaded && reservationId != null;
  bool get canPerformActions => hasValidToken && hasReservationData && !isLoading;
}

/// Notifier pour gérer les réservations des guests
class GuestManagementNotifier extends StateNotifier<GuestManagementState> {
  final ApiService _apiService;

  GuestManagementNotifier(this._apiService) : super(GuestManagementState());

  /// Valider un token et charger les données de réservation
  Future<void> validateTokenAndLoadReservation(String token) async {
    if (token.trim().isEmpty) {
      state = state.copyWith(
        error: 'Veuillez saisir un token valide',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      token: token.trim(),
      isLoading: true,
      error: null,
    );

    try {
      // Appeler l'API backend pour valider le token
      final reservation = await _apiService.validateGuestToken(token);
      
      state = state.copyWith(
        isLoading: false,
        isTokenValid: true,
        isReservationLoaded: true,
        reservationId: reservation.id,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isTokenValid: false,
        error: 'Token invalide ou expiré',
      );
    }
  }


  /// Modifier une réservation
  Future<void> modifyReservation({
    DateTime? newDate,
    String? newTime,
    int? newPartySize,
    String? newSpecialRequests,
    String? newName,
    String? newEmail,
    String? newPhone,
  }) async {
    if (!state.canModify) {
      state = state.copyWith(
        error: 'Cette réservation ne peut pas être modifiée',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // Créer un objet Reservation avec les nouvelles données
      final updatedReservation = Reservation(
        id: state.reservationId!,
        date: newDate ?? state.reservationDate!,
        time: newTime ?? state.reservationTime!,
        duration: 90, // Durée par défaut
        partySize: newPartySize ?? state.partySize!,
        specialRequests: newSpecialRequests ?? state.specialRequests,
        clientName: newName ?? state.clientName,
        clientEmail: newEmail ?? state.clientEmail,
        clientPhone: newPhone ?? state.clientPhone,
        status: state.status!,
        restaurantId: 'restaurant_1', // À récupérer depuis l'état
      );

      // Appeler l'API backend pour modifier la réservation
      await _apiService.updateReservationWithToken(state.token!, updatedReservation);
      
      // Mettre à jour l'état local
      state = state.copyWith(
        isLoading: false,
        reservationDate: newDate ?? state.reservationDate,
        reservationTime: newTime ?? state.reservationTime,
        partySize: newPartySize ?? state.partySize,
        specialRequests: newSpecialRequests ?? state.specialRequests,
        clientName: newName ?? state.clientName,
        clientEmail: newEmail ?? state.clientEmail,
        clientPhone: newPhone ?? state.clientPhone,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la modification: $e',
      );
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation({String? reason}) async {
    if (!state.canCancel) {
      state = state.copyWith(
        error: 'Cette réservation ne peut pas être annulée',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      // Appeler l'API backend pour annuler la réservation
      await _apiService.cancelReservationWithToken(state.token!, reason: reason);
      
      // Mettre à jour le statut
      state = state.copyWith(
        isLoading: false,
        status: 'CANCELLED',
        canModify: false,
        canCancel: false,
        error: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'annulation: $e',
      );
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = GuestManagementState();
  }


  /// Obtenir le statut formaté
  String getFormattedStatus() {
    switch (state.status) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmée';
      case 'CANCELLED':
        return 'Annulée';
      case 'COMPLETED':
        return 'Terminée';
      case 'NO_SHOW':
        return 'Absence';
      default:
        return 'Inconnu';
    }
  }

  /// Obtenir la couleur du statut
  String getStatusColor() {
    switch (state.status) {
      case 'PENDING':
        return 'orange';
      case 'CONFIRMED':
        return 'green';
      case 'CANCELLED':
        return 'red';
      case 'COMPLETED':
        return 'blue';
      case 'NO_SHOW':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Vérifier si la réservation peut être modifiée
  bool canModifyReservation() {
    if (!state.canModify) return false;
    if (state.status != 'CONFIRMED') return false;
    if (state.reservationDate == null) return false;
    
    // Vérifier si la réservation est dans plus de 24h
    final now = DateTime.now();
    final reservationDateTime = DateTime(
      state.reservationDate!.year,
      state.reservationDate!.month,
      state.reservationDate!.day,
    );
    
    final hoursUntilReservation = reservationDateTime.difference(now).inHours;
    return hoursUntilReservation > 24;
  }

  /// Vérifier si la réservation peut être annulée
  bool canCancelReservation() {
    if (!state.canCancel) return false;
    if (state.status != 'CONFIRMED') return false;
    if (state.reservationDate == null) return false;
    
    // Vérifier si la réservation est dans plus de 24h
    final now = DateTime.now();
    final reservationDateTime = DateTime(
      state.reservationDate!.year,
      state.reservationDate!.month,
      state.reservationDate!.day,
    );
    
    final hoursUntilReservation = reservationDateTime.difference(now).inHours;
    return hoursUntilReservation > 24;
  }
}

/// Provider pour la gestion des réservations des guests
final guestManagementProvider = StateNotifierProvider<GuestManagementNotifier, GuestManagementState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GuestManagementNotifier(apiService);
});
