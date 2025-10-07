import 'package:flutter/material.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../generated/l10n/app_localizations.dart';

/// Dialog pour modifier le temps de pause entre les créneaux
class BufferTimeDialog extends StatefulWidget {
  final int currentBufferTime;
  final Function(int) onBufferTimeChanged;

  const BufferTimeDialog({
    super.key,
    required this.currentBufferTime,
    required this.onBufferTimeChanged,
  });

  @override
  State<BufferTimeDialog> createState() => _BufferTimeDialogState();
}

class _BufferTimeDialogState extends State<BufferTimeDialog> {
  late int _selectedBufferTime;
  final List<int> _bufferTimeOptions = [0, 5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _selectedBufferTime = widget.currentBufferTime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.pause,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(l10n.bufferTime),
        ],
      ),
      content: BentoCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bufferTimeDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Options de temps de pause
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _bufferTimeOptions.map((bufferTime) {
                final isSelected = _selectedBufferTime == bufferTime;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBufferTime = bufferTime;
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
                          '${bufferTime}min',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getBufferTimeDescription(bufferTime),
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
            
            // Temps de pause personnalisé
            _buildCustomBufferTimeInput(theme, l10n),
            
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
          onPressed: _selectedBufferTime != widget.currentBufferTime
              ? () {
                  widget.onBufferTimeChanged(_selectedBufferTime);
                  Navigator.of(context).pop();
                }
              : null,
          text: l10n.save,
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildCustomBufferTimeInput(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temps de pause personnalisé',
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
                  hintText: 'Entrez le temps de pause',
                  suffixText: 'min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  final bufferTime = int.tryParse(value);
                  if (bufferTime != null && bufferTime >= 0 && bufferTime <= 60) {
                    setState(() {
                      _selectedBufferTime = bufferTime;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            SimpleButton(
              onPressed: () {
                // Appliquer le temps de pause personnalisé
                widget.onBufferTimeChanged(_selectedBufferTime);
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
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getImpactDescription(_selectedBufferTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBufferTimeDescription(int bufferTime) {
    switch (bufferTime) {
      case 0:
        return 'Aucune pause';
      case 5:
        return 'Pause courte';
      case 10:
        return 'Pause standard';
      case 15:
        return 'Pause confortable';
      case 20:
        return 'Pause longue';
      case 30:
        return 'Pause très longue';
      default:
        return 'Personnalisé';
    }
  }

  String _getImpactDescription(int bufferTime) {
    if (bufferTime == 0) {
      return 'Aucune pause entre les créneaux. Risque de chevauchement.';
    } else if (bufferTime <= 10) {
      return 'Pause minimale. Permet le nettoyage rapide entre les réservations.';
    } else if (bufferTime <= 20) {
      return 'Pause standard. Temps suffisant pour le nettoyage et la préparation.';
    } else {
      return 'Pause longue. Temps généreux pour le nettoyage et la préparation.';
    }
  }
}
