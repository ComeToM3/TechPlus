import 'package:flutter/material.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../generated/l10n/app_localizations.dart';

/// Dialog pour configurer la réservation avancée
class AdvanceBookingDialog extends StatefulWidget {
  final int currentMaxAdvanceDays;
  final Function(int) onMaxAdvanceDaysChanged;

  const AdvanceBookingDialog({
    super.key,
    required this.currentMaxAdvanceDays,
    required this.onMaxAdvanceDaysChanged,
  });

  @override
  State<AdvanceBookingDialog> createState() => _AdvanceBookingDialogState();
}

class _AdvanceBookingDialogState extends State<AdvanceBookingDialog> {
  late int _selectedMaxAdvanceDays;
  final List<int> _advanceDaysOptions = [7, 14, 30, 60, 90, 180];

  @override
  void initState() {
    super.initState();
    _selectedMaxAdvanceDays = widget.currentMaxAdvanceDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(l10n.maxAdvanceBooking),
        ],
      ),
      content: BentoCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.maxAdvanceBookingDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Options de jours d'avance
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _advanceDaysOptions.map((days) {
                final isSelected = _selectedMaxAdvanceDays == days;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMaxAdvanceDays = days;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${days} jours',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getAdvanceDaysDescription(days),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Jours d'avance personnalisés
            _buildCustomAdvanceDaysInput(theme, l10n),
            
            const SizedBox(height: 16),
            
            // Information sur l'impact
            _buildImpactInfo(theme, l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        SimpleButton(
          onPressed: _selectedMaxAdvanceDays != widget.currentMaxAdvanceDays
              ? () {
                  widget.onMaxAdvanceDaysChanged(_selectedMaxAdvanceDays);
                  Navigator.of(context).pop();
                }
              : null,
          text: l10n.save,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildCustomAdvanceDaysInput(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jours d\'avance personnalisés',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Entrez le nombre de jours',
                  suffixText: 'jours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  final days = int.tryParse(value);
                  if (days != null && days > 0 && days <= 365) {
                    setState(() {
                      _selectedMaxAdvanceDays = days;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            SimpleButton(
              onPressed: () {
                // Appliquer les jours d'avance personnalisés
                widget.onMaxAdvanceDaysChanged(_selectedMaxAdvanceDays);
                Navigator.of(context).pop();
              },
              text: l10n.apply,
              type: ButtonType.secondary,
              size: ButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactInfo(ThemeData theme, AppLocalizations l10n) {
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
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Impact sur les réservations',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getImpactDescription(_selectedMaxAdvanceDays),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getAdvanceDaysDescription(int days) {
    if (days <= 7) {
      return 'Court terme';
    } else if (days <= 30) {
      return 'Moyen terme';
    } else if (days <= 90) {
      return 'Long terme';
    } else {
      return 'Très long terme';
    }
  }

  String _getImpactDescription(int days) {
    if (days <= 7) {
      return 'Les clients peuvent réserver jusqu\'à ${days} jours à l\'avance. Idéal pour les réservations spontanées.';
    } else if (days <= 30) {
      return 'Les clients peuvent réserver jusqu\'à ${days} jours à l\'avance. Équilibre entre flexibilité et planification.';
    } else if (days <= 90) {
      return 'Les clients peuvent réserver jusqu\'à ${days} jours à l\'avance. Permet une planification avancée.';
    } else {
      return 'Les clients peuvent réserver jusqu\'à ${days} jours à l\'avance. Idéal pour les événements spéciaux.';
    }
  }
}
