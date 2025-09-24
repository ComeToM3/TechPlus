import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour valider et confirmer les modifications
class ModificationValidationWidget extends ConsumerWidget {
  final DateTime newDate;
  final String newTime;
  final int newPartySize;
  final String newName;
  final String newEmail;
  final String newPhone;
  final String newSpecialRequests;
  final DateTime originalDate;
  final String originalTime;
  final int originalPartySize;
  final String originalName;
  final String originalEmail;
  final String originalPhone;
  final String originalSpecialRequests;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const ModificationValidationWidget({
    super.key,
    required this.newDate,
    required this.newTime,
    required this.newPartySize,
    required this.newName,
    required this.newEmail,
    required this.newPhone,
    required this.newSpecialRequests,
    required this.originalDate,
    required this.originalTime,
    required this.originalPartySize,
    required this.originalName,
    required this.originalEmail,
    required this.originalPhone,
    required this.originalSpecialRequests,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final changes = _getChanges();

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
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Validation des modifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
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
                // Résumé des changements
                _buildChangesSummary(theme, changes),
                
                const SizedBox(height: 24),
                
                // Comparaison avant/après
                _buildComparison(theme, changes),
                
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

  Widget _buildChangesSummary(ThemeData theme, List<ChangeItem> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé des modifications',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (changes.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aucune modification détectée',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...changes.map((change) => _buildChangeItem(theme, change)),
        ],
      ],
    );
  }

  Widget _buildChangeItem(ThemeData theme, ChangeItem change) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.secondary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            change.icon,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${change.oldValue} → ${change.newValue}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(ThemeData theme, List<ChangeItem> changes) {
    if (changes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparaison détaillée',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Avant
        _buildComparisonSection(
          theme,
          'Avant',
          originalDate,
          originalTime,
          originalPartySize,
          originalName,
          originalEmail,
          originalPhone,
          originalSpecialRequests,
          theme.colorScheme.surfaceContainerHighest,
        ),
        
        const SizedBox(height: 12),
        
        // Après
        _buildComparisonSection(
          theme,
          'Après',
          newDate,
          newTime,
          newPartySize,
          newName,
          newEmail,
          newPhone,
          newSpecialRequests,
          theme.colorScheme.primaryContainer,
        ),
      ],
    );
  }

  Widget _buildComparisonSection(
    ThemeData theme,
    String title,
    DateTime date,
    String time,
    int partySize,
    String name,
    String email,
    String phone,
    String specialRequests,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildComparisonRow(theme, 'Date', _formatDate(date)),
          _buildComparisonRow(theme, 'Heure', time),
          _buildComparisonRow(theme, 'Personnes', '$partySize ${partySize == 1 ? 'personne' : 'personnes'}'),
          _buildComparisonRow(theme, 'Nom', name),
          _buildComparisonRow(theme, 'Email', email),
          if (phone.isNotEmpty) _buildComparisonRow(theme, 'Téléphone', phone),
          if (specialRequests.isNotEmpty) _buildComparisonRow(theme, 'Demandes', specialRequests),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ThemeData theme, String label, String value) {
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
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            onPressed: isLoading ? null : onCancel,
            text: 'Annuler',
            icon: Icons.cancel,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: AnimatedButton(
            onPressed: isLoading ? null : onConfirm,
            text: 'Confirmer les modifications',
            icon: Icons.check,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  List<ChangeItem> _getChanges() {
    final changes = <ChangeItem>[];
    
    if (newDate != originalDate || newTime != originalTime) {
      changes.add(ChangeItem(
        icon: Icons.calendar_today,
        label: 'Date et heure',
        oldValue: '${_formatDate(originalDate)} à $originalTime',
        newValue: '${_formatDate(newDate)} à $newTime',
      ));
    }
    
    if (newPartySize != originalPartySize) {
      changes.add(ChangeItem(
        icon: Icons.people,
        label: 'Nombre de personnes',
        oldValue: '$originalPartySize ${originalPartySize == 1 ? 'personne' : 'personnes'}',
        newValue: '$newPartySize ${newPartySize == 1 ? 'personne' : 'personnes'}',
      ));
    }
    
    if (newName != originalName) {
      changes.add(ChangeItem(
        icon: Icons.person,
        label: 'Nom',
        oldValue: originalName,
        newValue: newName,
      ));
    }
    
    if (newEmail != originalEmail) {
      changes.add(ChangeItem(
        icon: Icons.email,
        label: 'Email',
        oldValue: originalEmail,
        newValue: newEmail,
      ));
    }
    
    if (newPhone != originalPhone) {
      changes.add(ChangeItem(
        icon: Icons.phone,
        label: 'Téléphone',
        oldValue: originalPhone.isEmpty ? 'Non renseigné' : originalPhone,
        newValue: newPhone.isEmpty ? 'Non renseigné' : newPhone,
      ));
    }
    
    if (newSpecialRequests != originalSpecialRequests) {
      changes.add(ChangeItem(
        icon: Icons.note,
        label: 'Demandes spéciales',
        oldValue: originalSpecialRequests.isEmpty ? 'Aucune' : originalSpecialRequests,
        newValue: newSpecialRequests.isEmpty ? 'Aucune' : newSpecialRequests,
      ));
    }
    
    return changes;
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class ChangeItem {
  final IconData icon;
  final String label;
  final String oldValue;
  final String newValue;

  ChangeItem({
    required this.icon,
    required this.label,
    required this.oldValue,
    required this.newValue,
  });
}
