/// Erreurs de l'application
abstract class AppError {
  final String message;
  final String? code;
  final dynamic details;

  const AppError({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => message;
}

/// Erreur de réseau
class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Erreur de connexion réseau',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

/// Erreur d'authentification
class AuthError extends AppError {
  const AuthError({
    super.message = 'Erreur d\'authentification',
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

/// Erreur de validation
class ValidationError extends AppError {
  const ValidationError({
    super.message = 'Erreur de validation',
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

/// Erreur de réservation
class ReservationError extends AppError {
  const ReservationError({
    super.message = 'Erreur de réservation',
    super.code = 'RESERVATION_ERROR',
    super.details,
  });
}

/// Erreur de paiement
class PaymentError extends AppError {
  const PaymentError({
    super.message = 'Erreur de paiement',
    super.code = 'PAYMENT_ERROR',
    super.details,
  });
}

/// Erreur de serveur
class ServerError extends AppError {
  const ServerError({
    super.message = 'Erreur du serveur',
    super.code = 'SERVER_ERROR',
    super.details,
  });
}

/// Erreur inconnue
class UnknownError extends AppError {
  const UnknownError({
    super.message = 'Erreur inconnue',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}

/// Factory pour créer des erreurs
class AppErrorFactory {
  static AppError fromException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }

    final message = exception.toString();
    
    if (message.contains('network') || message.contains('connection')) {
      return const NetworkError();
    }
    
    if (message.contains('auth') || message.contains('login')) {
      return const AuthError();
    }
    
    if (message.contains('validation') || message.contains('invalid')) {
      return const ValidationError();
    }
    
    if (message.contains('reservation')) {
      return const ReservationError();
    }
    
    if (message.contains('payment')) {
      return const PaymentError();
    }
    
    if (message.contains('server') || message.contains('500')) {
      return const ServerError();
    }
    
    return UnknownError(message: message);
  }

  static AppError networkError([String? message]) {
    return NetworkError(message: message ?? 'Erreur de connexion réseau');
  }

  static AppError authError([String? message]) {
    return AuthError(message: message ?? 'Erreur d\'authentification');
  }

  static AppError validationError([String? message]) {
    return ValidationError(message: message ?? 'Erreur de validation');
  }

  static AppError reservationError([String? message]) {
    return ReservationError(message: message ?? 'Erreur de réservation');
  }

  static AppError paymentError([String? message]) {
    return PaymentError(message: message ?? 'Erreur de paiement');
  }

  static AppError serverError([String? message]) {
    return ServerError(message: message ?? 'Erreur du serveur');
  }
}
