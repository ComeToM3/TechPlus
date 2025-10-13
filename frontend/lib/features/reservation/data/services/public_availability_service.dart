import '../../../../core/network/api_service.dart';

/// Service pour récupérer les disponibilités publiques basées sur la configuration
class PublicAvailabilityService {
  final ApiService _apiService;

  PublicAvailabilityService(this._apiService);

  /// Récupère les créneaux disponibles basés sur la configuration du restaurant
  Future<List<String>> getAvailableTimeSlots({
    required DateTime date,
    required int partySize,
  }) async {
    try {
      return await _apiService.getAvailableTimeSlots(date, partySize);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux disponibles: $e');
    }
  }

  /// Récupère les tables disponibles pour un créneau spécifique
  Future<List<Map<String, dynamic>>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      return await _apiService.getAvailableTables(
        date: date,
        time: time,
        partySize: partySize,
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables disponibles: $e');
    }
  }

  /// Vérifie la disponibilité d'un créneau spécifique
  Future<bool> checkSlotAvailability({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      // Pour l'instant, utiliser la logique existante
      final tables = await _apiService.getAvailableTables(
        date: date,
        time: time,
        partySize: partySize,
      );
      return tables.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de disponibilité: $e');
    }
  }

  /// Récupère les informations du restaurant (nom, adresse, etc.)
  Future<Map<String, dynamic>> getRestaurantInfo() async {
    try {
      // Utiliser l'endpoint de disponibilité pour récupérer les infos du restaurant
      final timeSlots = await _apiService.getAvailableTimeSlots(DateTime.now(), 2);
      
      // Pour l'instant, retourner des informations par défaut
      // Les vraies infos du restaurant viendront des endpoints backend
      return {
        'name': 'Restaurant TechPlus',
        'address': '123 Rue de la Paix, Paris',
        'phone': '+33 1 23 45 67 89',
        'email': 'contact@techplus.com',
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des informations du restaurant: $e');
    }
  }
}
