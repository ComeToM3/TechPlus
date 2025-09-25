import 'package:flutter/material.dart';
import 'app_errors.dart';
import 'error_messages.dart';

/// Gestionnaire d'erreurs centralisé
class ErrorHandler {
  /// Afficher une erreur dans un SnackBar
  static void showError(BuildContext context, AppError error) {
    final message = _getErrorMessage(error);
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
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

  /// Afficher un message de succès
  static void showSuccess(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
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

  /// Afficher une erreur dans une boîte de dialogue
  static void showErrorDialog(BuildContext context, AppError error) {
    final message = _getErrorMessage(error);
    final title = _getErrorTitle(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Afficher une erreur avec des actions personnalisées
  static void showErrorWithActions(
    BuildContext context,
    AppError error,
    List<Widget> actions,
  ) {
    final message = _getErrorMessage(error);
    final title = _getErrorTitle(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  /// Afficher une erreur de confirmation
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  /// Obtenir le message d'erreur localisé
  static String _getErrorMessage(AppError error) {
    switch (error.runtimeType) {
      case NetworkError:
        return error.message.contains('timeout')
            ? ErrorMessages.connectionTimeout
            : ErrorMessages.networkUnavailable;
      case AuthError:
        if (error.message.contains('credentials')) {
          return ErrorMessages.invalidCredentials;
        } else if (error.message.contains('token')) {
          return ErrorMessages.tokenExpired;
        }
        return ErrorMessages.invalidCredentials;
      case ValidationError:
        if (error.message.contains('email')) {
          return ErrorMessages.invalidEmail;
        } else if (error.message.contains('phone')) {
          return ErrorMessages.invalidPhone;
        } else if (error.message.contains('required')) {
          return ErrorMessages.requiredField;
        }
        return ErrorMessages.requiredField;
      case ReservationError:
        if (error.message.contains('not found')) {
          return ErrorMessages.reservationNotFound;
        } else if (error.message.contains('unavailable')) {
          return ErrorMessages.timeSlotUnavailable;
        } else if (error.message.contains('expired')) {
          return ErrorMessages.reservationExpired;
        }
        return ErrorMessages.reservationNotFound;
      case PaymentError:
        if (error.message.contains('declined')) {
          return ErrorMessages.paymentDeclined;
        } else if (error.message.contains('insufficient')) {
          return ErrorMessages.insufficientFunds;
        } else if (error.message.contains('expired')) {
          return ErrorMessages.cardExpired;
        }
        return ErrorMessages.paymentFailed;
      case ServerError:
        return ErrorMessages.serverError;
      default:
        return error.message.isNotEmpty ? error.message : ErrorMessages.unknownError;
    }
  }

  /// Obtenir le titre d'erreur
  static String _getErrorTitle(AppError error) {
    switch (error.runtimeType) {
      case NetworkError:
        return 'Erreur de connexion';
      case AuthError:
        return 'Erreur d\'authentification';
      case ValidationError:
        return 'Erreur de validation';
      case ReservationError:
        return 'Erreur de réservation';
      case PaymentError:
        return 'Erreur de paiement';
      case ServerError:
        return 'Erreur du serveur';
      default:
        return 'Erreur';
    }
  }

  /// Logger une erreur (pour le debugging)
  static void logError(AppError error, [StackTrace? stackTrace]) {
    // TODO: Implémenter le logging avec un service de logging
    print('Error: ${error.message}');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}
