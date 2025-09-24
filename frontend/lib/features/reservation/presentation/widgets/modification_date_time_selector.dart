import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget pour sélectionner la nouvelle date et heure lors de la modification
class ModificationDateTimeSelector extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final String initialTime;
  final Function(DateTime date, String time) onDateTimeChanged;

  const ModificationDateTimeSelector({
    super.key,
    required this.initialDate,
    required this.initialTime,
    required this.onDateTimeChanged,
  });

  @override
  ConsumerState<ModificationDateTimeSelector> createState() => _ModificationDateTimeSelectorState();
}

class _ModificationDateTimeSelectorState extends ConsumerState<ModificationDateTimeSelector> {
  late DateTime _selectedDate;
  late String _selectedTime;
  late DateTime _focusedDay;

  // Créneaux horaires disponibles
  final List<String> _availableTimeSlots = [
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _focusedDay = widget.initialDate;
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
                  Icons.calendar_today,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nouvelle date et heure',
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
                // Calendrier
                _buildCalendar(theme),
                
                const SizedBox(height: 24),
                
                // Sélection de l'heure
                _buildTimeSelector(theme),
                
                const SizedBox(height: 16),
                
                // Résumé de la sélection
                _buildSelectionSummary(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez une nouvelle date',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        TableCalendar<dynamic>(
          firstDay: DateTime.now().add(const Duration(days: 1)),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDate, selectedDay)) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateTimeChanged(_selectedDate, _selectedTime);
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: theme.colorScheme.primary,
            ),
            holidayTextStyle: TextStyle(
              color: theme.colorScheme.primary,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            defaultDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            weekendDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(fontWeight: FontWeight.bold),
            weekendStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ) ?? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez une nouvelle heure',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Grille des créneaux horaires
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _availableTimeSlots.length,
          itemBuilder: (context, index) {
            final timeSlot = _availableTimeSlots[index];
            final isSelected = _selectedTime == timeSlot;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = timeSlot;
                });
                widget.onDateTimeChanged(_selectedDate, _selectedTime);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    timeSlot,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectionSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle réservation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(_selectedDate)} à $_selectedTime',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
