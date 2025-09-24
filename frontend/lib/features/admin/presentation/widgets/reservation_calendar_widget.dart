import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../providers/reservation_calendar_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget principal du calendrier des réservations
class ReservationCalendarWidget extends ConsumerStatefulWidget {
  final VoidCallback? onReservationTap;
  final VoidCallback? onCreateReservation;

  const ReservationCalendarWidget({
    super.key,
    this.onReservationTap,
    this.onCreateReservation,
  });

  @override
  ConsumerState<ReservationCalendarWidget> createState() => _ReservationCalendarWidgetState();
}

class _ReservationCalendarWidgetState extends ConsumerState<ReservationCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationCalendarProvider.notifier).changeSelectedDate(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calendarState = ref.watch(reservationCalendarProvider);

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec contrôles
            _buildHeader(context, l10n),
            const SizedBox(height: 16),
            
            // Calendrier
            _buildCalendar(context, calendarState, l10n),
            const SizedBox(height: 16),
            
            // Liste des réservations du jour sélectionné
            if (_selectedDay != null)
              _buildReservationsList(context, _selectedDay!, calendarState, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final calendarState = ref.watch(reservationCalendarProvider);

    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.reservationCalendar,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Bouton de vue mensuelle
        _buildViewButton(
          context,
          CalendarViewType.monthly,
          Icons.calendar_view_month,
          l10n.monthly,
          calendarState.viewType == CalendarViewType.monthly,
        ),
        const SizedBox(width: 8),
        
        // Bouton de vue hebdomadaire
        _buildViewButton(
          context,
          CalendarViewType.weekly,
          Icons.calendar_view_week,
          l10n.weekly,
          calendarState.viewType == CalendarViewType.weekly,
        ),
        const SizedBox(width: 8),
        
        // Bouton de vue quotidienne
        _buildViewButton(
          context,
          CalendarViewType.daily,
          Icons.calendar_view_day,
          l10n.daily,
          calendarState.viewType == CalendarViewType.daily,
        ),
        const SizedBox(width: 16),
        
        // Bouton de création
        ElevatedButton.icon(
          onPressed: widget.onCreateReservation,
          icon: const Icon(Icons.add),
          label: Text(l10n.createReservation),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(
    BuildContext context,
    CalendarViewType viewType,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        ref.read(reservationCalendarProvider.notifier).changeViewType(viewType);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    ReservationCalendarState calendarState,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return TableCalendar<ReservationCalendar>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: (day) => calendarState.reservations.where((reservation) {
        return reservation.date.year == day.year &&
               reservation.date.month == day.month &&
               reservation.date.day == day.day;
      }).toList(),
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
        holidayTextStyle: TextStyle(
          color: theme.colorScheme.error,
        ),
        defaultTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
        ),
        selectedTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 6,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ?? TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: theme.colorScheme.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          ref.read(reservationCalendarProvider.notifier).changeSelectedDate(selectedDay);
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        ref.read(reservationCalendarProvider.notifier).changeSelectedDate(focusedDay);
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
    );
  }

  Widget _buildReservationsList(
    BuildContext context,
    DateTime selectedDay,
    ReservationCalendarState calendarState,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final reservationsForDay = ref.read(reservationCalendarProvider.notifier)
        .getReservationsForDate(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reservationsForDate(selectedDay.day.toString(), selectedDay.month.toString()),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (reservationsForDay.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.noReservationsForDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...reservationsForDay.map((reservation) => 
            _buildReservationCard(context, reservation, l10n)
          ).toList(),
      ],
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ReservationCalendar reservation,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final status = ReservationStatus.fromString(reservation.status);
    final statusColor = _getStatusColor(status, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onReservationTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Indicateur de statut
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations de la réservation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reservation.time,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.clientName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${reservation.partySize} ${l10n.people}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (reservation.tableNumber != null)
                      Text(
                        '${l10n.table} ${reservation.tableNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Actions
              IconButton(
                onPressed: widget.onReservationTap,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status, ThemeData theme) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.noShow:
        return Colors.grey;
    }
  }
}
