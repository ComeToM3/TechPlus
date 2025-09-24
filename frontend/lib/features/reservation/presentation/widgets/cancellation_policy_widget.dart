import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Widget pour afficher la politique d'annulation
class CancellationPolicyWidget extends ConsumerWidget {
  const CancellationPolicyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  Icons.info_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Politique d\'annulation',
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
                if (reservationState.isPaymentRequired) ...[
                  // Politique avec paiement
                  _buildPaymentRequiredPolicy(theme, reservationState),
                ] else ...[
                  // Politique sans paiement
                  _buildNoPaymentPolicy(theme),
                ],
                
                const SizedBox(height: 16),
                
                // Informations supplémentaires
                _buildAdditionalInfo(theme, reservationState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRequiredPolicy(ThemeData theme, ReservationFlowState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Montant de l'acompte
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.payment,
                color: theme.colorScheme.onTertiaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Acompte requis : ${state.depositAmount.toStringAsFixed(2)}€',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Règles de remboursement
        Text(
          'Règles de remboursement :',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        _buildPolicyItem(
          theme,
          Icons.check_circle,
          'Plus de 24h avant',
          'Remboursement complet automatique',
          theme.colorScheme.primary,
        ),
        
        _buildPolicyItem(
          theme,
          Icons.cancel,
          'Moins de 24h avant',
          'Aucun remboursement (acompte perdu)',
          theme.colorScheme.error,
        ),
        
        _buildPolicyItem(
          theme,
          Icons.person_off,
          'No-show (absence)',
          'Aucun remboursement (acompte perdu)',
          theme.colorScheme.error,
        ),
        
        _buildPolicyItem(
          theme,
          Icons.restaurant,
          'Annulation par le restaurant',
          'Remboursement complet',
          theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildNoPaymentPolicy(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.onSecondaryContainer,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun paiement requis',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cette réservation ne nécessite pas d\'acompte.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations importantes',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• L\'acompte sera débité immédiatement après confirmation du paiement\n'
            '• Les remboursements sont traités automatiquement selon les conditions ci-dessus\n'
            '• En cas de problème, contactez-nous au +33 1 23 45 67 89',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
