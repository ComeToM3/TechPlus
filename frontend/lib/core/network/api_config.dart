class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  
  // Configuration pour différents environnements
  static const String developmentUrl = 'http://localhost:3000';
  static const String productionUrl = 'https://api.techplus.com';
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
