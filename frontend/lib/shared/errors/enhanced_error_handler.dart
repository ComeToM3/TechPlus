import 'package:flutter/material.dart';
import 'contextual_errors.dart';
import 'enhanced_error_messages.dart';

/// Gestionnaire d'erreurs amélioré avec messages spécifiques et actions suggérées
class EnhancedErrorHandler {
  /// Afficher une erreur contextuelle dans un SnackBar
  static void showContextualError(BuildContext context, ContextualError error) {
    final message = error.getLocalizedMessage();
    final actions = error.getSuggestedActions();
    
    final snackBar = SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Actions suggérées: ${actions.take(2).join(', ')}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      backgroundColor: _getErrorColor(error),
      duration: Duration(seconds: error.isRetryable ? 6 : 4),
      action: SnackBarAction(
        label: 'Détails',
        textColor: Colors.white,
        onPressed: () => _showErrorDetails(context, error),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Afficher une erreur contextuelle dans une boîte de dialogue
  static void showContextualErrorDialog(BuildContext context, ContextualError error) {
    final message = error.getLocalizedMessage();
    final actions = error.getSuggestedActions();
    final title = _getErrorTitle(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getErrorIcon(error), color: _getErrorColor(error)),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Actions suggérées:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...actions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(action)),
                  ],
                ),
              )),
            ],
            if (error.helpUrl != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _openHelpUrl(context, error.helpUrl!),
                icon: const Icon(Icons.help_outline),
                label: const Text('Aide en ligne'),
              ),
            ],
          ],
        ),
        actions: [
          if (error.isRetryable)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRetry(context, error);
              },
              child: Text(error.retryAfterSeconds != null 
                ? 'Réessayer (${error.retryAfterSeconds}s)'
                : 'Réessayer'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Afficher une erreur contextuelle avec actions personnalisées
  static void showContextualErrorWithActions(
    BuildContext context,
    ContextualError error,
    List<Widget> customActions,
  ) {
    final message = error.getLocalizedMessage();
    final actions = error.getSuggestedActions();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getErrorIcon(error), color: _getErrorColor(error)),
            const SizedBox(width: 8),
            Text(_getErrorTitle(error)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Actions suggérées:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...actions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(action)),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          ...customActions,
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Afficher un message de succès contextuel
  static void showContextualSuccess(BuildContext context, String successKey, {Map<String, String>? parameters}) {
    final message = EnhancedErrorMessages.getSuccessMessage(successKey);
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Fermer',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Afficher un message d'information contextuel
  static void showContextualInfo(BuildContext context, String infoKey, {Map<String, String>? parameters}) {
    final message = EnhancedErrorMessages.getInfoMessage(infoKey);
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 3),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Afficher les détails d'une erreur
  static void _showErrorDetails(BuildContext context, ContextualError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de l\'erreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${error.runtimeType}'),
            Text('Code: ${error.code}'),
            Text('Clé: ${error.errorKey}'),
            if (error.parameters != null) ...[
              const SizedBox(height: 8),
              Text('Paramètres: ${error.parameters}'),
            ],
            if (error.details != null) ...[
              const SizedBox(height: 8),
              Text('Détails: ${error.details}'),
            ],
            if (error.retryAfterSeconds != null) ...[
              const SizedBox(height: 8),
              Text('Réessayer après: ${error.retryAfterSeconds} secondes'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Gérer le retry d'une erreur
  static void _handleRetry(BuildContext context, ContextualError error) {
    // TODO: Implémenter la logique de retry spécifique selon le type d'erreur
    if (error.retryAfterSeconds != null) {
      showContextualInfo(context, 'please_wait');
      // Programmer le retry après le délai spécifié
    } else {
      showContextualInfo(context, 'retry');
    }
  }

  /// Ouvrir l'URL d'aide
  static void _openHelpUrl(BuildContext context, String url) {
    // TODO: Implémenter l'ouverture de l'URL d'aide
    showContextualInfo(context, 'feature_unavailable');
  }

  /// Obtenir la couleur d'erreur selon le type
  static Color _getErrorColor(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Colors.orange;
      case ContextualReservationError:
        return Colors.red;
      case ContextualPaymentError:
        return Colors.purple;
      case ContextualValidationError:
        return Colors.amber;
      case ContextualNetworkError:
        return Colors.blue;
      case ContextualServerError:
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  /// Obtenir l'icône d'erreur selon le type
  static IconData _getErrorIcon(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return Icons.lock_outline;
      case ContextualReservationError:
        return Icons.event_busy;
      case ContextualPaymentError:
        return Icons.payment;
      case ContextualValidationError:
        return Icons.warning_outlined;
      case ContextualNetworkError:
        return Icons.wifi_off;
      case ContextualServerError:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }

  /// Obtenir le titre d'erreur selon le type
  static String _getErrorTitle(ContextualError error) {
    switch (error.runtimeType) {
      case ContextualAuthError:
        return 'Erreur d\'authentification';
      case ContextualReservationError:
        return 'Erreur de réservation';
      case ContextualPaymentError:
        return 'Erreur de paiement';
      case ContextualValidationError:
        return 'Erreur de validation';
      case ContextualNetworkError:
        return 'Erreur de connexion';
      case ContextualServerError:
        return 'Erreur du serveur';
      default:
        return 'Erreur';
    }
  }

  /// Logger une erreur contextuelle
  static void logContextualError(ContextualError error, [StackTrace? stackTrace]) {
    // TODO: Implémenter le logging avec un service de logging
    print('Contextual Error: ${error.errorKey}');
    print('Message: ${error.getLocalizedMessage()}');
    print('Parameters: ${error.parameters}');
    print('Suggested Actions: ${error.getSuggestedActions()}');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}
