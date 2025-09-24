import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour afficher la notification de confirmation d'annulation
class CancellationNotificationWidget extends ConsumerWidget {
  final String reservationId;
  final DateTime reservationDate;
  final String reservationTime;
  final int partySize;
  final String clientName;
  final String cancellationReason;
  final bool isRefundable;
  final double refundAmount;
  final String? refundStatus;
  final VoidCallback onClose;
  final VoidCallback? onViewDetails;

  const CancellationNotificationWidget({
    super.key,
    required this.reservationId,
    required this.reservationDate,
    required this.reservationTime,
    required this.partySize,
    required this.clientName,
    required this.cancellationReason,
    required this.isRefundable,
    required this.refundAmount,
    this.refundStatus,
    required this.onClose,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                  Icons.check_circle,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Annulation confirmée',
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
                // Message de confirmation
                _buildConfirmationMessage(theme),
                
                const SizedBox(height: 16),
                
                // Détails de l'annulation
                _buildCancellationDetails(theme),
                
                const SizedBox(height: 16),
                
                // Informations de remboursement
                if (isRefundable) _buildRefundInformation(theme),
                
                const SizedBox(height: 16),
                
                // Prochaines étapes
                _buildNextSteps(theme),
                
                const SizedBox(height: 24),
                
                // Actions
                _buildActions(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationMessage(ThemeData theme) {
    return Container(
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
              'Votre réservation a été annulée avec succès. Vous recevrez un email de confirmation sous peu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'annulation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildDetailRow(theme, 'N° Réservation', reservationId),
          _buildDetailRow(theme, 'Nom', clientName),
          _buildDetailRow(theme, 'Date', DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(reservationDate)),
          _buildDetailRow(theme, 'Heure', reservationTime),
          _buildDetailRow(theme, 'Personnes', '${partySize} ${partySize == 1 ? 'personne' : 'personnes'}'),
          _buildDetailRow(theme, 'Motif', cancellationReason),
          _buildDetailRow(theme, 'Date d\'annulation', DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildRefundInformation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Remboursement',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          _buildRefundRow(theme, 'Montant', '${refundAmount.toStringAsFixed(2)}€'),
          _buildRefundRow(theme, 'Statut', _formatRefundStatus(refundStatus)),
          _buildRefundRow(theme, 'Délai', '3-5 jours ouvrés'),
          _buildRefundRow(theme, 'Méthode', 'Même moyen de paiement'),
        ],
      ),
    );
  }

  Widget _buildNextSteps(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaines étapes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildStepItem(theme, '1', 'Email de confirmation reçu'),
          _buildStepItem(theme, '2', isRefundable ? 'Remboursement en cours' : 'Aucun remboursement'),
          _buildStepItem(theme, '3', 'Nouvelle réservation possible'),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            onPressed: onClose,
            text: 'Fermer',
            icon: Icons.close,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        if (onViewDetails != null) ...[
          const SizedBox(width: 16),
          
          Expanded(
            child: AnimatedButton(
              onPressed: onViewDetails,
              text: 'Voir les détails',
              icon: Icons.visibility,
              type: ButtonType.primary,
              size: ButtonSize.large,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ThemeData theme, String step, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRefundStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return 'En cours';
      case 'PROCESSING':
        return 'Traitement';
      case 'COMPLETED':
        return 'Terminé';
      case 'FAILED':
        return 'Échoué';
      default:
        return 'En attente';
    }
  }
}
