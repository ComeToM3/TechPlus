import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Sélecteur de créneaux horaires
class TimeSlotSelector extends ConsumerWidget {
  final String? selectedTime;
  final List<String> availableTimes;
  final Function(String) onTimeSelected;

  const TimeSlotSelector({
    super.key,
    this.selectedTime,
    required this.availableTimes,
    required this.onTimeSelected,
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
                  Icons.access_time,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sélectionnez un créneau',
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
                // Message d'information
                if (reservationState.selectedDate != null)
                  Container(
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
                            'Créneaux disponibles pour le ${_formatDate(reservationState.selectedDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Grille des créneaux
                if (availableTimes.isEmpty)
                  _buildNoSlotsAvailable(theme)
                else
                  _buildTimeSlotsGrid(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSlotsAvailable(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun créneau disponible',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez sélectionner une autre date',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsGrid(ThemeData theme) {
    // Grouper les créneaux par période (midi/soir)
    final lunchSlots = availableTimes.where((time) {
      final hour = int.parse(time.split(':')[0]);
      return hour >= 12 && hour < 15;
    }).toList();
    
    final dinnerSlots = availableTimes.where((time) {
      final hour = int.parse(time.split(':')[0]);
      return hour >= 19 && hour < 23;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Créneaux du midi
        if (lunchSlots.isNotEmpty) ...[
          _buildTimePeriodHeader(theme, 'Midi', Icons.wb_sunny),
          const SizedBox(height: 12),
          _buildTimeSlotsRow(theme, lunchSlots),
          const SizedBox(height: 20),
        ],
        
        // Créneaux du soir
        if (dinnerSlots.isNotEmpty) ...[
          _buildTimePeriodHeader(theme, 'Soir', Icons.nights_stay),
          const SizedBox(height: 12),
          _buildTimeSlotsRow(theme, dinnerSlots),
        ],
      ],
    );
  }

  Widget _buildTimePeriodHeader(ThemeData theme, String period, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          period,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsRow(ThemeData theme, List<String> slots) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((time) {
        final isSelected = selectedTime == time;
        return _buildTimeSlotChip(theme, time, isSelected);
      }).toList(),
    );
  }

  Widget _buildTimeSlotChip(ThemeData theme, String time, bool isSelected) {
    return GestureDetector(
      onTap: () => onTimeSelected(time),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
