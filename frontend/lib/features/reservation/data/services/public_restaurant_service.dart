import '../../../../core/network/api_service.dart';

/// Service pour récupérer les données publiques du restaurant
class PublicRestaurantService {
  final ApiService _apiService;

  PublicRestaurantService(this._apiService);

  /// Récupère la configuration du restaurant
  Future<Map<String, dynamic>> getRestaurantConfig() async {
    try {
      // Vérifier que l'API fonctionne en testant les créneaux
      await _apiService.getAvailableTimeSlots(DateTime.now(), 2);
      
      // Pour l'instant, retourner une configuration par défaut
      // Les vraies infos du restaurant viendront des endpoints backend
      return {
        'name': 'Restaurant TechPlus',
        'address': '123 Rue de la Paix, Paris',
        'phone': '+33 1 23 45 67 89',
        'email': 'contact@techplus.com',
        'openingHours': {
          'monday': {'open': '12:00', 'close': '22:00'},
          'tuesday': {'open': '12:00', 'close': '22:00'},
          'wednesday': {'open': '12:00', 'close': '22:00'},
          'thursday': {'open': '12:00', 'close': '22:00'},
          'friday': {'open': '12:00', 'close': '23:00'},
          'saturday': {'open': '12:00', 'close': '23:00'},
          'sunday': {'open': '12:00', 'close': '21:00'},
        },
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la configuration du restaurant: $e');
    }
  }

  /// Récupère les créneaux horaires configurés pour un jour
  Future<List<String>> getConfiguredTimeSlots(DateTime date) async {
    try {
      // Utiliser l'endpoint de disponibilité existant
      return await _apiService.getAvailableTimeSlots(date, 2);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux horaires: $e');
    }
  }

  /// Récupère toutes les tables configurées
  Future<List<Map<String, dynamic>>> getAllTables() async {
    try {
      // Pour l'instant, retourner des tables par défaut
      // TODO: Implémenter l'endpoint /api/restaurant/tables
      return [
        {'id': '1', 'number': 1, 'capacity': 2, 'isActive': true},
        {'id': '2', 'number': 2, 'capacity': 4, 'isActive': true},
        {'id': '3', 'number': 3, 'capacity': 4, 'isActive': true},
        {'id': '4', 'number': 4, 'capacity': 6, 'isActive': true},
        {'id': '5', 'number': 5, 'capacity': 8, 'isActive': true},
      ];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables: $e');
    }
  }

  /// Récupère les heures d'ouverture
  Future<Map<String, dynamic>> getOpeningHours() async {
    try {
      // Pour l'instant, retourner des heures par défaut
      // TODO: Implémenter l'endpoint /api/restaurant/opening-hours
      return {
        'monday': {'open': '12:00', 'close': '22:00'},
        'tuesday': {'open': '12:00', 'close': '22:00'},
        'wednesday': {'open': '12:00', 'close': '22:00'},
        'thursday': {'open': '12:00', 'close': '22:00'},
        'friday': {'open': '12:00', 'close': '23:00'},
        'saturday': {'open': '12:00', 'close': '23:00'},
        'sunday': {'open': '12:00', 'close': '21:00'},
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des heures d\'ouverture: $e');
    }
  }
}
