import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget pour modifier le nombre de personnes lors de la modification
class ModificationPartySizeSelector extends ConsumerStatefulWidget {
  final int initialPartySize;
  final Function(int partySize) onPartySizeChanged;

  const ModificationPartySizeSelector({
    super.key,
    required this.initialPartySize,
    required this.onPartySizeChanged,
  });

  @override
  ConsumerState<ModificationPartySizeSelector> createState() => _ModificationPartySizeSelectorState();
}

class _ModificationPartySizeSelectorState extends ConsumerState<ModificationPartySizeSelector> {
  late int _selectedPartySize;

  @override
  void initState() {
    super.initState();
    _selectedPartySize = widget.initialPartySize;
  }

  @override
  Widget build(BuildContext context) {
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
                // Sélecteur de nombre de personnes
                _buildPartySizeSelector(theme),
                
                const SizedBox(height: 16),
                
                // Informations sur la durée
                _buildDurationInfo(theme),
                
                const SizedBox(height: 16),
                
                // Informations sur le paiement
                _buildPaymentInfo(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartySizeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez le nouveau nombre de personnes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Sélecteur avec boutons + et -
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouton -
            IconButton(
              onPressed: _selectedPartySize > 1 ? () => _decreasePartySize() : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
                shape: const CircleBorder(),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Affichage du nombre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$_selectedPartySize',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    _selectedPartySize == 1 ? 'personne' : 'personnes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Bouton +
            IconButton(
              onPressed: _selectedPartySize < 12 ? () => _increasePartySize() : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Indicateur de plage
        Center(
          child: Text(
            'Entre 1 et 12 personnes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(ThemeData theme) {
    final duration = _selectedPartySize <= 4 ? '1h30' : '2h00';
    final isChanged = _selectedPartySize != widget.initialPartySize;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChanged 
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isChanged 
              ? theme.colorScheme.secondary
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: isChanged 
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durée de la réservation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isChanged 
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isChanged 
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isChanged) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Durée mise à jour selon le nombre de personnes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontStyle: FontStyle.italic,
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

  Widget _buildPaymentInfo(ThemeData theme) {
    final requiresPayment = _selectedPartySize >= 6;
    final initialRequiresPayment = widget.initialPartySize >= 6;
    final isChanged = _selectedPartySize != widget.initialPartySize;
    
    if (!isChanged && !requiresPayment) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: requiresPayment 
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: requiresPayment 
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            requiresPayment ? Icons.payments : Icons.check_circle,
            color: requiresPayment 
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requiresPayment ? 'Paiement requis' : 'Aucun paiement requis',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: requiresPayment 
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  requiresPayment 
                      ? 'Un acompte de 10€ sera requis pour cette réservation'
                      : 'Cette réservation ne nécessite pas d\'acompte',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: requiresPayment 
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (isChanged && initialRequiresPayment != requiresPayment) ...[
                  const SizedBox(height: 4),
                  Text(
                    requiresPayment 
                        ? 'Paiement maintenant requis'
                        : 'Paiement plus nécessaire',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: requiresPayment 
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                      fontStyle: FontStyle.italic,
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

  void _increasePartySize() {
    if (_selectedPartySize < 12) {
      setState(() {
        _selectedPartySize++;
      });
      widget.onPartySizeChanged(_selectedPartySize);
    }
  }

  void _decreasePartySize() {
    if (_selectedPartySize > 1) {
      setState(() {
        _selectedPartySize--;
      });
      widget.onPartySizeChanged(_selectedPartySize);
    }
  }
}
