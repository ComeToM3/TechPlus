import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Widget pour afficher le récapitulatif final de la réservation
class ReservationSummaryWidget extends ConsumerWidget {
  const ReservationSummaryWidget({super.key});

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
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Récapitulatif de votre réservation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
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
                // Numéro de réservation
                if (reservationState.reservationId != null) ...[
                  _buildReservationId(theme, reservationState.reservationId!),
                  const SizedBox(height: 16),
                ],
                
                // Détails de la réservation
                _buildReservationDetails(theme, reservationState, notifier),
                
                const SizedBox(height: 16),
                
                // Informations client
                _buildClientInfo(theme, reservationState),
                
                const SizedBox(height: 16),
                
                // Détails financiers
                _buildFinancialDetails(theme, reservationState, notifier),
                
                const SizedBox(height: 16),
                
                // Token de gestion
                if (reservationState.managementToken != null) ...[
                  _buildManagementToken(theme, reservationState.managementToken!),
                  const SizedBox(height: 16),
                ],
                
                // Statut de l'email
                _buildEmailStatus(theme, reservationState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationId(ThemeData theme, String reservationId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.confirmation_number,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Numéro de réservation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  reservationId,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reservationId));
              // TODO: Afficher un snackbar de confirmation
            },
            icon: Icon(
              Icons.copy,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Copier le numéro',
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(
    ThemeData theme,
    ReservationFlowState state,
    ReservationFlowNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de la réservation',
          style: theme.textTheme.titleMedium?.copyWith(
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

  Widget _buildClientInfo(ThemeData theme, ReservationFlowState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations client',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          theme,
          Icons.person,
          'Nom',
          state.clientName,
        ),
        
        _buildDetailRow(
          theme,
          Icons.email,
          'Email',
          state.clientEmail,
        ),
        
        if (state.clientPhone.isNotEmpty) ...[
          _buildDetailRow(
            theme,
            Icons.phone,
            'Téléphone',
            state.clientPhone,
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
          'Détails financiers',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildFinancialRow(
          theme,
          'Estimation totale',
          '${estimatedTotal.toStringAsFixed(2)}€',
          isSubtotal: true,
        ),
        
        if (state.isPaymentRequired) ...[
          _buildFinancialRow(
            theme,
            'Acompte payé',
            '${state.depositAmount.toStringAsFixed(2)}€',
            isHighlighted: true,
            isPaid: state.isPaymentCompleted,
          ),
          
          _buildFinancialRow(
            theme,
            'Solde à payer sur place',
            '${(estimatedTotal - state.depositAmount).toStringAsFixed(2)}€',
            isSubtotal: true,
          ),
        ],
      ],
    );
  }

  Widget _buildManagementToken(ThemeData theme, String token) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key,
                color: theme.colorScheme.onSecondaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Token de gestion',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Ce token vous permet de modifier ou annuler votre réservation :',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    token,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    // TODO: Afficher un snackbar de confirmation
                  },
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Copier le token',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Lien de gestion : /manage-reservation?token=$token',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStatus(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: state.isEmailSent
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            state.isEmailSent ? Icons.email : Icons.email_outlined,
            color: state.isEmailSent
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.isEmailSent
                  ? 'Email de confirmation envoyé à ${state.clientEmail}'
                  : 'Email de confirmation en cours d\'envoi...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: state.isEmailSent
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onErrorContainer,
              ),
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
    bool isPaid = false,
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
          Row(
            children: [
              if (isPaid) ...[
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
              ],
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
