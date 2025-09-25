import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/index.dart';
import '../../errors/contextual_errors.dart';
import '../../errors/enhanced_error_handler.dart';
import 'enhanced_error_display.dart';

/// Widget de démonstration du système d'erreurs amélioré
class ErrorDemoWidget extends ConsumerWidget {
  const ErrorDemoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentError = ref.watch(currentErrorProvider);
    final errorHistory = ref.watch(errorHistoryProvider);
    final errorStatistics = ref.watch(errorStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration des Erreurs Contextuelles'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affichage de l'erreur actuelle
            if (currentError != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Erreur actuelle',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      EnhancedErrorDisplay(
                        error: currentError,
                        onRetry: () => ref.read(errorStateProvider.notifier).clearCurrentError(),
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Statistiques des erreurs
            if (errorStatistics.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistiques des erreurs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...errorStatistics.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.key)),
                            Text('${entry.value}'),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tests d'erreurs d'authentification
            _buildErrorCategory(
              context,
              'Erreurs d\'Authentification',
              Colors.orange,
              [
                _buildTestButton(
                  'Identifiants invalides',
                  () => _testAuthError(ref, 'invalid_credentials'),
                ),
                _buildTestButton(
                  'Utilisateur non trouvé',
                  () => _testAuthError(ref, 'user_not_found'),
                ),
                _buildTestButton(
                  'Token expiré',
                  () => _testAuthError(ref, 'token_expired'),
                ),
                _buildTestButton(
                  'Compte verrouillé',
                  () => _testAuthError(ref, 'account_locked'),
                ),
              ],
            ),

            // Tests d'erreurs de réservation
            _buildErrorCategory(
              context,
              'Erreurs de Réservation',
              Colors.red,
              [
                _buildTestButton(
                  'Créneau indisponible',
                  () => _testReservationError(ref, 'time_slot_unavailable'),
                ),
                _buildTestButton(
                  'Trop de personnes',
                  () => _testReservationError(ref, 'max_party_size_exceeded'),
                ),
                _buildTestButton(
                  'Réservation trop tôt',
                  () => _testReservationError(ref, 'reservation_too_early'),
                ),
                _buildTestButton(
                  'Restaurant fermé',
                  () => _testReservationError(ref, 'restaurant_closed'),
                ),
              ],
            ),

            // Tests d'erreurs de paiement
            _buildErrorCategory(
              context,
              'Erreurs de Paiement',
              Colors.purple,
              [
                _buildTestButton(
                  'Carte refusée',
                  () => _testPaymentError(ref, 'payment_declined'),
                ),
                _buildTestButton(
                  'Fonds insuffisants',
                  () => _testPaymentError(ref, 'insufficient_funds'),
                ),
                _buildTestButton(
                  'Carte expirée',
                  () => _testPaymentError(ref, 'card_expired'),
                ),
                _buildTestButton(
                  'Erreur Stripe',
                  () => _testPaymentError(ref, 'stripe_error'),
                ),
              ],
            ),

            // Tests d'erreurs de validation
            _buildErrorCategory(
              context,
              'Erreurs de Validation',
              Colors.amber,
              [
                _buildTestButton(
                  'Champ obligatoire',
                  () => _testValidationError(ref, 'required_field'),
                ),
                _buildTestButton(
                  'Email invalide',
                  () => _testValidationError(ref, 'invalid_email'),
                ),
                _buildTestButton(
                  'Téléphone invalide',
                  () => _testValidationError(ref, 'invalid_phone'),
                ),
                _buildTestButton(
                  'Nombre de personnes invalide',
                  () => _testValidationError(ref, 'invalid_party_size'),
                ),
              ],
            ),

            // Tests d'erreurs de réseau
            _buildErrorCategory(
              context,
              'Erreurs de Réseau',
              Colors.blue,
              [
                _buildTestButton(
                  'Connexion lente',
                  () => _testNetworkError(ref, 'connection_timeout'),
                ),
                _buildTestButton(
                  'Serveur indisponible',
                  () => _testNetworkError(ref, 'server_unavailable'),
                ),
                _buildTestButton(
                  'Limite de taux',
                  () => _testNetworkError(ref, 'api_rate_limit'),
                ),
              ],
            ),

            // Tests d'erreurs de serveur
            _buildErrorCategory(
              context,
              'Erreurs de Serveur',
              Colors.red.shade800,
              [
                _buildTestButton(
                  'Mode maintenance',
                  () => _testServerError(ref, 'maintenance_mode'),
                ),
                _buildTestButton(
                  'Erreur base de données',
                  () => _testServerError(ref, 'database_error'),
                ),
                _buildTestButton(
                  'Erreur interne',
                  () => _testServerError(ref, 'internal_error'),
                ),
              ],
            ),

            // Actions globales
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions globales',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => ref.read(errorStateProvider.notifier).clearCurrentError(),
                            icon: const Icon(Icons.clear),
                            label: const Text('Effacer erreur actuelle'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => ref.read(errorStateProvider.notifier).clearErrorHistory(),
                            icon: const Icon(Icons.history),
                            label: const Text('Effacer historique'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showErrorHistory(context, errorHistory),
                            icon: const Icon(Icons.list),
                            label: const Text('Voir historique'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showErrorStatistics(context, errorStatistics),
                            icon: const Icon(Icons.analytics),
                            label: const Text('Voir statistiques'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCategory(
    BuildContext context,
    String title,
    Color color,
    List<Widget> buttons,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  // Méthodes de test pour chaque catégorie d'erreur
  void _testAuthError(WidgetRef ref, String errorKey) {
    final error = ContextualAuthError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _testReservationError(WidgetRef ref, String errorKey) {
    final error = ContextualReservationError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _testPaymentError(WidgetRef ref, String errorKey) {
    final error = ContextualPaymentError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _testValidationError(WidgetRef ref, String errorKey) {
    final error = ContextualValidationError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _testNetworkError(WidgetRef ref, String errorKey) {
    final error = ContextualNetworkError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _testServerError(WidgetRef ref, String errorKey) {
    final error = ContextualServerError(errorKey: errorKey);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(ref.context, error);
  }

  void _showErrorHistory(BuildContext context, List<ContextualError> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique des erreurs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final error = history[index];
              return ListTile(
                leading: Icon(_getErrorIcon(error)),
                title: Text(error.errorKey),
                subtitle: Text(error.getLocalizedMessage()),
                trailing: Text('${index + 1}'),
              );
            },
          ),
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

  void _showErrorStatistics(BuildContext context, Map<String, int> statistics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques des erreurs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: statistics.length,
            itemBuilder: (context, index) {
              final entry = statistics.entries.elementAt(index);
              return ListTile(
                title: Text(entry.key),
                trailing: Text('${entry.value}'),
              );
            },
          ),
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

  IconData _getErrorIcon(ContextualError error) {
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
}
