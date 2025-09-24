import '../entities/restaurant_config_entity.dart';

/// Repository pour la configuration du restaurant
abstract class RestaurantConfigRepository {
  /// Récupère la configuration actuelle du restaurant
  Future<RestaurantConfig> getRestaurantConfig();

  /// Met à jour la configuration du restaurant
  Future<RestaurantConfig> updateRestaurantConfig(UpdateRestaurantConfigRequest request);

  /// Récupère les heures d'ouverture
  Future<List<OpeningHours>> getOpeningHours();

  /// Met à jour les heures d'ouverture
  Future<List<OpeningHours>> updateOpeningHours(List<OpeningHours> openingHours);

  /// Récupère les paramètres de paiement
  Future<PaymentSettings> getPaymentSettings();

  /// Met à jour les paramètres de paiement
  Future<PaymentSettings> updatePaymentSettings(PaymentSettings paymentSettings);

  /// Récupère la politique d'annulation
  Future<CancellationPolicy> getCancellationPolicy();

  /// Met à jour la politique d'annulation
  Future<CancellationPolicy> updateCancellationPolicy(CancellationPolicy cancellationPolicy);

  /// Upload une image (logo ou couverture)
  Future<String> uploadImage(String imagePath, String type);

  /// Supprime une image
  Future<void> deleteImage(String imageUrl);
}

