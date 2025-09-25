import 'oauth_config.dart';
import 'env_loader.dart';

/// Test de configuration OAuth
class OAuthTest {
  /// Vérifier la configuration OAuth
  static Future<Map<String, bool>> testOAuthConfiguration() async {
    await EnvLoader.loadEnv();
    
    final results = <String, bool>{};
    
    // Test Google OAuth
    results['Google Client ID'] = OAuthConfig.googleClientId != 'YOUR_GOOGLE_CLIENT_ID';
    results['Google Server Client ID'] = OAuthConfig.googleServerClientId != 'YOUR_GOOGLE_SERVER_CLIENT_ID';
    
    // Test Facebook OAuth
    results['Facebook App ID'] = OAuthConfig.facebookAppId != 'YOUR_FACEBOOK_APP_ID';
    results['Facebook Client Token'] = OAuthConfig.facebookClientToken != 'YOUR_FACEBOOK_CLIENT_TOKEN';
    
    // Test Apple OAuth
    results['Apple Service ID'] = OAuthConfig.appleServiceId != 'YOUR_APPLE_SERVICE_ID';
    results['Apple Team ID'] = OAuthConfig.appleTeamId != 'YOUR_APPLE_TEAM_ID';
    results['Apple Key ID'] = OAuthConfig.appleKeyId != 'YOUR_APPLE_KEY_ID';
    results['Apple Private Key'] = OAuthConfig.applePrivateKey != 'YOUR_APPLE_PRIVATE_KEY';
    
    // Test Backend
    results['Backend URL'] = OAuthConfig.backendBaseUrl != 'https://your-backend-url.com';
    
    return results;
  }
  
  /// Afficher le statut de configuration
  static Future<void> printConfigurationStatus() async {
    print('\n🔐 Configuration OAuth - Statut:');
    print('=' * 50);
    
    final results = await testOAuthConfiguration();
    
    for (final entry in results.entries) {
      final status = entry.value ? '✅' : '❌';
      print('$status ${entry.key}');
    }
    
    final allConfigured = results.values.every((configured) => configured);
    print('\n${allConfigured ? '✅' : '❌'} Configuration OAuth: ${allConfigured ? 'COMPLÈTE' : 'INCOMPLÈTE'}');
    
    if (!allConfigured) {
      print('\n📝 Actions requises:');
      print('1. Ajouter les clés OAuth dans le fichier .env');
      print('2. Configurer les endpoints backend');
      print('3. Tester la connexion OAuth');
    }
  }
  
  /// Obtenir les clés manquantes
  static List<String> getMissingKeys() {
    final results = <String>[];
    
    if (OAuthConfig.googleClientId == 'YOUR_GOOGLE_CLIENT_ID') {
      results.add('GOOGLE_CLIENT_ID');
    }
    if (OAuthConfig.googleServerClientId == 'YOUR_GOOGLE_SERVER_CLIENT_ID') {
      results.add('GOOGLE_SERVER_CLIENT_ID');
    }
    if (OAuthConfig.facebookAppId == 'YOUR_FACEBOOK_APP_ID') {
      results.add('FACEBOOK_APP_ID');
    }
    if (OAuthConfig.facebookClientToken == 'YOUR_FACEBOOK_CLIENT_TOKEN') {
      results.add('FACEBOOK_CLIENT_TOKEN');
    }
    if (OAuthConfig.appleServiceId == 'YOUR_APPLE_SERVICE_ID') {
      results.add('APPLE_SERVICE_ID');
    }
    if (OAuthConfig.appleTeamId == 'YOUR_APPLE_TEAM_ID') {
      results.add('APPLE_TEAM_ID');
    }
    if (OAuthConfig.appleKeyId == 'YOUR_APPLE_KEY_ID') {
      results.add('APPLE_KEY_ID');
    }
    if (OAuthConfig.applePrivateKey == 'YOUR_APPLE_PRIVATE_KEY') {
      results.add('APPLE_PRIVATE_KEY');
    }
    
    return results;
  }
}
