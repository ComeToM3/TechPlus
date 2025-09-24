import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// Container d'injection de dépendances
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  
  factory InjectionContainer() => _instance;
  
  InjectionContainer._internal();
  
  /// Initialiser les dépendances
  Future<void> init() async {
    // Les providers Riverpod s'initialisent automatiquement
  }
  
  /// Nettoyer les dépendances
  Future<void> dispose() async {
    // Nettoyage si nécessaire
  }
}
