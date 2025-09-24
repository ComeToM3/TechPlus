import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/restaurant_config_entity.dart';

/// Data source local pour la configuration du restaurant
class RestaurantConfigLocalDataSource {
  final SharedPreferences _prefs;

  const RestaurantConfigLocalDataSource(this._prefs);

  static const String _configKey = 'restaurant_config';
  static const String _openingHoursKey = 'opening_hours';
  static const String _paymentSettingsKey = 'payment_settings';
  static const String _cancellationPolicyKey = 'cancellation_policy';

  /// Sauvegarde la configuration du restaurant
  Future<void> saveRestaurantConfig(RestaurantConfig config) async {
    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  /// Récupère la configuration du restaurant
  Future<RestaurantConfig?> getRestaurantConfig() async {
    final configJson = _prefs.getString(_configKey);
    if (configJson == null) return null;
    
    try {
      return RestaurantConfig.fromJson(jsonDecode(configJson));
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les heures d'ouverture
  Future<void> saveOpeningHours(List<OpeningHours> openingHours) async {
    final json = openingHours.map((h) => h.toJson()).toList();
    await _prefs.setString(_openingHoursKey, jsonEncode(json));
  }

  /// Récupère les heures d'ouverture
  Future<List<OpeningHours>?> getOpeningHours() async {
    final hoursJson = _prefs.getString(_openingHoursKey);
    if (hoursJson == null) return null;
    
    try {
      final List<dynamic> jsonList = jsonDecode(hoursJson);
      return jsonList.map((h) => OpeningHours.fromJson(h as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les paramètres de paiement
  Future<void> savePaymentSettings(PaymentSettings paymentSettings) async {
    await _prefs.setString(_paymentSettingsKey, jsonEncode(paymentSettings.toJson()));
  }

  /// Récupère les paramètres de paiement
  Future<PaymentSettings?> getPaymentSettings() async {
    final settingsJson = _prefs.getString(_paymentSettingsKey);
    if (settingsJson == null) return null;
    
    try {
      return PaymentSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde la politique d'annulation
  Future<void> saveCancellationPolicy(CancellationPolicy cancellationPolicy) async {
    await _prefs.setString(_cancellationPolicyKey, jsonEncode(cancellationPolicy.toJson()));
  }

  /// Récupère la politique d'annulation
  Future<CancellationPolicy?> getCancellationPolicy() async {
    final policyJson = _prefs.getString(_cancellationPolicyKey);
    if (policyJson == null) return null;
    
    try {
      return CancellationPolicy.fromJson(jsonDecode(policyJson));
    } catch (e) {
      return null;
    }
  }

  /// Supprime toutes les données de configuration
  Future<void> clearAllData() async {
    await _prefs.remove(_configKey);
    await _prefs.remove(_openingHoursKey);
    await _prefs.remove(_paymentSettingsKey);
    await _prefs.remove(_cancellationPolicyKey);
  }
}

