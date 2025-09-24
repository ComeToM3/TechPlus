import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Sélecteur du nombre de personnes
class PartySizeSelector extends ConsumerWidget {
  final int partySize;
  final Function(int) onPartySizeChanged;

  const PartySizeSelector({
    super.key,
    required this.partySize,
    required this.onPartySizeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

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
                  Icons.people,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nombre de personnes',
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
                // Sélecteur principal
                _buildMainSelector(theme),
                
                const SizedBox(height: 16),
                
                // Informations sur la durée
                _buildDurationInfo(theme, reservationState.partySize),
                
                const SizedBox(height: 16),
                
                // Information sur le paiement
                if (reservationState.partySize >= 6)
                  _buildPaymentInfo(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSelector(ThemeData theme) {
    return Row(
      children: [
        // Bouton moins
        _buildCounterButton(
          theme,
          Icons.remove,
          () => onPartySizeChanged(partySize - 1),
          partySize > 1,
        ),
        
        const SizedBox(width: 16),
        
        // Affichage du nombre
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$partySize',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  partySize == 1 ? 'personne' : 'personnes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Bouton plus
        _buildCounterButton(
          theme,
          Icons.add,
          () => onPartySizeChanged(partySize + 1),
          partySize < 12,
        ),
      ],
    );
  }

  Widget _buildCounterButton(ThemeData theme, IconData icon, VoidCallback onPressed, bool enabled) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: enabled
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          color: enabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDurationInfo(ThemeData theme, int partySize) {
    final duration = partySize <= 4 ? 90 : 120;
    final durationText = duration == 90 ? '1h30' : '2h00';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Durée de réservation: $durationText',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.tertiary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: theme.colorScheme.onTertiaryContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Paiement requis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Un acompte de 10€ est requis pour les réservations de 6 personnes et plus.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
