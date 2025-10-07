import 'package:flutter/material.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../domain/entities/schedule_entity.dart';

/// Dialog pour ajouter ou modifier un créneau horaire
class AddTimeSlotDialog extends StatefulWidget {
  final DayOfWeek dayOfWeek;
  final TimeSlot? initialTimeSlot;
  final Function(TimeSlot) onTimeSlotAdded;

  const AddTimeSlotDialog({
    super.key,
    required this.dayOfWeek,
    this.initialTimeSlot,
    required this.onTimeSlotAdded,
  });

  @override
  State<AddTimeSlotDialog> createState() => _AddTimeSlotDialogState();
}

class _AddTimeSlotDialogState extends State<AddTimeSlotDialog> {
  late final TextEditingController _timeController;
  late final TextEditingController _capacityController;
  late bool _isAvailable;
  late bool _isRecommended;
  final List<String> _presetTimes = [
    '12:00', '12:30', '13:00', '13:30', '14:00',
    '19:00', '19:30', '20:00', '20:30', '21:00', '21:30'
  ];

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.initialTimeSlot?.time ?? '');
    _capacityController = TextEditingController(text: widget.initialTimeSlot?.capacity.toString() ?? '20');
    _isAvailable = widget.initialTimeSlot?.isAvailable ?? true;
    _isRecommended = widget.initialTimeSlot?.isRecommended ?? false;
  }

  @override
  void dispose() {
    _timeController.dispose();
    _capacityController.dispose();
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
            widget.initialTimeSlot != null ? Icons.edit : Icons.add,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text('${widget.initialTimeSlot != null ? 'Modifier' : 'Ajouter'} un créneau - ${widget.dayOfWeek.getLocalizedName('fr')}'),
        ],
      ),
      content: BentoCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Heure du créneau
            _buildTimeInput(theme, l10n),
            
            const SizedBox(height: 16),
            
            // Capacité
            _buildCapacityInput(theme, l10n),
            
            const SizedBox(height: 16),
            
            // Options
            _buildOptions(theme, l10n),
            
            const SizedBox(height: 16),
            
            // Créneaux prédéfinis
            _buildPresetTimes(theme, l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        SimpleButton(
          onPressed: _isValidInput() ? _addTimeSlot : null,
          text: widget.initialTimeSlot != null ? 'Modifier' : 'Ajouter',
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildTimeInput(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.time,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _timeController,
          decoration: InputDecoration(
            hintText: 'HH:MM (ex: 19:30)',
            prefixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCapacityInput(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.capacity,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _capacityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nombre de personnes',
            prefixIcon: const Icon(Icons.people),
            suffixText: 'personnes',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildOptions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.options,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.available),
          subtitle: Text('Permet aux clients de réserver ce créneau'),
          value: _isAvailable,
          onChanged: (value) {
            setState(() {
              _isAvailable = value;
            });
          },
        ),
        SwitchListTile(
          title: Text(l10n.recommended),
          subtitle: Text('Mettre en avant ce créneau pour les clients'),
          value: _isRecommended,
          onChanged: (value) {
            setState(() {
              _isRecommended = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPresetTimes(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux prédéfinis',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetTimes.map((time) {
            final isSelected = _timeController.text == time;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _timeController.text = time;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Text(
                  time,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isValidInput() {
    final time = _timeController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim());
    
    if (time.isEmpty || capacity == null || capacity <= 0) {
      return false;
    }
    
    // Validation du format de l'heure
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(time)) {
      return false;
    }
    
    return true;
  }

  void _addTimeSlot() {
    if (!_isValidInput()) return;
    
    final time = _timeController.text.trim();
    final capacity = int.parse(_capacityController.text.trim());
    
    final timeSlot = TimeSlot(
      time: time,
      isAvailable: _isAvailable,
      capacity: capacity,
      isRecommended: _isRecommended,
    );
    
    widget.onTimeSlotAdded(timeSlot);
    Navigator.of(context).pop();
  }
}
