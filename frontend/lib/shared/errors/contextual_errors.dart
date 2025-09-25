import 'app_errors.dart';
import 'enhanced_error_messages.dart';

/// Erreurs contextuelles avec informations détaillées
class ContextualError extends AppError {
  final String errorKey;
  final Map<String, String>? parameters;
  final List<String>? suggestedActions;
  final String? helpUrl;
  final bool isRetryable;
  final int? retryAfterSeconds;

  const ContextualError({
    required this.errorKey,
    super.message = '',
    super.code,
    super.details,
    this.parameters,
    this.suggestedActions,
    this.helpUrl,
    this.isRetryable = false,
    this.retryAfterSeconds,
  });

  /// Obtenir le message d'erreur localisé
  String getLocalizedMessage() {
    return EnhancedErrorMessages.getErrorMessage(errorKey, parameters: parameters);
  }

  /// Obtenir les actions suggérées
  List<String> getSuggestedActions() {
    return suggestedActions ?? EnhancedErrorMessages.getSuggestedActions('general_errors');
  }

  /// Créer une copie de l'erreur avec des paramètres modifiés
  ContextualError copyWith({
    String? errorKey,
    String? message,
    String? code,
    dynamic details,
    Map<String, String>? parameters,
    List<String>? suggestedActions,
    String? helpUrl,
    bool? isRetryable,
    int? retryAfterSeconds,
  }) {
    return ContextualError(
      errorKey: errorKey ?? this.errorKey,
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      parameters: parameters ?? this.parameters,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      helpUrl: helpUrl ?? this.helpUrl,
      isRetryable: isRetryable ?? this.isRetryable,
      retryAfterSeconds: retryAfterSeconds ?? this.retryAfterSeconds,
    );
  }
}

