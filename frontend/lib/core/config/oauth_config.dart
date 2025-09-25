/// Configuration OAuth pour l'administration
class OAuthConfig {
  // Configuration Google OAuth - Variables d'environnement
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_CLIENT_ID',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_SERVER_CLIENT_ID',
  );
  static const List<String> googleScopes = ['email', 'profile'];
  
  // Configuration Facebook OAuth - Variables d'environnement
  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: 'YOUR_FACEBOOK_APP_ID',
  );
  static const String facebookClientToken = String.fromEnvironment(
    'FACEBOOK_CLIENT_TOKEN',
    defaultValue: 'YOUR_FACEBOOK_CLIENT_TOKEN',
  );
  static const List<String> facebookPermissions = ['email', 'public_profile'];
  
  // Configuration Apple OAuth - Variables d'environnement
  static const String appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
    defaultValue: 'YOUR_APPLE_SERVICE_ID',
  );
  static const String appleTeamId = String.fromEnvironment(
    'APPLE_TEAM_ID',
    defaultValue: 'YOUR_APPLE_TEAM_ID',
  );
  static const String appleKeyId = String.fromEnvironment(
    'APPLE_KEY_ID',
    defaultValue: 'YOUR_APPLE_KEY_ID',
  );
  static const String applePrivateKey = String.fromEnvironment(
    'APPLE_PRIVATE_KEY',
    defaultValue: 'YOUR_APPLE_PRIVATE_KEY',
  );
  
  // Configuration backend - Utilise l'URL de l'API configurée
  static const String backendBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String googleAuthEndpoint = '/api/auth/google';
  static const String facebookAuthEndpoint = '/api/auth/facebook';
  static const String appleAuthEndpoint = '/api/auth/apple';
  
  // Configuration de sécurité
  static const bool enableOAuthForAdmin = true;
  static const bool enableOAuthForPublic = false; // Garder le système de tokens pour le public
  static const bool requireAdminRole = true;
  
  /// Vérifier si OAuth est configuré
  static bool get isConfigured {
    return googleClientId != 'YOUR_GOOGLE_CLIENT_ID' &&
           facebookAppId != 'YOUR_FACEBOOK_APP_ID' &&
           appleServiceId != 'YOUR_APPLE_SERVICE_ID';
  }
  
  /// Obtenir les endpoints OAuth
  static Map<String, String> get oauthEndpoints {
    return {
      'google': '$backendBaseUrl$googleAuthEndpoint',
      'facebook': '$backendBaseUrl$facebookAuthEndpoint',
      'apple': '$backendBaseUrl$appleAuthEndpoint',
    };
  }
  
  /// Obtenir la configuration Google
  static Map<String, dynamic> get googleConfig {
    return {
      'clientId': googleClientId,
      'serverClientId': googleServerClientId,
      'scopes': googleScopes,
    };
  }
  
  /// Obtenir la configuration Facebook
  static Map<String, dynamic> get facebookConfig {
    return {
      'appId': facebookAppId,
      'clientToken': facebookClientToken,
      'permissions': facebookPermissions,
    };
  }
  
  /// Obtenir la configuration Apple
  static Map<String, dynamic> get appleConfig {
    return {
      'serviceId': appleServiceId,
      'teamId': appleTeamId,
      'keyId': appleKeyId,
      'privateKey': applePrivateKey,
    };
  }
}
