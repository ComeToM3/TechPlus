import 'package:flutter/material.dart';
import '../../../../../generated/l10n/app_localizations.dart';

/// Dialog pour configurer la durée des créneaux
class SlotDurationDialog extends StatefulWidget {
  final int currentDuration;
  final Function(int) onDurationChanged;

  const SlotDurationDialog({
    super.key,
    required this.currentDuration,
    required this.onDurationChanged,
  });

  @override
  State<SlotDurationDialog> createState() => _SlotDurationDialogState();
}

class _SlotDurationDialogState extends State<SlotDurationDialog> {
  late int _selectedDuration;
  final TextEditingController _customController = TextEditingController();

  // Durées prédéfinies
  final List<int> _presetDurations = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.currentDuration;
    if (!_presetDurations.contains(_selectedDuration)) {
      _customController.text = _selectedDuration.toString();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.access_time,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text('Durée des créneaux'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez la durée des créneaux de réservation :',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Durées prédéfinies
            Text(
              'Durées recommandées :',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetDurations.map((duration) {
                final isSelected = _selectedDuration == duration;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                      _customController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$duration min',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Durée personnalisée
            Text(
              'Durée personnalisée :',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Entrez la durée en minutes',
                suffixText: 'min',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                final duration = int.tryParse(value);
                if (duration != null && duration > 0) {
                  setState(() {
                    _selectedDuration = duration;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Aperçu
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
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les créneaux seront de $_selectedDuration minutes',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            widget.onDurationChanged(_selectedDuration);
            Navigator.of(context).pop();
          },
          child: Text('Confirmer'),
        ),
      ],
    );
  }
}