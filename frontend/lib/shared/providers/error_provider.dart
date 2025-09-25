import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/contextual_errors.dart';

/// État de gestion des erreurs
class ErrorState {
  final ContextualError? currentError;
  final List<ContextualError> errorHistory;
  final bool isRetrying;
  final DateTime? lastErrorTime;

  const ErrorState({
    this.currentError,
    this.errorHistory = const [],
    this.isRetrying = false,
    this.lastErrorTime,
  });

  ErrorState copyWith({
    ContextualError? currentError,
    List<ContextualError>? errorHistory,
    bool? isRetrying,
    DateTime? lastErrorTime,
  }) {
    return ErrorState(
      currentError: currentError ?? this.currentError,
      errorHistory: errorHistory ?? this.errorHistory,
      isRetrying: isRetrying ?? this.isRetrying,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
    );
  }

  /// Vérifier si une erreur est récente (moins de 5 minutes)
  bool get isRecentError {
    if (lastErrorTime == null) return false;
    return DateTime.now().difference(lastErrorTime!).inMinutes < 5;
  }

  /// Obtenir les erreurs récentes
  List<ContextualError> get recentErrors {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return errorHistory.where((error) => 
      error.details is DateTime && 
      (error.details as DateTime).isAfter(fiveMinutesAgo)
    ).toList();
  }

  /// Vérifier si une erreur similaire s'est produite récemment
  bool hasSimilarRecentError(ContextualError error) {
    return recentErrors.any((recentError) => 
      recentError.runtimeType == error.runtimeType &&
      recentError.errorKey == error.errorKey
    );
  }
}

/// Notifier pour la gestion des erreurs
class ErrorNotifier extends StateNotifier<ErrorState> {
  ErrorNotifier() : super(const ErrorState());

  /// Ajouter une nouvelle erreur
  void addError(ContextualError error) {
    final now = DateTime.now();
    final updatedHistory = <ContextualError>[
      ...state.errorHistory,
      error.copyWith(details: now),
    ];

    state = state.copyWith(
      currentError: error,
      errorHistory: updatedHistory,
      lastErrorTime: now,
    );
  }

  /// Effacer l'erreur actuelle
  void clearCurrentError() {
    state = state.copyWith(currentError: null);
  }

  /// Marquer le début d'un retry
  void startRetry() {
    state = state.copyWith(isRetrying: true);
  }

  /// Marquer la fin d'un retry
  void endRetry() {
    state = state.copyWith(isRetrying: false);
  }

  /// Effacer l'historique des erreurs
  void clearErrorHistory() {
    state = state.copyWith(
      errorHistory: [],
      lastErrorTime: null,
    );
  }

  /// Obtenir les statistiques d'erreurs
  Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};
    
    for (final error in state.errorHistory) {
      final key = '${error.runtimeType}_${error.errorKey}';
      stats[key] = (stats[key] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Obtenir les erreurs les plus fréquentes
  List<ContextualError> getMostFrequentErrors({int limit = 5}) {
    final stats = getErrorStatistics();
    final sortedStats = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedStats.take(limit).map<ContextualError>((entry) {
      final keyParts = entry.key.split('_');
      final errorType = keyParts[0];
      final errorKey = keyParts.sublist(1).join('_');
      
      // Créer une erreur représentative basée sur le type et la clé
      switch (errorType) {
        case 'ContextualAuthError':
          return ContextualAuthError(errorKey: errorKey);
        case 'ContextualReservationError':
          return ContextualReservationError(errorKey: errorKey);
        case 'ContextualPaymentError':
          return ContextualPaymentError(errorKey: errorKey);
        case 'ContextualValidationError':
          return ContextualValidationError(errorKey: errorKey);
        case 'ContextualNetworkError':
          return ContextualNetworkError(errorKey: errorKey);
        case 'ContextualServerError':
          return ContextualServerError(errorKey: errorKey);
        default:
          return ContextualAuthError(errorKey: errorKey);
      }
    }).toList();
  }
}

/// Provider pour l'état des erreurs
final errorStateProvider = StateNotifierProvider<ErrorNotifier, ErrorState>((ref) {
  return ErrorNotifier();
});

/// Provider pour l'erreur actuelle
final currentErrorProvider = Provider<ContextualError?>((ref) {
  return ref.watch(errorStateProvider).currentError;
});

/// Provider pour l'historique des erreurs
final errorHistoryProvider = Provider<List<ContextualError>>((ref) {
  return ref.watch(errorStateProvider).errorHistory;
});

/// Provider pour les erreurs récentes
final recentErrorsProvider = Provider<List<ContextualError>>((ref) {
  return ref.watch(errorStateProvider).recentErrors;
});

/// Provider pour les statistiques d'erreurs
final errorStatisticsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(errorStateProvider.notifier);
  return notifier.getErrorStatistics();
});

/// Provider pour les erreurs les plus fréquentes
final mostFrequentErrorsProvider = Provider<List<ContextualError>>((ref) {
  final notifier = ref.watch(errorStateProvider.notifier);
  return notifier.getMostFrequentErrors();
});

/// Provider pour vérifier si une erreur est récente
final isRecentErrorProvider = Provider<bool>((ref) {
  return ref.watch(errorStateProvider).isRecentError;
});

/// Provider pour vérifier si un retry est en cours
final isRetryingProvider = Provider<bool>((ref) {
  return ref.watch(errorStateProvider).isRetrying;
});

/// Provider pour créer des erreurs contextuelles
final contextualErrorFactoryProvider = Provider<ContextualErrorFactory>((ref) {
  return ContextualErrorFactory();
});

/// Factory pour créer des erreurs contextuelles
class ContextualErrorFactory {
  /// Créer une erreur d'authentification
  ContextualAuthError createAuthError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualAuthError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur de réservation
  ContextualReservationError createReservationError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualReservationError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur de paiement
  ContextualPaymentError createPaymentError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualPaymentError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur de validation
  ContextualValidationError createValidationError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualValidationError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur de réseau
  ContextualNetworkError createNetworkError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualNetworkError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur de serveur
  ContextualServerError createServerError(String errorKey, {Map<String, String>? parameters}) {
    return ContextualServerError(
      errorKey: errorKey,
      parameters: parameters,
    );
  }

  /// Créer une erreur à partir d'une exception
  ContextualError fromException(dynamic exception) {
    final message = exception.toString();
    
    if (message.contains('network') || message.contains('connection')) {
      return ContextualNetworkError(
        errorKey: 'network_unavailable',
        message: message,
      );
    }
    
    if (message.contains('auth') || message.contains('login')) {
      return ContextualAuthError(
        errorKey: 'invalid_credentials',
        message: message,
      );
    }
    
    if (message.contains('validation') || message.contains('invalid')) {
      return ContextualValidationError(
        errorKey: 'required_field',
        message: message,
      );
    }
    
    if (message.contains('reservation')) {
      return ContextualReservationError(
        errorKey: 'reservation_not_found',
        message: message,
      );
    }
    
    if (message.contains('payment')) {
      return ContextualPaymentError(
        errorKey: 'payment_failed',
        message: message,
      );
    }
    
    if (message.contains('server') || message.contains('500')) {
      return ContextualServerError(
        errorKey: 'server_error',
        message: message,
      );
    }
    
    return ContextualAuthError(
      errorKey: 'unknown_error',
      message: message,
    );
  }
}
