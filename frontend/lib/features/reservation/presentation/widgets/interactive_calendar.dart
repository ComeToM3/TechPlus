import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calendrier interactif pour la sélection de date
class InteractiveCalendar extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime> availableDates;

  const InteractiveCalendar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    required this.availableDates,
  });

  @override
  ConsumerState<InteractiveCalendar> createState() => _InteractiveCalendarState();
}

class _InteractiveCalendarState extends ConsumerState<InteractiveCalendar> {
  late PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _pageController = PageController(
      initialPage: _getInitialPage(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getInitialPage() {
    final now = DateTime.now();
    final monthsDiff = (widget.selectedDate?.year ?? now.year) * 12 + 
                      (widget.selectedDate?.month ?? now.month) - 
                      (now.year * 12 + now.month);
    return monthsDiff;
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
        children: [
          // Header du calendrier
          _buildCalendarHeader(theme),
          
          // Calendrier
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                final newMonth = DateTime.now().add(Duration(days: index * 30));
                setState(() {
                  _currentMonth = DateTime(newMonth.year, newMonth.month, 1);
                });
              },
              itemBuilder: (context, index) {
                final month = DateTime.now().add(Duration(days: index * 30));
                return _buildMonthCalendar(theme, month);
              },
            ),
          ),
          
          // Indicateurs de navigation
          _buildNavigationIndicators(theme),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getMonthYearText(_currentMonth),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              
              IconButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(ThemeData theme, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Générer les jours du mois
    final daysInMonth = lastDayOfMonth.day;
    final days = <Widget>[];
    
    // Ajouter les jours de la semaine précédente (vides)
    for (int i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }
    
    // Ajouter les jours du mois
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      days.add(_buildDayCell(theme, date));
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-têtes des jours de la semaine
          _buildWeekdayHeaders(theme),
          
          const SizedBox(height: 8),
          
          // Grille des jours
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: days,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    final weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(ThemeData theme, DateTime date) {
    final isSelected = widget.selectedDate != null &&
        date.year == widget.selectedDate!.year &&
        date.month == widget.selectedDate!.month &&
        date.day == widget.selectedDate!.day;
    
    final isAvailable = _isDateAvailable(date);
    final isToday = _isToday(date);
    final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return GestureDetector(
      onTap: isAvailable ? () => widget.onDateSelected(date) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : isPast
                      ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
                      : isAvailable
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationIndicators(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.circle,
            size: 8,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.circle,
            size: 8,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isDateAvailable(DateTime date) {
    // Vérifier si la date est dans la liste des dates disponibles
    return widget.availableDates.any((availableDate) =>
        availableDate.year == date.year &&
        availableDate.month == date.month &&
        availableDate.day == date.day);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
