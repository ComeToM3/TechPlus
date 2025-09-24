import '../../../../core/network/api_client.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import 'package:dio/dio.dart';

/// Data source distant pour la configuration du restaurant
class RestaurantConfigRemoteDataSource {
  final ApiClient _apiClient;

  const RestaurantConfigRemoteDataSource(this._apiClient);

  /// Récupère la configuration actuelle du restaurant
  Future<RestaurantConfig> getRestaurantConfig() async {
    try {
      final response = await _apiClient.get('/api/restaurant/config');
      return RestaurantConfig.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la configuration: $e');
    }
  }

  /// Met à jour la configuration du restaurant
  Future<RestaurantConfig> updateRestaurantConfig(UpdateRestaurantConfigRequest request) async {
    try {
      final response = await _apiClient.put(
        '/api/restaurant/config',
        data: request.toJson(),
      );
      return RestaurantConfig.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la configuration: $e');
    }
  }

  /// Récupère les heures d'ouverture
  Future<List<OpeningHours>> getOpeningHours() async {
    try {
      final response = await _apiClient.get('/api/restaurant/opening-hours');
      return (response.data as List)
          .map((h) => OpeningHours.fromJson(h as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des heures d\'ouverture: $e');
    }
  }

  /// Met à jour les heures d'ouverture
  Future<List<OpeningHours>> updateOpeningHours(List<OpeningHours> openingHours) async {
    try {
      final response = await _apiClient.put(
        '/api/restaurant/opening-hours',
        data: openingHours.map((h) => h.toJson()).toList(),
      );
      return (response.data as List)
          .map((h) => OpeningHours.fromJson(h as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des heures d\'ouverture: $e');
    }
  }

  /// Récupère les paramètres de paiement
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      final response = await _apiClient.get('/api/restaurant/payment-settings');
      return PaymentSettings.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des paramètres de paiement: $e');
    }
  }

  /// Met à jour les paramètres de paiement
  Future<PaymentSettings> updatePaymentSettings(PaymentSettings paymentSettings) async {
    try {
      final response = await _apiClient.put(
        '/api/restaurant/payment-settings',
        data: paymentSettings.toJson(),
      );
      return PaymentSettings.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des paramètres de paiement: $e');
    }
  }

  /// Récupère la politique d'annulation
  Future<CancellationPolicy> getCancellationPolicy() async {
    try {
      final response = await _apiClient.get('/api/restaurant/cancellation-policy');
      return CancellationPolicy.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la politique d\'annulation: $e');
    }
  }

  /// Met à jour la politique d'annulation
  Future<CancellationPolicy> updateCancellationPolicy(CancellationPolicy cancellationPolicy) async {
    try {
      final response = await _apiClient.put(
        '/api/restaurant/cancellation-policy',
        data: cancellationPolicy.toJson(),
      );
      return CancellationPolicy.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la politique d\'annulation: $e');
    }
  }

  /// Upload une image (logo ou couverture)
  Future<String> uploadImage(String imagePath, String type) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'type': type,
      });
      
      final response = await _apiClient.post(
        '/api/restaurant/upload-image',
        data: formData,
      );
      return response.data['imageUrl'] as String;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Supprime une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _apiClient.delete('/api/restaurant/delete-image', data: {'imageUrl': imageUrl});
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }
}
