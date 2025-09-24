import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Widget pour afficher la politique de remboursement lors de l'annulation
class RefundPolicyWidget extends ConsumerWidget {
  final DateTime reservationDate;
  final String reservationTime;
  final bool hasPayment;
  final double depositAmount;
  final String? paymentStatus;

  const RefundPolicyWidget({
    super.key,
    required this.reservationDate,
    required this.reservationTime,
    required this.hasPayment,
    required this.depositAmount,
    this.paymentStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final refundInfo = _calculateRefundInfo();

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
              color: refundInfo.isRefundable 
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.errorContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  refundInfo.isRefundable ? Icons.monetization_on : Icons.cancel,
                  color: refundInfo.isRefundable 
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Politique de remboursement',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: refundInfo.isRefundable 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
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
                _buildReservationInfo(theme, refundInfo),
                
                const SizedBox(height: 16),
                
                // Statut du remboursement
                _buildRefundStatus(theme, refundInfo),
                
                const SizedBox(height: 16),
                
                // Détails de la politique
                _buildPolicyDetails(theme, refundInfo),
                
                const SizedBox(height: 16),
                
                // Actions recommandées
                _buildRecommendedActions(theme, refundInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationInfo(ThemeData theme, RefundInfo refundInfo) {
    final timeParts = reservationTime.split(':');
    final fullReservationDateTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    
    final timeUntilReservation = fullReservationDateTime.difference(DateTime.now());
    final hoursUntilReservation = timeUntilReservation.inHours;
    final daysUntilReservation = timeUntilReservation.inDays;

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
            'Détails de la réservation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildInfoRow(theme, 'Date', DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(reservationDate)),
          _buildInfoRow(theme, 'Heure', reservationTime),
          _buildInfoRow(theme, 'Temps restant', _formatTimeRemaining(daysUntilReservation, hoursUntilReservation)),
          
          if (hasPayment) ...[
            _buildInfoRow(theme, 'Acompte payé', '${depositAmount.toStringAsFixed(2)}€'),
            _buildInfoRow(theme, 'Statut paiement', _formatPaymentStatus(paymentStatus)),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundStatus(ThemeData theme, RefundInfo refundInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: refundInfo.isRefundable 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: refundInfo.isRefundable 
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            refundInfo.isRefundable ? Icons.check_circle : Icons.cancel,
            color: refundInfo.isRefundable 
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  refundInfo.isRefundable ? 'Remboursement possible' : 'Aucun remboursement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: refundInfo.isRefundable 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  refundInfo.refundMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: refundInfo.isRefundable 
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
                
                if (refundInfo.refundAmount > 0) ...[
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Remboursement: ${refundInfo.refundAmount.toStringAsFixed(2)}€',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
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

  Widget _buildPolicyDetails(ThemeData theme, RefundInfo refundInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Politique d\'annulation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        _buildPolicyItem(
          theme,
          'Plus de 24h avant',
          'Remboursement complet automatique',
          Icons.check_circle,
          Colors.green,
        ),
        
        _buildPolicyItem(
          theme,
          'Moins de 24h avant',
          'Aucun remboursement (acompte perdu)',
          Icons.cancel,
          Colors.red,
        ),
        
        _buildPolicyItem(
          theme,
          'No-show (absence)',
          'Aucun remboursement (acompte perdu)',
          Icons.cancel,
          Colors.red,
        ),
        
        _buildPolicyItem(
          theme,
          'Annulation par le restaurant',
          'Remboursement complet',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildPolicyItem(ThemeData theme, String condition, String result, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
                  condition,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                Text(
                  result,
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

  Widget _buildRecommendedActions(ThemeData theme, RefundInfo refundInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommandations',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          
          const SizedBox(height: 8),
          
          if (refundInfo.isRefundable) ...[
            Text(
              '• Vous pouvez annuler sans frais',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '• Le remboursement sera traité automatiquement',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '• Vous recevrez un email de confirmation',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ] else ...[
            Text(
              '• L\'annulation entraînera la perte de l\'acompte',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '• Considérez modifier plutôt qu\'annuler',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '• Contactez-nous en cas de force majeure',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
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

  RefundInfo _calculateRefundInfo() {
    final timeParts = reservationTime.split(':');
    final fullReservationDateTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    
    final timeUntilReservation = fullReservationDateTime.difference(DateTime.now());
    final hoursUntilReservation = timeUntilReservation.inHours;
    
    final isRefundable = hoursUntilReservation > 24;
    
    if (!hasPayment) {
      return RefundInfo(
        isRefundable: true,
        refundAmount: 0.0,
        refundMessage: 'Aucun acompte payé - annulation gratuite',
      );
    }
    
    if (isRefundable) {
      return RefundInfo(
        isRefundable: true,
        refundAmount: depositAmount,
        refundMessage: 'Remboursement complet de l\'acompte (${depositAmount.toStringAsFixed(2)}€)',
      );
    } else {
      return RefundInfo(
        isRefundable: false,
        refundAmount: 0.0,
        refundMessage: 'Aucun remboursement - moins de 24h avant la réservation',
      );
    }
  }

  String _formatTimeRemaining(int days, int hours) {
    if (days > 0) {
      return '$days jour${days > 1 ? 's' : ''} et ${hours % 24}h';
    } else if (hours > 0) {
      return '$hours heure${hours > 1 ? 's' : ''}';
    } else {
      return 'Moins d\'une heure';
    }
  }

  String _formatPaymentStatus(String? status) {
    switch (status) {
      case 'COMPLETED':
        return 'Payé';
      case 'PENDING':
        return 'En attente';
      case 'FAILED':
        return 'Échoué';
      case 'REFUNDED':
        return 'Remboursé';
      default:
        return 'Inconnu';
    }
  }
}

class RefundInfo {
  final bool isRefundable;
  final double refundAmount;
  final String refundMessage;

  RefundInfo({
    required this.isRefundable,
    required this.refundAmount,
    required this.refundMessage,
  });
}
