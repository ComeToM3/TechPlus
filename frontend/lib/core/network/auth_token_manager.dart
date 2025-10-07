/// Gestionnaire global pour les tokens d'authentification
class AuthTokenManager {
  static final AuthTokenManager _instance = AuthTokenManager._internal();
  factory AuthTokenManager() => _instance;
  AuthTokenManager._internal();

  String? _accessToken;
  final List<Function(String?)> _listeners = [];

  /// Obtenir le token actuel
  String? get accessToken {
    // Solution temporaire pour le développement - retourner un token de développement
    if (_accessToken == null) {
      print('🔧 [AuthTokenManager] Utilisation du token de développement');
      return 'dev-token';
    }
    return _accessToken;
  }

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
