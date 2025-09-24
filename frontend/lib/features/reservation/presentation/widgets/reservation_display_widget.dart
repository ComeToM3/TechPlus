import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guest_management_provider.dart';

/// Widget pour afficher les détails de la réservation
class ReservationDisplayWidget extends ConsumerWidget {
  const ReservationDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);

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
                  Icons.restaurant,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de votre réservation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (guestState.reservationId != null)
                        Text(
                          'N° ${guestState.reservationId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
                // Statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(theme, guestState.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFormattedStatus(guestState.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                // Informations de la réservation
                _buildReservationInfo(theme, guestState),
                
                const SizedBox(height: 16),
                
                // Informations client
                _buildClientInfo(theme, guestState),
                
                const SizedBox(height: 16),
                
                // Détails financiers
                _buildFinancialInfo(theme, guestState),
                
                const SizedBox(height: 16),
                
                // Politique d'annulation
                if (guestState.cancellationPolicy != null)
                  _buildCancellationPolicy(theme, guestState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationInfo(ThemeData theme, GuestManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de la réservation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildInfoRow(
          theme,
          Icons.calendar_today,
          'Date',
          _formatDate(state.reservationDate!),
        ),
        
        _buildInfoRow(
          theme,
          Icons.access_time,
          'Heure',
          state.reservationTime!,
        ),
        
        _buildInfoRow(
          theme,
          Icons.people,
          'Nombre de personnes',
          '${state.partySize} ${state.partySize == 1 ? 'personne' : 'personnes'}',
        ),
        
        _buildInfoRow(
          theme,
          Icons.schedule,
          'Durée',
          state.partySize! <= 4 ? '1h30' : '2h00',
        ),
        
        if (state.specialRequests != null && state.specialRequests!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            Icons.note,
            'Demandes spéciales',
            state.specialRequests!,
            isMultiline: true,
          ),
        ],
      ],
    );
  }

  Widget _buildClientInfo(ThemeData theme, GuestManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations client',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildInfoRow(
          theme,
          Icons.person,
          'Nom',
          state.clientName!,
        ),
        
        _buildInfoRow(
          theme,
          Icons.email,
          'Email',
          state.clientEmail!,
        ),
        
        if (state.clientPhone != null && state.clientPhone!.isNotEmpty) ...[
          _buildInfoRow(
            theme,
            Icons.phone,
            'Téléphone',
            state.clientPhone!,
          ),
        ],
      ],
    );
  }

  Widget _buildFinancialInfo(ThemeData theme, GuestManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails financiers',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (state.depositAmount != null && state.depositAmount! > 0) ...[
          _buildFinancialRow(
            theme,
            'Acompte',
            '${state.depositAmount!.toStringAsFixed(2)}€',
            isPaid: state.isPaymentCompleted ?? false,
          ),
          
          if (state.isPaymentCompleted == true) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Acompte payé',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aucun acompte requis pour cette réservation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCancellationPolicy(ThemeData theme, GuestManagementState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Politique d\'annulation',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            state.cancellationPolicy!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
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
              color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'NO_SHOW':
        return Colors.red;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getFormattedStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmée';
      case 'CANCELLED':
        return 'Annulée';
      case 'COMPLETED':
        return 'Terminée';
      case 'NO_SHOW':
        return 'Absence';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
