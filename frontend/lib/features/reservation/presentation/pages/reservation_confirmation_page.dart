import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_flow_provider.dart';
import '../widgets/reservation_summary_widget.dart';
import '../widgets/next_actions_widget.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de confirmation de la réservation (Étape 4)
class ReservationConfirmationPage extends ConsumerStatefulWidget {
  const ReservationConfirmationPage({super.key});

  @override
  ConsumerState<ReservationConfirmationPage> createState() => _ReservationConfirmationPageState();
}

class _ReservationConfirmationPageState extends ConsumerState<ReservationConfirmationPage> {
  @override
  void initState() {
    super.initState();
    // Confirmer automatiquement la réservation au chargement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confirmReservation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
          tooltip: 'Retour à l\'accueil',
        ),
        actions: [
          if (reservationState.isReservationConfirmed)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareReservation(reservationState),
              tooltip: 'Partager la réservation',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de confirmation
            _buildConfirmationHeader(theme, reservationState),
            
            const SizedBox(height: 24),
            
            // Récapitulatif de la réservation
            if (reservationState.isReservationConfirmed) ...[
              const ReservationSummaryWidget(),
              const SizedBox(height: 24),
            ],
            
            // Actions suivantes
            if (reservationState.isReservationConfirmed) ...[
              const NextActionsWidget(),
              const SizedBox(height: 24),
            ],
            
            // État de traitement
            if (reservationState.isProcessingConfirmation) ...[
              _buildProcessingState(theme),
              const SizedBox(height: 24),
            ],
            
            // Affichage des erreurs
            if (reservationState.confirmationError != null) ...[
              _buildErrorCard(theme, reservationState.confirmationError!),
              const SizedBox(height: 24),
            ],
            
            // Bouton de retry en cas d'erreur
            if (reservationState.confirmationError != null) ...[
              _buildRetryButton(theme, reservationState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationHeader(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isReservationConfirmed
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ]
              : state.isProcessingConfirmation
                  ? [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondaryContainer,
                    ]
                  : [
                      theme.colorScheme.error,
                      theme.colorScheme.errorContainer,
                    ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Icône de statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.isReservationConfirmed
                  ? Icons.check_circle
                  : state.isProcessingConfirmation
                      ? Icons.hourglass_empty
                      : Icons.error,
              size: 48,
              color: state.isReservationConfirmed
                  ? theme.colorScheme.primary
                  : state.isProcessingConfirmation
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.error,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Titre
          Text(
            state.isReservationConfirmed
                ? 'Réservation confirmée !'
                : state.isProcessingConfirmation
                    ? 'Confirmation en cours...'
                    : 'Erreur de confirmation',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            state.isReservationConfirmed
                ? 'Votre réservation a été confirmée avec succès. Vous allez recevoir un email de confirmation.'
                : state.isProcessingConfirmation
                    ? 'Veuillez patienter pendant que nous traitons votre réservation...'
                    : 'Une erreur est survenue lors de la confirmation de votre réservation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (state.isReservationConfirmed) ...[
            const SizedBox(height: 16),
            
            // Numéro de réservation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'N° ${state.reservationId ?? 'N/A'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Indicateur de progression
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Traitement en cours...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Création de votre réservation et envoi de l\'email de confirmation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur de confirmation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton(ThemeData theme, ReservationFlowState state) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedButton(
        onPressed: state.isProcessingConfirmation ? null : _confirmReservation,
        text: 'Réessayer',
        icon: Icons.refresh,
        type: ButtonType.primary,
        size: ButtonSize.large,
        isLoading: state.isProcessingConfirmation,
      ),
    );
  }

  Future<void> _confirmReservation() async {
    try {
      await ref.read(reservationFlowProvider.notifier).confirmReservation();
    } catch (e) {
      // L'erreur est gérée par le provider
    }
  }

  void _shareReservation(ReservationFlowState state) {
    if (state.reservationId != null) {
      // TODO: Implémenter le partage de réservation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Partage de la réservation ${state.reservationId}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
