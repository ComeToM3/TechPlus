import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import '../../domain/repositories/restaurant_config_repository.dart';
import '../../data/repositories/restaurant_config_repository_impl.dart';
import '../../data/datasources/restaurant_config_remote_datasource.dart';
import '../../data/datasources/restaurant_config_local_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection_container.dart';

/// Provider pour le repository de configuration du restaurant
final restaurantConfigRepositoryProvider = Provider<RestaurantConfigRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);
  
  return sharedPreferencesAsync.when(
    data: (sharedPreferences) => RestaurantConfigRepositoryImpl(
      RestaurantConfigRemoteDataSource(apiClient),
      RestaurantConfigLocalDataSource(sharedPreferences),
    ),
    loading: () => throw Exception('SharedPreferences not available'),
    error: (error, stack) => throw Exception('SharedPreferences error: $error'),
  );
});

/// Provider pour la configuration du restaurant
final restaurantConfigProvider = FutureProvider<RestaurantConfig>((ref) async {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return await repository.getRestaurantConfig();
});

/// Provider pour les heures d'ouverture
final openingHoursProvider = FutureProvider<List<OpeningHours>>((ref) async {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return await repository.getOpeningHours();
});

/// Provider pour les paramètres de paiement
final paymentSettingsProvider = FutureProvider<PaymentSettings>((ref) async {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return await repository.getPaymentSettings();
});

/// Provider pour la politique d'annulation
final cancellationPolicyProvider = FutureProvider<CancellationPolicy>((ref) async {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return await repository.getCancellationPolicy();
});

/// Notifier pour la gestion de la configuration du restaurant
class RestaurantConfigNotifier extends StateNotifier<AsyncValue<RestaurantConfig>> {
  final RestaurantConfigRepository _repository;

  RestaurantConfigNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadConfig();
  }

  /// Charge la configuration
  Future<void> _loadConfig() async {
    try {
      state = const AsyncValue.loading();
      final config = await _repository.getRestaurantConfig();
      state = AsyncValue.data(config);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Met à jour la configuration
  Future<void> updateConfig(UpdateRestaurantConfigRequest request) async {
    try {
      state = const AsyncValue.loading();
      final config = await _repository.updateRestaurantConfig(request);
      state = AsyncValue.data(config);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit la configuration
  Future<void> refresh() async {
    await _loadConfig();
  }
}

/// Provider pour le notifier de configuration
final restaurantConfigNotifierProvider = StateNotifierProvider<RestaurantConfigNotifier, AsyncValue<RestaurantConfig>>((ref) {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return RestaurantConfigNotifier(repository);
});

/// Notifier pour la gestion des heures d'ouverture
class OpeningHoursNotifier extends StateNotifier<AsyncValue<List<OpeningHours>>> {
  final RestaurantConfigRepository _repository;

  OpeningHoursNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadOpeningHours();
  }

  /// Charge les heures d'ouverture
  Future<void> _loadOpeningHours() async {
    try {
      state = const AsyncValue.loading();
      final hours = await _repository.getOpeningHours();
      state = AsyncValue.data(hours);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Met à jour les heures d'ouverture
  Future<void> updateOpeningHours(List<OpeningHours> openingHours) async {
    try {
      state = const AsyncValue.loading();
      final hours = await _repository.updateOpeningHours(openingHours);
      state = AsyncValue.data(hours);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit les heures d'ouverture
  Future<void> refresh() async {
    await _loadOpeningHours();
  }
}

/// Provider pour le notifier des heures d'ouverture
final openingHoursNotifierProvider = StateNotifierProvider<OpeningHoursNotifier, AsyncValue<List<OpeningHours>>>((ref) {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return OpeningHoursNotifier(repository);
});

/// Notifier pour la gestion des paramètres de paiement
class PaymentSettingsNotifier extends StateNotifier<AsyncValue<PaymentSettings>> {
  final RestaurantConfigRepository _repository;

  PaymentSettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadPaymentSettings();
  }

  /// Charge les paramètres de paiement
  Future<void> _loadPaymentSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _repository.getPaymentSettings();
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Met à jour les paramètres de paiement
  Future<void> updatePaymentSettings(PaymentSettings paymentSettings) async {
    try {
      state = const AsyncValue.loading();
      final settings = await _repository.updatePaymentSettings(paymentSettings);
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit les paramètres de paiement
  Future<void> refresh() async {
    await _loadPaymentSettings();
  }
}

/// Provider pour le notifier des paramètres de paiement
final paymentSettingsNotifierProvider = StateNotifierProvider<PaymentSettingsNotifier, AsyncValue<PaymentSettings>>((ref) {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return PaymentSettingsNotifier(repository);
});

/// Notifier pour la gestion de la politique d'annulation
class CancellationPolicyNotifier extends StateNotifier<AsyncValue<CancellationPolicy>> {
  final RestaurantConfigRepository _repository;

  CancellationPolicyNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCancellationPolicy();
  }

  /// Charge la politique d'annulation
  Future<void> _loadCancellationPolicy() async {
    try {
      state = const AsyncValue.loading();
      final policy = await _repository.getCancellationPolicy();
      state = AsyncValue.data(policy);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Met à jour la politique d'annulation
  Future<void> updateCancellationPolicy(CancellationPolicy cancellationPolicy) async {
    try {
      state = const AsyncValue.loading();
      final policy = await _repository.updateCancellationPolicy(cancellationPolicy);
      state = AsyncValue.data(policy);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit la politique d'annulation
  Future<void> refresh() async {
    await _loadCancellationPolicy();
  }
}

/// Provider pour le notifier de la politique d'annulation
final cancellationPolicyNotifierProvider = StateNotifierProvider<CancellationPolicyNotifier, AsyncValue<CancellationPolicy>>((ref) {
  final repository = ref.watch(restaurantConfigRepositoryProvider);
  return CancellationPolicyNotifier(repository);
});
