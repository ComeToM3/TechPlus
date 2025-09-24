import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_flow_provider.dart';
import '../widgets/client_info_form.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page d'informations client pour la réservation (Étape 2)
class ReservationInfoPage extends ConsumerStatefulWidget {
  const ReservationInfoPage({super.key});

  @override
  ConsumerState<ReservationInfoPage> createState() => _ReservationInfoPageState();
}

class _ReservationInfoPageState extends ConsumerState<ReservationInfoPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations client'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reservations/create'),
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
            // En-tête avec récapitulatif
            _buildHeader(theme, reservationState),
            
            const SizedBox(height: 24),
            
            // Formulaire client
            const ClientInfoForm(),
            
            const SizedBox(height: 32),
            
            // Boutons de navigation
            _buildNavigationButtons(theme, reservationState),
            
            const SizedBox(height: 16),
            
            // Affichage des erreurs
            if (reservationState.error != null)
              _buildErrorCard(theme, reservationState.error!),
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
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Étape 2/4 - Vos informations',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Récapitulatif de la sélection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif de votre réservation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildSummaryRow(
                  theme,
                  Icons.calendar_today,
                  'Date',
                  _formatDate(state.selectedDate!),
                ),
                
                _buildSummaryRow(
                  theme,
                  Icons.access_time,
                  'Heure',
                  state.selectedTime!,
                ),
                
                _buildSummaryRow(
                  theme,
                  Icons.people,
                  'Nombre de personnes',
                  '${state.partySize} ${state.partySize == 1 ? 'personne' : 'personnes'}',
                ),
                
                _buildSummaryRow(
                  theme,
                  Icons.schedule,
                  'Durée',
                  state.partySize <= 4 ? '1h30' : '2h00',
                ),
                
                if (state.partySize >= 6) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: theme.colorScheme.onTertiaryContainer,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Acompte de 10€ requis',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
            onPressed: () => context.go('/reservations/create'),
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
            onPressed: state.canProceedToPayment
                ? () => _proceedToPayment()
                : null,
            text: 'Continuer',
            icon: Icons.arrow_forward,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: state.isLoading,
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

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _proceedToPayment() {
    final notifier = ref.read(reservationFlowProvider.notifier);
    
    if (notifier.validateClientInfo()) {
      // Sauvegarder les données temporaires
      notifier.saveTemporaryData();
      
      // Naviguer vers l'étape de paiement
      if (notifier.isPaymentRequired()) {
        context.go('/reservations/create/payment');
      } else {
        // Pas de paiement requis, aller directement à la confirmation
        context.go('/reservations/create/confirmation');
      }
    }
  }
}
