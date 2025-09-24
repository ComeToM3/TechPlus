import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_flow_provider.dart';
import '../widgets/payment_summary_widget.dart';
import '../widgets/cancellation_policy_widget.dart';
import '../widgets/stripe_payment_widget.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de paiement pour la réservation (Étape 3)
class ReservationPaymentPage extends ConsumerStatefulWidget {
  const ReservationPaymentPage({super.key});

  @override
  ConsumerState<ReservationPaymentPage> createState() => _ReservationPaymentPageState();
}

class _ReservationPaymentPageState extends ConsumerState<ReservationPaymentPage> {
  @override
  void initState() {
    super.initState();
    // Initialiser les informations de paiement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationFlowProvider.notifier).initializePayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reservations/create/info'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
            tooltip: 'Retour à l\'accueil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, reservationState),
            
            const SizedBox(height: 24),
            
            // Résumé de la réservation
            const PaymentSummaryWidget(),
            
            const SizedBox(height: 24),
            
            // Interface de paiement ou message
            if (reservationState.isPaymentRequired) ...[
              const StripePaymentWidget(),
              const SizedBox(height: 24),
            ] else ...[
              _buildNoPaymentRequired(theme),
              const SizedBox(height: 24),
            ],
            
            // Politique d'annulation
            const CancellationPolicyWidget(),
            
            const SizedBox(height: 32),
            
            // Boutons de navigation
            _buildNavigationButtons(theme, reservationState),
            
            const SizedBox(height: 16),
            
            // Affichage des erreurs
            if (reservationState.paymentError != null)
              _buildErrorCard(theme, reservationState.paymentError!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.isPaymentRequired ? Icons.payment : Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Étape 3/4 - ${state.isPaymentRequired ? 'Paiement' : 'Confirmation'}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            state.isPaymentRequired
                ? 'Finalisez votre réservation en payant l\'acompte requis.'
                : 'Votre réservation ne nécessite pas de paiement. Vous pouvez procéder à la confirmation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPaymentRequired(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun paiement requis',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre réservation est pour moins de 6 personnes. Vous pouvez procéder directement à la confirmation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme, ReservationFlowState state) {
    return Row(
      children: [
        // Bouton retour
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.go('/reservations/create/info'),
            text: 'Retour',
            icon: Icons.arrow_back,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Bouton continuer
        Expanded(
          child: AnimatedButton(
            onPressed: state.canProceedToConfirmation
                ? () => _proceedToConfirmation()
                : null,
            text: 'Continuer',
            icon: Icons.arrow_forward,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: state.isPaymentProcessing,
          ),
        ),
      ],
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
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToConfirmation() {
    final currentState = ref.read(reservationFlowProvider);
    if (currentState.isPaymentRequired && !currentState.isPaymentCompleted) {
      // Afficher un message d'erreur si le paiement n'est pas terminé
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter le paiement avant de continuer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Naviguer vers la confirmation
    context.go('/reservations/create/confirmation');
  }
}
