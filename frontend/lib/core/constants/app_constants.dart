/// Constantes de l'application TechPlus
class AppConstants {
  // Informations de l'application
  static const String appName = 'TechPlus';
  static const String appVersion = '1.0.0';

  // URLs de l'API
  static const String baseUrl = 'http://localhost:3000';
  static const String apiUrl = '$baseUrl/api';

  // Endpoints API
  static const String authEndpoint = '$apiUrl/auth';
  static const String reservationsEndpoint = '$apiUrl/reservations';
  static const String availabilityEndpoint = '$apiUrl/availability';
  static const String paymentsEndpoint = '$apiUrl/payments';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;

  // Reservation
  static const int minPartySize = 1;
  static const int maxPartySize = 12;
  static const int paymentThreshold =
      6; // Paiement obligatoire pour 6+ personnes
  static const double defaultDepositAmount = 10.0; // 10$ d'acompte
}
