/// Configuration des environnements
class EnvironmentConfig {
  // Environnement actuel
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');
  
  // URLs de base selon l'environnement
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.techplus.com';
      case 'staging':
        return 'https://staging-api.techplus.com';
      case 'development':
      default:
        return 'http://localhost:3000';
    }
  }
  
  // Timeouts selon l'environnement
  static Duration get connectTimeout {
    switch (environment) {
      case 'production':
        return const Duration(seconds: 5);
      case 'staging':
        return const Duration(seconds: 8);
      case 'development':
      default:
        return const Duration(seconds: 10);
    }
  }
  
  static Duration get receiveTimeout {
    switch (environment) {
      case 'production':
        return const Duration(seconds: 15);
      case 'staging':
        return const Duration(seconds: 20);
      case 'development':
      default:
        return const Duration(seconds: 30);
    }
  }
  
  static Duration get sendTimeout {
    switch (environment) {
      case 'production':
        return const Duration(seconds: 10);
      case 'staging':
        return const Duration(seconds: 15);
      case 'development':
      default:
        return const Duration(seconds: 30);
    }
  }
  
  // Headers selon l'environnement
  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (environment == 'development') {
      headers['X-Debug-Mode'] = 'true';
    }
    
    return headers;
  }
  
  // Vérifier si l'API est configurée
  static bool get isConfigured {
    return baseUrl.isNotEmpty && !baseUrl.contains('your-backend-url.com');
  }
}
