import '../../domain/entities/restaurant_config_entity.dart';
import '../../domain/repositories/restaurant_config_repository.dart';
import '../datasources/restaurant_config_remote_datasource.dart';
import '../datasources/restaurant_config_local_datasource.dart';

/// Implémentation du repository pour la configuration du restaurant
class RestaurantConfigRepositoryImpl implements RestaurantConfigRepository {
  final RestaurantConfigRemoteDataSource _remoteDataSource;
  final RestaurantConfigLocalDataSource _localDataSource;

  const RestaurantConfigRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<RestaurantConfig> getRestaurantConfig() async {
    try {
      // Essayer de récupérer depuis le cache local d'abord
      final cachedConfig = await _localDataSource.getRestaurantConfig();
      if (cachedConfig != null) {
        // Récupérer depuis l'API en arrière-plan pour mettre à jour le cache
        _remoteDataSource.getRestaurantConfig().then((config) {
          _localDataSource.saveRestaurantConfig(config);
        }).catchError((_) {
          // Ignorer les erreurs de mise à jour en arrière-plan
        });
        return cachedConfig;
      }

      // Si pas de cache, récupérer depuis l'API
      final config = await _remoteDataSource.getRestaurantConfig();
      await _localDataSource.saveRestaurantConfig(config);
      return config;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner le cache
      final cachedConfig = await _localDataSource.getRestaurantConfig();
      if (cachedConfig != null) {
        return cachedConfig;
      }
      rethrow;
    }
  }

  @override
  Future<RestaurantConfig> updateRestaurantConfig(UpdateRestaurantConfigRequest request) async {
    try {
      final config = await _remoteDataSource.updateRestaurantConfig(request);
      await _localDataSource.saveRestaurantConfig(config);
      return config;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OpeningHours>> getOpeningHours() async {
    try {
      // Essayer de récupérer depuis le cache local d'abord
      final cachedHours = await _localDataSource.getOpeningHours();
      if (cachedHours != null) {
        // Récupérer depuis l'API en arrière-plan pour mettre à jour le cache
        _remoteDataSource.getOpeningHours().then((hours) {
          _localDataSource.saveOpeningHours(hours);
        }).catchError((_) {
          // Ignorer les erreurs de mise à jour en arrière-plan
        });
        return cachedHours;
      }

      // Si pas de cache, récupérer depuis l'API
      final hours = await _remoteDataSource.getOpeningHours();
      await _localDataSource.saveOpeningHours(hours);
      return hours;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner le cache
      final cachedHours = await _localDataSource.getOpeningHours();
      if (cachedHours != null) {
        return cachedHours;
      }
      rethrow;
    }
  }

  @override
  Future<List<OpeningHours>> updateOpeningHours(List<OpeningHours> openingHours) async {
    try {
      final hours = await _remoteDataSource.updateOpeningHours(openingHours);
      await _localDataSource.saveOpeningHours(hours);
      return hours;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      // Essayer de récupérer depuis le cache local d'abord
      final cachedSettings = await _localDataSource.getPaymentSettings();
      if (cachedSettings != null) {
        // Récupérer depuis l'API en arrière-plan pour mettre à jour le cache
        _remoteDataSource.getPaymentSettings().then((settings) {
          _localDataSource.savePaymentSettings(settings);
        }).catchError((_) {
          // Ignorer les erreurs de mise à jour en arrière-plan
        });
        return cachedSettings;
      }

      // Si pas de cache, récupérer depuis l'API
      final settings = await _remoteDataSource.getPaymentSettings();
      await _localDataSource.savePaymentSettings(settings);
      return settings;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner le cache
      final cachedSettings = await _localDataSource.getPaymentSettings();
      if (cachedSettings != null) {
        return cachedSettings;
      }
      rethrow;
    }
  }

  @override
  Future<PaymentSettings> updatePaymentSettings(PaymentSettings paymentSettings) async {
    try {
      final settings = await _remoteDataSource.updatePaymentSettings(paymentSettings);
      await _localDataSource.savePaymentSettings(settings);
      return settings;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CancellationPolicy> getCancellationPolicy() async {
    try {
      // Essayer de récupérer depuis le cache local d'abord
      final cachedPolicy = await _localDataSource.getCancellationPolicy();
      if (cachedPolicy != null) {
        // Récupérer depuis l'API en arrière-plan pour mettre à jour le cache
        _remoteDataSource.getCancellationPolicy().then((policy) {
          _localDataSource.saveCancellationPolicy(policy);
        }).catchError((_) {
          // Ignorer les erreurs de mise à jour en arrière-plan
        });
        return cachedPolicy;
      }

      // Si pas de cache, récupérer depuis l'API
      final policy = await _remoteDataSource.getCancellationPolicy();
      await _localDataSource.saveCancellationPolicy(policy);
      return policy;
    } catch (e) {
      // En cas d'erreur réseau, essayer de retourner le cache
      final cachedPolicy = await _localDataSource.getCancellationPolicy();
      if (cachedPolicy != null) {
        return cachedPolicy;
      }
      rethrow;
    }
  }

  @override
  Future<CancellationPolicy> updateCancellationPolicy(CancellationPolicy cancellationPolicy) async {
    try {
      final policy = await _remoteDataSource.updateCancellationPolicy(cancellationPolicy);
      await _localDataSource.saveCancellationPolicy(policy);
      return policy;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadImage(String imagePath, String type) async {
    try {
      return await _remoteDataSource.uploadImage(imagePath, type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _remoteDataSource.deleteImage(imageUrl);
    } catch (e) {
      rethrow;
    }
  }
}

