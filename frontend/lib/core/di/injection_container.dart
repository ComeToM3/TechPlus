// Container d'injection de dépendances
// Les providers sont maintenant gérés dans shared/providers/core_providers.dart

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
