import '../../../../core/network/api_service.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/errors/contextual_errors.dart';

/// Service pour la gestion des réservations publiques
class PublicReservationService {
  final ApiService _apiService;

  PublicReservationService(this._apiService);

  /// Obtenir les créneaux disponibles pour une date et un nombre de personnes
  Future<List<String>> getAvailableTimeSlots(DateTime date, int partySize) async {
    try {
      return await _apiService.getAvailableTimeSlots(date, partySize);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'availability_error',
        message: 'Erreur lors de la récupération des créneaux: $e',
      );
    }
  }

  /// Obtenir les tables disponibles pour une date, heure et nombre de personnes
  Future<List<Map<String, dynamic>>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      // Pour l'instant, retournons des tables simulées
      // TODO: Implémenter l'API réelle
      return [
        {'id': 'table_1', 'number': 1, 'capacity': 2},
        {'id': 'table_2', 'number': 2, 'capacity': 4},
        {'id': 'table_3', 'number': 3, 'capacity': 6},
        {'id': 'table_4', 'number': 4, 'capacity': 8},
      ];
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'tables_error',
        message: 'Erreur lors de la récupération des tables: $e',
      );
    }
  }

  /// Vérifier la disponibilité d'un créneau spécifique
  Future<bool> checkSlotAvailability({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      // Pour l'instant, retournons toujours true
      // TODO: Implémenter la vérification réelle
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Créer une réservation publique (sans authentification)
  Future<Reservation> createPublicReservation(Reservation reservation) async {
    try {
      final result = await _apiService.createPublicReservation(
        date: reservation.date,
        time: reservation.time,
        partySize: reservation.partySize,
        clientName: reservation.clientName ?? '',
        clientEmail: reservation.clientEmail ?? '',
        clientPhone: reservation.clientPhone ?? '',
        specialRequests: reservation.specialRequests,
        tableId: reservation.tableId,
      );
      
      // Convertir le résultat en objet Reservation
      return Reservation(
        id: result['id'] ?? '',
        date: DateTime.parse(result['date']),
        time: result['time'] ?? '',
        duration: result['duration'] ?? 90,
        partySize: result['partySize'] ?? 2,
        status: result['status'] ?? 'PENDING',
        clientName: result['clientName'],
        clientEmail: result['clientEmail'],
        clientPhone: result['clientPhone'],
        specialRequests: result['specialRequests'],
        restaurantId: result['restaurantId'] ?? '',
        tableId: result['tableId'],
      );
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'create_reservation_error',
        message: 'Erreur de création: $e',
      );
    }
  }

  /// Obtenir une réservation par ID
  Future<Reservation> getReservation(String id) async {
    try {
      return await _apiService.getReservation(id);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'get_reservation_error',
        message: 'Erreur de récupération: $e',
      );
    }
  }

  /// Modifier une réservation avec token de gestion
  Future<Reservation> updateReservationWithToken(String token, Reservation reservation) async {
    try {
      return await _apiService.updateReservationWithToken(token, reservation);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'update_reservation_error',
        message: 'Erreur de modification: $e',
      );
    }
  }

  /// Annuler une réservation avec token de gestion
  Future<void> cancelReservationWithToken(String token, {String? reason}) async {
    try {
      await _apiService.cancelReservationWithToken(token, reason: reason);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'cancel_reservation_error',
        message: 'Erreur d\'annulation: $e',
      );
    }
  }

  /// Valider un token de gestion
  Future<Reservation> validateManagementToken(String token) async {
    try {
      return await _apiService.validateGuestToken(token);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'token_validation_error',
        message: 'Token invalide ou expiré: $e',
      );
    }
  }

  /// Envoyer un email de confirmation
  Future<void> sendConfirmationEmail({
    required String reservationId,
    required String clientEmail,
  }) async {
    try {
      await _apiService.sendConfirmationEmail(
        reservationId: reservationId,
        clientEmail: clientEmail,
      );
    } catch (e) {
      // Ne pas propager l'erreur pour les emails
      // L'email est optionnel
    }
  }
}