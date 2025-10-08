/// Gestionnaire global pour les tokens d'authentification
/// Source unique de vérité pour l'authentification dans l'application
class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _accessToken;
  final List<Function(String?)> _listeners = [];

  /// Obtenir le token actuel
  /// En développement, retourne automatiquement 'dev-token' si aucun token n'est défini
  String? get accessToken {
    if (_accessToken == null) {
      // Token de développement utilisé par défaut
      return 'dev-token';
    }
    return _accessToken;
  }

  /// Vérifier si un token est défini (pas le token de développement)
  bool get hasRealToken => _accessToken != null;

  /// Vérifier si on utilise le token de développement
  bool get isUsingDevToken => _accessToken == null;

  /// Mettre à jour le token
  void updateToken(String? token) {
    _accessToken = token;
    // Notifier tous les listeners
    for (final listener in _listeners) {
      listener(token);
    }
  }

  /// Effacer le token
  void clearToken() {
    _accessToken = null;
    // Notifier tous les listeners
    for (final listener in _listeners) {
      listener(null);
    }
  }

  /// Ajouter un listener pour les changements de token
  void addListener(Function(String?) listener) {
    _listeners.add(listener);
  }

  /// Supprimer un listener
  void removeListener(Function(String?) listener) {
    _listeners.remove(listener);
  }
}
