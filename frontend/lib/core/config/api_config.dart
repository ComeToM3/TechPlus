import 'environment_config.dart';

/// Configuration de l'API backend
class ApiConfig {
  // URL de base de l'API backend (dynamique selon l'environnement)
  static String get baseUrl => EnvironmentConfig.baseUrl;
  
  // Timeouts (dynamiques selon l'environnement)
  static Duration get connectTimeout => EnvironmentConfig.connectTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;
  static Duration get sendTimeout => EnvironmentConfig.sendTimeout;
  
  // Endpoints
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authToken = '/api/auth/token';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  
  static const String reservations = '/api/reservations';
  static const String reservationsManage = '/api/reservations/manage';
  
  static const String availability = '/api/availability';
  
  static const String paymentsCreateIntent = '/api/payments/create-intent';
  static const String paymentsConfirm = '/api/payments/confirm';
  static const String paymentsRefund = '/api/payments/refund';
  
  // Headers (dynamiques selon l'environnement)
  static Map<String, String> get defaultHeaders => EnvironmentConfig.headers;
  
  /// Vérifier si l'API est configurée
  static bool get isConfigured => EnvironmentConfig.isConfigured;
  
  /// Obtenir l'URL complète pour un endpoint
  static String getEndpoint(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Obtenir tous les endpoints
  static Map<String, String> get allEndpoints {
    return {
      'authLogin': getEndpoint(authLogin),
      'authRegister': getEndpoint(authRegister),
      'authToken': getEndpoint(authToken),
      'authRefresh': getEndpoint(authRefresh),
      'authLogout': getEndpoint(authLogout),
      'reservations': getEndpoint(reservations),
      'reservationsManage': getEndpoint(reservationsManage),
      'availability': getEndpoint(availability),
      'paymentsCreateIntent': getEndpoint(paymentsCreateIntent),
      'paymentsConfirm': getEndpoint(paymentsConfirm),
      'paymentsRefund': getEndpoint(paymentsRefund),
    };
  }
}
