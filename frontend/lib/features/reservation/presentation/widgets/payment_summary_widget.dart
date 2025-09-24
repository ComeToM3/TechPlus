import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Widget pour afficher le résumé de paiement
class PaymentSummaryWidget extends ConsumerWidget {
  const PaymentSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);
    final notifier = ref.read(reservationFlowProvider.notifier);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Résumé de votre réservation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Détails de la réservation
                _buildReservationDetails(theme, reservationState),
                
                const SizedBox(height: 16),
                
                // Séparateur
                Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                
                const SizedBox(height: 16),
                
                // Détails financiers
                _buildFinancialDetails(theme, reservationState, notifier),
                
                if (reservationState.isPaymentRequired) ...[
                  const SizedBox(height: 16),
                  
                  // Séparateur
                  Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                  
                  const SizedBox(height: 16),
                  
                  // Total à payer
                  _buildTotalToPay(theme, reservationState),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(ThemeData theme, ReservationFlowState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de la réservation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          theme,
          Icons.calendar_today,
          'Date',
          _formatDate(state.selectedDate!),
        ),
        
        _buildDetailRow(
          theme,
          Icons.access_time,
          'Heure',
          state.selectedTime!,
        ),
        
        _buildDetailRow(
          theme,
          Icons.people,
          'Nombre de personnes',
          '${state.partySize} ${state.partySize == 1 ? 'personne' : 'personnes'}',
        ),
        
        _buildDetailRow(
          theme,
          Icons.schedule,
          'Durée',
          state.partySize <= 4 ? '1h30' : '2h00',
        ),
        
        if (state.specialRequests.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            theme,
            Icons.note,
            'Demandes spéciales',
            state.specialRequests,
            isMultiline: true,
          ),
        ],
      ],
    );
  }

  Widget _buildFinancialDetails(
    ThemeData theme,
    ReservationFlowState state,
    ReservationFlowNotifier notifier,
  ) {
    final estimatedTotal = notifier.getEstimatedTotal();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimation des coûts',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildFinancialRow(
          theme,
          'Prix moyen par personne',
          '25,00€',
          isSubtotal: true,
        ),
        
        _buildFinancialRow(
          theme,
          '× ${state.partySize} personne${state.partySize > 1 ? 's' : ''}',
          '${estimatedTotal.toStringAsFixed(2)}€',
          isSubtotal: true,
        ),
        
        if (state.isPaymentRequired) ...[
          const SizedBox(height: 8),
          _buildFinancialRow(
            theme,
            'Acompte requis (6+ personnes)',
            '${state.depositAmount.toStringAsFixed(2)}€',
            isHighlighted: true,
          ),
        ],
      ],
    );
  }

  Widget _buildTotalToPay(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Montant à payer maintenant',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            '${state.depositAmount.toStringAsFixed(2)}€',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    ThemeData theme,
    String label,
    String amount, {
    bool isSubtotal = false,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
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
}
