import 'package:dio/dio.dart';
import '../../shared/models/user.dart';
import '../../shared/models/reservation.dart';
import '../../shared/errors/contextual_errors.dart';
import '../config/api_config.dart';

/// Service API centralisé pour remplacer toutes les simulations
class ApiService {
  final Dio _dio;
  final String _baseUrl;

  ApiService(this._dio, this._baseUrl) {
    // Vérifier que l'API est configurée
    if (!ApiConfig.isConfigured) {
      throw Exception('API backend non configurée. Veuillez configurer ApiConfig.baseUrl');
    }
  }

  // ==================== AUTHENTICATION ====================

  /// Connexion avec email et mot de passe
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ContextualAuthError(
          errorKey: 'login_failed',
          message: 'Échec de la connexion: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualAuthError(
        errorKey: 'login_error',
        message: 'Erreur de connexion: ${e.toString()}',
      );
    }
  }

  /// Inscription avec email et mot de passe
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ContextualAuthError(
          errorKey: 'registration_failed',
          message: 'Échec de l\'inscription: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualAuthError(
        errorKey: 'registration_error',
        message: 'Erreur d\'inscription: ${e.toString()}',
      );
    }
  }

  /// Connexion par token (pour les guests)
  Future<AuthResponse> loginWithToken(String token) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/token', data: {
        'token': token,
      });

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ContextualAuthError(
          errorKey: 'token_invalid',
          message: 'Token invalide ou expiré',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualAuthError(
        errorKey: 'token_error',
        message: 'Erreur de validation du token: ${e.toString()}',
      );
    }
  }

  /// Rafraîchir le token d'accès
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ContextualAuthError(
          errorKey: 'refresh_failed',
          message: 'Échec du rafraîchissement du token',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualAuthError(
        errorKey: 'refresh_error',
        message: 'Erreur de rafraîchissement: ${e.toString()}',
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _dio.post('$_baseUrl/api/auth/logout');
    } on DioException catch (e) {
      // Ne pas propager l'erreur pour la déconnexion
      print('Logout error: ${e.message}');
    }
  }

  // ==================== RESERVATIONS ====================

  /// Charger les réservations
  Future<List<Reservation>> getReservations({
    String? userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _dio.get('$_baseUrl/api/reservations', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reservations'];
        return data.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw ContextualReservationError(
          errorKey: 'load_reservations_failed',
          message: 'Échec du chargement des réservations',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'load_reservations_error',
        message: 'Erreur de chargement: ${e.toString()}',
      );
    }
  }

  /// Créer une réservation
  Future<Reservation> createReservation(Reservation reservation) async {
    try {
      final response = await _dio.post('$_baseUrl/api/reservations', data: reservation.toJson());

      if (response.statusCode == 201) {
        return Reservation.fromJson(response.data);
      } else {
        throw ContextualReservationError(
          errorKey: 'create_reservation_failed',
          message: 'Échec de la création de la réservation',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'create_reservation_error',
        message: 'Erreur de création: ${e.toString()}',
      );
    }
  }

  /// Mettre à jour une réservation
  Future<Reservation> updateReservation(String id, Reservation reservation) async {
    try {
      final response = await _dio.put('$_baseUrl/api/reservations/$id', data: reservation.toJson());

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data);
      } else {
        throw ContextualReservationError(
          errorKey: 'update_reservation_failed',
          message: 'Échec de la mise à jour de la réservation',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'update_reservation_error',
        message: 'Erreur de mise à jour: ${e.toString()}',
      );
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation(String id, {String? reason}) async {
    try {
      final response = await _dio.delete('$_baseUrl/api/reservations/$id', data: {
        'reason': reason,
      });

      if (response.statusCode != 200) {
        throw ContextualReservationError(
          errorKey: 'cancel_reservation_failed',
          message: 'Échec de l\'annulation de la réservation',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'cancel_reservation_error',
        message: 'Erreur d\'annulation: ${e.toString()}',
      );
    }
  }

  /// Obtenir une réservation par ID
  Future<Reservation> getReservation(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/api/reservations/$id');

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data);
      } else {
        throw ContextualReservationError(
          errorKey: 'get_reservation_failed',
          message: 'Réservation non trouvée',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'get_reservation_error',
        message: 'Erreur de récupération: ${e.toString()}',
      );
    }
  }

  // ==================== GUEST MANAGEMENT ====================

  /// Valider un token guest
  Future<Reservation> validateGuestToken(String token) async {
    try {
      final response = await _dio.get('$_baseUrl/api/reservations/manage/$token');

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data);
      } else {
        throw ContextualReservationError(
          errorKey: 'token_invalid',
          message: 'Token invalide ou expiré',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'token_validation_error',
        message: 'Erreur de validation du token: ${e.toString()}',
      );
    }
  }

  /// Modifier une réservation avec token guest
  Future<Reservation> updateReservationWithToken(String token, Reservation reservation) async {
    try {
      final response = await _dio.put('$_baseUrl/api/reservations/manage/$token', data: reservation.toJson());

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data);
      } else {
        throw ContextualReservationError(
          errorKey: 'update_guest_reservation_failed',
          message: 'Échec de la modification de la réservation',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'update_guest_reservation_error',
        message: 'Erreur de modification: ${e.toString()}',
      );
    }
  }

  /// Annuler une réservation avec token guest
  Future<void> cancelReservationWithToken(String token, {String? reason}) async {
    try {
      final response = await _dio.delete('$_baseUrl/api/reservations/manage/$token', data: {
        'reason': reason,
      });

      if (response.statusCode != 200) {
        throw ContextualReservationError(
          errorKey: 'cancel_guest_reservation_failed',
          message: 'Échec de l\'annulation de la réservation',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'cancel_guest_reservation_error',
        message: 'Erreur d\'annulation: ${e.toString()}',
      );
    }
  }

  // ==================== AVAILABILITY ====================

  /// Obtenir les créneaux disponibles
  Future<List<String>> getAvailableTimeSlots(DateTime date, int partySize) async {
    try {
      final response = await _dio.get('$_baseUrl/api/availability', queryParameters: {
        'date': date.toIso8601String().split('T')[0],
        'partySize': partySize,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['timeSlots'];
        return data.cast<String>();
      } else {
        throw ContextualReservationError(
          errorKey: 'availability_failed',
          message: 'Échec de la récupération des créneaux',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualReservationError(
        errorKey: 'availability_error',
        message: 'Erreur de disponibilité: ${e.toString()}',
      );
    }
  }

  // ==================== PAYMENTS ====================

  /// Créer un PaymentIntent Stripe
  Future<PaymentIntentResponse> createPaymentIntent({
    required double amount,
    required String currency,
    required String reservationId,
  }) async {
    try {
      final response = await _dio.post('$_baseUrl/api/payments/create-intent', data: {
        'amount': (amount * 100).round(), // Convertir en centimes
        'currency': currency,
        'reservationId': reservationId,
      });

      if (response.statusCode == 200) {
        return PaymentIntentResponse.fromJson(response.data);
      } else {
        throw ContextualPaymentError(
          errorKey: 'payment_intent_failed',
          message: 'Échec de la création du PaymentIntent',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_intent_error',
        message: 'Erreur de paiement: ${e.toString()}',
      );
    }
  }

  /// Confirmer un paiement
  Future<PaymentConfirmationResponse> confirmPayment(String paymentIntentId) async {
    try {
      final response = await _dio.post('$_baseUrl/api/payments/confirm', data: {
        'paymentIntentId': paymentIntentId,
      });

      if (response.statusCode == 200) {
        return PaymentConfirmationResponse.fromJson(response.data);
      } else {
        throw ContextualPaymentError(
          errorKey: 'payment_confirmation_failed',
          message: 'Échec de la confirmation du paiement',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_confirmation_error',
        message: 'Erreur de confirmation: ${e.toString()}',
      );
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Envoyer un email de confirmation
  Future<void> sendConfirmationEmail({
    required String reservationId,
    required String clientEmail,
  }) async {
    try {
      await _dio.post('$_baseUrl/api/notifications/send', data: {
        'type': 'reservation_confirmation',
        'reservationId': reservationId,
        'clientEmail': clientEmail,
      });
    } on DioException catch (e) {
      // Ne pas propager l'erreur pour les notifications
      print('Email notification error: ${e.message}');
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Gérer les erreurs Dio
  ContextualError _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ContextualNetworkError(
          errorKey: 'network_timeout',
          message: 'Délai d\'attente dépassé',
          suggestedActions: ['Vérifiez votre connexion internet', 'Réessayez plus tard'],
        );
      case DioExceptionType.connectionError:
        return ContextualNetworkError(
          errorKey: 'network_connection',
          message: 'Erreur de connexion',
          suggestedActions: ['Vérifiez votre connexion internet', 'Réessayez plus tard'],
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return ContextualAuthError(
            errorKey: 'unauthorized',
            message: 'Non autorisé',
            suggestedActions: ['Reconnectez-vous', 'Vérifiez vos identifiants'],
          );
        } else if (statusCode == 403) {
          return ContextualAuthError(
            errorKey: 'forbidden',
            message: 'Accès interdit',
            suggestedActions: ['Contactez l\'administrateur'],
          );
        } else if (statusCode == 404) {
          return ContextualError(
            errorKey: 'not_found',
            message: 'Ressource non trouvée',
            suggestedActions: ['Vérifiez l\'URL', 'Contactez le support'],
          );
        } else if (statusCode == 500) {
          return ContextualServerError(
            errorKey: 'server_error',
            message: 'Erreur serveur',
            suggestedActions: ['Réessayez plus tard', 'Contactez le support'],
          );
        } else {
          return ContextualError(
            errorKey: 'http_error',
            message: 'Erreur HTTP $statusCode',
            suggestedActions: ['Réessayez plus tard'],
          );
        }
      default:
        return ContextualError(
          errorKey: 'unknown_error',
          message: 'Erreur inconnue: ${e.message}',
          suggestedActions: ['Réessayez plus tard', 'Contactez le support'],
        );
    }
  }
}

/// Réponse d'authentification
class AuthResponse {
  final User user;
  final String accessToken;
  final String? refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Le backend retourne une structure avec 'data' qui contient 'user' et 'tokens'
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid response format: missing data field');
    }
    
    return AuthResponse(
      user: User.fromJson(data['user']),
      accessToken: data['tokens']['accessToken'],
      refreshToken: data['tokens']['refreshToken'],
    );
  }
}

/// Réponse PaymentIntent
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'],
      paymentIntentId: json['paymentIntentId'],
    );
  }
}

/// Réponse de confirmation de paiement
class PaymentConfirmationResponse {
  final bool success;
  final String? error;

  PaymentConfirmationResponse({
    required this.success,
    this.error,
  });

  factory PaymentConfirmationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmationResponse(
      success: json['success'],
      error: json['error'],
    );
  }
}