/// Erreur d'authentification contextuelle
class ContextualAuthError extends ContextualError {
  const ContextualAuthError({
    required super.errorKey,
    super.message = '',
    super.code = 'AUTH_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualAuthError.invalidCredentials() {
    return const ContextualAuthError(
      errorKey: 'invalid_credentials',
      suggestedActions: ['Vérifier les identifiants', 'Réinitialiser le mot de passe'],
    );
  }

  factory ContextualAuthError.userNotFound() {
    return const ContextualAuthError(
      errorKey: 'user_not_found',
      suggestedActions: ['Créer un compte', 'Vérifier l\'email'],
    );
  }

  factory ContextualAuthError.tokenExpired() {
    return const ContextualAuthError(
      errorKey: 'token_expired',
      suggestedActions: ['Se reconnecter', 'Rafraîchir la page'],
    );
  }

  factory ContextualAuthError.accountLocked() {
    return const ContextualAuthError(
      errorKey: 'account_locked',
      suggestedActions: ['Contacter le support', 'Attendre le déverrouillage'],
      isRetryable: false,
    );
  }
}

/// Erreur de réservation contextuelle
class ContextualReservationError extends ContextualError {
  const ContextualReservationError({
    required super.errorKey,
    super.message = '',
    super.code = 'RESERVATION_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualReservationError.timeSlotUnavailable({int? maxPartySize}) {
    return ContextualReservationError(
      errorKey: 'time_slot_unavailable',
      parameters: maxPartySize != null ? {'max': maxPartySize.toString()} : null,
      suggestedActions: const ['Choisir un autre créneau', 'Modifier le nombre de personnes'],
    );
  }

  factory ContextualReservationError.maxPartySizeExceeded(int maxSize) {
    return ContextualReservationError(
      errorKey: 'max_party_size_exceeded',
      parameters: {'max': maxSize.toString()},
      suggestedActions: const ['Réduire le nombre de personnes', 'Choisir un autre créneau'],
    );
  }

  factory ContextualReservationError.reservationTooEarly() {
    return const ContextualReservationError(
      errorKey: 'reservation_too_early',
      suggestedActions: ['Choisir un créneau plus tard', 'Contacter le restaurant'],
    );
  }

  factory ContextualReservationError.restaurantClosed() {
    return const ContextualReservationError(
      errorKey: 'restaurant_closed',
      suggestedActions: ['Choisir un autre horaire', 'Vérifier les heures d\'ouverture'],
    );
  }
}

/// Erreur de paiement contextuelle
class ContextualPaymentError extends ContextualError {
  const ContextualPaymentError({
    required super.errorKey,
    super.message = '',
    super.code = 'PAYMENT_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualPaymentError.cardDeclined() {
    return const ContextualPaymentError(
      errorKey: 'payment_declined',
      suggestedActions: ['Vérifier les informations de carte', 'Utiliser une autre carte', 'Contacter la banque'],
    );
  }

  factory ContextualPaymentError.insufficientFunds() {
    return const ContextualPaymentError(
      errorKey: 'insufficient_funds',
      suggestedActions: ['Vérifier le solde', 'Utiliser une autre carte', 'Contacter la banque'],
    );
  }

  factory ContextualPaymentError.cardExpired() {
    return const ContextualPaymentError(
      errorKey: 'card_expired',
      suggestedActions: ['Utiliser une carte valide', 'Mettre à jour les informations de carte'],
    );
  }

  factory ContextualPaymentError.stripeError() {
    return const ContextualPaymentError(
      errorKey: 'stripe_error',
      suggestedActions: ['Réessayer dans quelques minutes', 'Contacter le support'],
      retryAfterSeconds: 60,
    );
  }
}

/// Erreur de validation contextuelle
class ContextualValidationError extends ContextualError {
  const ContextualValidationError({
    required super.errorKey,
    super.message = '',
    super.code = 'VALIDATION_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualValidationError.requiredField(String fieldName) {
    return ContextualValidationError(
      errorKey: 'required_field',
      parameters: {'field': fieldName},
      suggestedActions: const ['Remplir le champ obligatoire', 'Vérifier tous les champs'],
    );
  }

  factory ContextualValidationError.invalidEmail() {
    return const ContextualValidationError(
      errorKey: 'invalid_email',
      suggestedActions: ['Vérifier le format de l\'email', 'Utiliser un email valide'],
    );
  }

  factory ContextualValidationError.invalidPhone() {
    return const ContextualValidationError(
      errorKey: 'invalid_phone',
      suggestedActions: ['Vérifier le format du téléphone', 'Utiliser le format international'],
    );
  }

  factory ContextualValidationError.invalidPartySize({int? min, int? max}) {
    return ContextualValidationError(
      errorKey: 'invalid_party_size',
      parameters: {
        if (min != null) 'min': min.toString(),
        if (max != null) 'max': max.toString(),
      },
      suggestedActions: const ['Ajuster le nombre de personnes', 'Vérifier les limites'],
    );
  }
}

/// Erreur de réseau contextuelle
class ContextualNetworkError extends ContextualError {
  const ContextualNetworkError({
    required super.errorKey,
    super.message = '',
    super.code = 'NETWORK_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualNetworkError.connectionTimeout() {
    return const ContextualNetworkError(
      errorKey: 'connection_timeout',
      suggestedActions: ['Vérifier la connexion internet', 'Réessayer dans quelques minutes'],
      retryAfterSeconds: 30,
    );
  }

  factory ContextualNetworkError.serverUnavailable() {
    return const ContextualNetworkError(
      errorKey: 'server_unavailable',
      suggestedActions: ['Réessayer dans quelques minutes', 'Vérifier le statut du service'],
      retryAfterSeconds: 60,
    );
  }

  factory ContextualNetworkError.apiRateLimit() {
    return const ContextualNetworkError(
      errorKey: 'api_rate_limit',
      suggestedActions: ['Attendre quelques minutes', 'Réduire la fréquence des requêtes'],
      retryAfterSeconds: 300,
    );
  }
}

/// Erreur de serveur contextuelle
class ContextualServerError extends ContextualError {
  const ContextualServerError({
    required super.errorKey,
    super.message = '',
    super.code = 'SERVER_ERROR',
    super.details,
    super.parameters,
    super.suggestedActions,
    super.helpUrl,
    super.isRetryable = true,
    super.retryAfterSeconds,
  });

  factory ContextualServerError.maintenanceMode() {
    return const ContextualServerError(
      errorKey: 'maintenance_mode',
      suggestedActions: ['Réessayer dans quelques heures', 'Vérifier le statut du service'],
      isRetryable: false,
    );
  }

  factory ContextualServerError.databaseError() {
    return const ContextualServerError(
      errorKey: 'database_error',
      suggestedActions: ['Réessayer dans quelques minutes', 'Contacter le support'],
      retryAfterSeconds: 120,
    );
  }

  factory ContextualServerError.internalError() {
    return const ContextualServerError(
      errorKey: 'internal_error',
      suggestedActions: ['Réessayer plus tard', 'Contacter le support'],
      retryAfterSeconds: 300,
    );
  }
}
