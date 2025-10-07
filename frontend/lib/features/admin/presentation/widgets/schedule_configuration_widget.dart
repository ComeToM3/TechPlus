import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'dialogs/dialogs.dart';
import '../providers/schedule_provider.dart';

/// Widget principal pour la configuration des créneaux horaires
class ScheduleConfigurationWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic>? config;
  final Function(ScheduleConfig)? onScheduleChanged;
  final Function(TimeSlotSettings)? onSettingsChanged;

  const ScheduleConfigurationWidget({
    super.key,
    this.config,
    this.onScheduleChanged,
    this.onSettingsChanged,
  });

  @override
  ConsumerState<ScheduleConfigurationWidget> createState() => _ScheduleConfigurationWidgetState();
}

class _ScheduleConfigurationWidgetState extends ConsumerState<ScheduleConfigurationWidget> {
  ScheduleConfig? _scheduleConfig;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScheduleConfig();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(ScheduleConfigurationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Désactivé pour éviter la boucle infinie
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ne pas recharger automatiquement pour éviter les boucles
  }

  void _loadScheduleConfig() {
    // Utiliser les données du provider en priorité
    final scheduleState = ref.read(scheduleProvider);
    
    if (scheduleState.config != null) {
      setState(() {
        _scheduleConfig = _convertApiDataToScheduleConfig(scheduleState.config!);
      });
    } else if (widget.config != null) {
      setState(() {
        _scheduleConfig = _convertApiDataToScheduleConfig(widget.config!);
      });
    } else {
      // Créer une configuration par défaut
      setState(() {
        _scheduleConfig = _getDefaultScheduleConfig();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Écouter les changements du provider
    final scheduleState = ref.watch(scheduleProvider);
    
    // Charger la configuration une seule fois
    if (scheduleState.config != null && _scheduleConfig == null) {
      try {
        _scheduleConfig = _convertApiDataToScheduleConfig(scheduleState.config!);
      } catch (e) {
        // Créer une configuration par défaut en cas d'erreur
        _scheduleConfig = _getDefaultScheduleConfig();
      }
    }
    
    if (scheduleState.isLoading || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scheduleConfig == null) {
      return _buildEmptyState(theme, l10n);
    }

    return Column(
      children: [
        // Paramètres généraux en premier
        _buildSettingsSection(theme, l10n),
        const SizedBox(height: 16),

        // Créneaux par jour
        _buildScheduleSection(theme, l10n),
      ],
    );
  }



  ScheduleConfig _getDefaultScheduleConfig() {
    return ScheduleConfig(
      id: 'default',
      restaurantId: 'restaurant_1',
      daySchedules: DayOfWeek.values.map((day) {
        return DaySchedule(
          dayOfWeek: day.english,
          isOpen: day != DayOfWeek.sunday,
          notes: '',
          timeSlots: day == DayOfWeek.sunday ? [] : _generateDefaultTimeSlots(day),
          openingTime: day == DayOfWeek.sunday ? null : '09:00',
          closingTime: day == DayOfWeek.sunday ? null : '22:00',
        );
      }).toList(),
      timeSlotSettings: TimeSlotSettings(
        slotDurationMinutes: 30,
        bufferTimeMinutes: 15,
        maxAdvanceBookingDays: 30,
        minAdvanceBookingHours: 2,
        allowSameDayBooking: true,
        allowWeekendBooking: true,
        defaultCapacityPerSlot: 20,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<TimeSlot> _generateDefaultTimeSlots(DayOfWeek day) {
    if (day == DayOfWeek.sunday) return [];
    
    final slots = <TimeSlot>[];
    
    // Déjeuner : 12h-14h
    for (int hour = 12; hour < 14; hour++) {
        slots.add(TimeSlot(
        time: '${hour.toString().padLeft(2, '0')}:00',
          isAvailable: true,
          capacity: 20,
        isRecommended: hour == 12 || hour == 13,
        ));
    }
    
    // Dîner : 19h-21h
    for (int hour = 19; hour < 21; hour++) {
        slots.add(TimeSlot(
        time: '${hour.toString().padLeft(2, '0')}:00',
          isAvailable: true,
          capacity: 20,
        isRecommended: hour == 19 || hour == 20,
        ));
    }
    
    return slots;
  }

  List<TimeSlot> _generateDefaultTimeSlotsForDay(String dayOfWeek) {
    if (dayOfWeek.toLowerCase() == 'sunday') return [];
    
    final slots = <TimeSlot>[];
    
    // Déjeuner : 12h-14h
    for (int hour = 12; hour < 14; hour++) {
        slots.add(TimeSlot(
        time: '${hour.toString().padLeft(2, '0')}:00',
          isAvailable: true,
          capacity: 20,
        isRecommended: hour == 12 || hour == 13,
        ));
    }
    
    // Dîner : 19h-21h
    for (int hour = 19; hour < 21; hour++) {
        slots.add(TimeSlot(
        time: '${hour.toString().padLeft(2, '0')}:00',
          isAvailable: true,
          capacity: 20,
        isRecommended: hour == 19 || hour == 20,
        ));
    }
    
    return slots;
  }

  ScheduleConfig _convertApiDataToScheduleConfig(Map<String, dynamic> data) {
    
    final daySchedules = (data['daySchedules'] as List<dynamic>?)
        ?.map((dayData) => DaySchedule(
              dayOfWeek: dayData['dayOfWeek'] as String,
              isOpen: dayData['isOpen'] as bool? ?? false,
              notes: dayData['notes'] as String? ?? '',
              timeSlots: (dayData['timeSlots'] as List<dynamic>?)
                  ?.map((slotData) => TimeSlot(
                        time: slotData['time'] as String,
                        isAvailable: slotData['isAvailable'] as bool? ?? true,
                        capacity: slotData['capacity'] as int? ?? 20,
                        isRecommended: slotData['isRecommended'] as bool? ?? false,
                      ))
                  .toList() ?? [],
              openingTime: dayData['openingTime'] as String?,
              closingTime: dayData['closingTime'] as String?,
            ))
        .toList() ?? [];

    // Gérer les deux formats : paramètres directs ou dans timeSlotSettings
    TimeSlotSettings timeSlotSettings;
    if (data['timeSlotSettings'] != null) {
      // Format avec timeSlotSettings (depuis le provider)
      timeSlotSettings = TimeSlotSettings.fromJson(data['timeSlotSettings'] as Map<String, dynamic>);
    } else {
      // Format avec paramètres directs (depuis l'API)
      timeSlotSettings = TimeSlotSettings(
        slotDurationMinutes: data['slotDurationMinutes'] as int? ?? 30,
        bufferTimeMinutes: data['bufferTimeMinutes'] as int? ?? 15,
        maxAdvanceBookingDays: data['maxAdvanceBookingDays'] as int? ?? 30,
        minAdvanceBookingHours: data['minAdvanceBookingHours'] as int? ?? 2,
        allowSameDayBooking: data['allowSameDayBooking'] as bool? ?? true,
        allowWeekendBooking: data['allowWeekendBooking'] as bool? ?? true,
        defaultCapacityPerSlot: data['defaultCapacityPerSlot'] as int? ?? 20,
      );
    }

    return ScheduleConfig(
      id: data['id'] as String? ?? 'default',
      restaurantId: data['restaurantId'] as String? ?? 'restaurant_1',
      daySchedules: daySchedules,
      timeSlotSettings: timeSlotSettings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }


  Widget _buildSettingsSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Paramètres',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGrid(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildSettingsGrid(ThemeData theme, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          // Sur mobile, afficher en 2 colonnes
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildSettingCard(
                theme,
                'Durée des créneaux',
                '${_scheduleConfig!.timeSlotSettings.slotDurationMinutes} min',
                Icons.access_time,
                () => _showDurationDialog(theme, l10n),
              ),
              _buildSettingCard(
                theme,
                'Temps de pause',
                '${_scheduleConfig!.timeSlotSettings.bufferTimeMinutes} min',
                Icons.pause,
                () => _showBufferTimeDialog(theme, l10n),
              ),
              _buildSettingCard(
                theme,
                'Réservation avancée',
                '${_scheduleConfig!.timeSlotSettings.maxAdvanceBookingDays} jours',
                Icons.calendar_today,
                () => _showMaxAdvanceDialog(theme, l10n),
              ),
              _buildSettingCard(
                theme,
                'Réservation minimum',
                '${_scheduleConfig!.timeSlotSettings.minAdvanceBookingHours}h',
                Icons.schedule,
                () => _showMinAdvanceDialog(theme, l10n),
              ),
            ],
          );
        } else {
          // Sur desktop, afficher en une seule ligne horizontale
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSettingCard(
                  theme,
                  'Durée des créneaux',
                  '${_scheduleConfig!.timeSlotSettings.slotDurationMinutes} min',
                  Icons.access_time,
                  () => _showDurationDialog(theme, l10n),
                ),
                const SizedBox(width: 12),
                _buildSettingCard(
                  theme,
                  'Temps de pause',
                  '${_scheduleConfig!.timeSlotSettings.bufferTimeMinutes} min',
                  Icons.pause,
                  () => _showBufferTimeDialog(theme, l10n),
                ),
                const SizedBox(width: 12),
                _buildSettingCard(
                  theme,
                  'Réservation avancée',
                  '${_scheduleConfig!.timeSlotSettings.maxAdvanceBookingDays} jours',
                  Icons.calendar_today,
                  () => _showMaxAdvanceDialog(theme, l10n),
                ),
                const SizedBox(width: 12),
                _buildSettingCard(
                  theme,
                  'Réservation minimum',
                  '${_scheduleConfig!.timeSlotSettings.minAdvanceBookingHours}h',
                  Icons.schedule,
                  () => _showMinAdvanceDialog(theme, l10n),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSettingCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200, // Largeur fixe pour le design horizontal
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                    children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Horaires d\'ouverture',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScheduleTable(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(ThemeData theme, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isMobile 
              ? _buildMobileTable(theme)
              : _buildDesktopTable(theme),
        );
      },
    );
  }

  Widget _buildDesktopTable(ThemeData theme) {
    return Column(
      children: [
        // En-tête du tableau
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              // Cellule vide pour l'en-tête des heures
              Container(
                width: 120,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Jours',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // En-têtes des heures
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Text(
                    'Ouverture',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Text(
                    'Fermeture',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lignes des jours
        ..._scheduleConfig!.daySchedules.map((daySchedule) {
          return _buildDayRow(theme, daySchedule);
        }).toList(),
      ],
    );
  }

  Widget _buildMobileTable(ThemeData theme) {
    return Column(
      children: [
        // En-tête du tableau mobile
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Jours',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                child: Text(
                    'Ouverture',
                    style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Text(
                    'Fermeture',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lignes des jours mobile
        ..._scheduleConfig!.daySchedules.map((daySchedule) {
          return _buildMobileDayRow(theme, daySchedule);
        }).toList(),
      ],
    );
  }

  Widget _buildDayRow(ThemeData theme, DaySchedule daySchedule) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Nom du jour avec switch
          Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDayName(daySchedule.dayOfWeek),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Switch(
                  value: daySchedule.isOpen,
                  onChanged: (value) => _toggleDayOpen(daySchedule.dayOfWeek, value),
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          // Heure d'ouverture
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: daySchedule.isOpen
                  ? _buildTimeInputCompact(theme, daySchedule.openingTime ?? '09:00', (time) => _updateOpeningTime(daySchedule, time))
                  : Container(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        'Fermé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          // Heure de fermeture
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: daySchedule.isOpen
                  ? _buildTimeInputCompact(theme, daySchedule.closingTime ?? '22:00', (time) => _updateClosingTime(daySchedule, time))
                  : Container(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        'Fermé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDayRow(ThemeData theme, DaySchedule daySchedule) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Nom du jour avec switch (version mobile)
          Container(
            width: 70,
            padding: const EdgeInsets.all(4),
      child: Column(
              mainAxisSize: MainAxisSize.min,
        children: [
                Text(
                  _getDayName(daySchedule.dayOfWeek),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Switch(
                  value: daySchedule.isOpen,
                  onChanged: (value) => _toggleDayOpen(daySchedule.dayOfWeek, value),
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          // Heure d'ouverture (mobile)
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: daySchedule.isOpen
                  ? _buildTimeInputCompact(theme, daySchedule.openingTime ?? '09:00', (time) => _updateOpeningTime(daySchedule, time))
                  : Container(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        'Fermé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          // Heure de fermeture (mobile)
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: daySchedule.isOpen
                  ? _buildTimeInputCompact(theme, daySchedule.closingTime ?? '22:00', (time) => _updateClosingTime(daySchedule, time))
                  : Container(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        'Fermé',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildTimeInputCompact(ThemeData theme, String value, Function(String) onChanged) {
    return InkWell(
      onTap: () => _showTimePickerCompact(theme, value, onChanged),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  void _showTimePickerCompact(ThemeData theme, String initialTime, Function(String) onChanged) {
    final timeParts = initialTime.split(':');
    final initialHour = int.tryParse(timeParts[0]) ?? 9;
    final initialMinute = int.tryParse(timeParts[1]) ?? 0;
    
    showTimePicker(
      context: this.context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    ).then((time) {
      if (time != null) {
        final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        onChanged(formattedTime);
      }
    });
  }


  void _updateOpeningTime(DaySchedule daySchedule, String openingTime) {
    setState(() {
      final dayIndex = _scheduleConfig!.daySchedules.indexWhere(
        (day) => day.dayOfWeek == daySchedule.dayOfWeek,
      );
      if (dayIndex != -1) {
        _scheduleConfig!.daySchedules[dayIndex] = _scheduleConfig!.daySchedules[dayIndex].copyWith(
          openingTime: openingTime,
        );
      }
    });
    // Sauvegarder immédiatement les changements
    widget.onScheduleChanged?.call(_scheduleConfig!);
  }

  void _updateClosingTime(DaySchedule daySchedule, String closingTime) {
    setState(() {
      final dayIndex = _scheduleConfig!.daySchedules.indexWhere(
        (day) => day.dayOfWeek == daySchedule.dayOfWeek,
      );
      if (dayIndex != -1) {
        _scheduleConfig!.daySchedules[dayIndex] = _scheduleConfig!.daySchedules[dayIndex].copyWith(
          closingTime: closingTime,
        );
      }
    });
    // Sauvegarder immédiatement les changements
    widget.onScheduleChanged?.call(_scheduleConfig!);
  }


  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune configuration trouvée',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Une configuration par défaut sera créée automatiquement',
            style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayName(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday': return 'Lundi';
      case 'tuesday': return 'Mardi';
      case 'wednesday': return 'Mercredi';
      case 'thursday': return 'Jeudi';
      case 'friday': return 'Vendredi';
      case 'saturday': return 'Samedi';
      case 'sunday': return 'Dimanche';
      default: return dayOfWeek;
    }
  }

  void _toggleDayOpen(String dayOfWeek, bool isOpen) {
    setState(() {
      final dayIndex = _scheduleConfig!.daySchedules.indexWhere(
        (day) => day.dayOfWeek == dayOfWeek,
      );
      if (dayIndex != -1) {
        List<TimeSlot> timeSlots;
        String? openingTime;
        String? closingTime;
        
        if (isOpen) {
          // Si on ouvre le jour, générer des créneaux par défaut s'il n'y en a pas
          if (_scheduleConfig!.daySchedules[dayIndex].timeSlots.isEmpty) {
            timeSlots = _generateDefaultTimeSlotsForDay(dayOfWeek);
            openingTime = '09:00';
            closingTime = '22:00';
          } else {
            timeSlots = _scheduleConfig!.daySchedules[dayIndex].timeSlots;
            openingTime = _scheduleConfig!.daySchedules[dayIndex].openingTime ?? '09:00';
            closingTime = _scheduleConfig!.daySchedules[dayIndex].closingTime ?? '22:00';
          }
        } else {
          // Si on ferme le jour, supprimer les créneaux
          timeSlots = [];
          openingTime = null;
          closingTime = null;
        }
        
        _scheduleConfig!.daySchedules[dayIndex] = _scheduleConfig!.daySchedules[dayIndex].copyWith(
          isOpen: isOpen,
          timeSlots: timeSlots,
          openingTime: openingTime,
          closingTime: closingTime,
        );
      }
    });
    // Sauvegarder immédiatement les changements
    widget.onScheduleChanged?.call(_scheduleConfig!);
  }


  void _showDurationDialog(ThemeData theme, AppLocalizations l10n) {
    showDialog(
      context: this.context,
      builder: (context) => SlotDurationDialog(
        currentDuration: _scheduleConfig!.timeSlotSettings.slotDurationMinutes,
        onDurationChanged: (duration) {
          setState(() {
            _scheduleConfig = _scheduleConfig!.copyWith(
              timeSlotSettings: _scheduleConfig!.timeSlotSettings.copyWith(
                slotDurationMinutes: duration,
              ),
            );
          });
          // Appeler onScheduleChanged pour sauvegarder
          widget.onScheduleChanged?.call(_scheduleConfig!);
        },
      ),
    );
  }

  void _showBufferTimeDialog(ThemeData theme, AppLocalizations l10n) {
    showDialog(
      context: this.context,
      builder: (context) => BufferTimeDialog(
        currentBufferTime: _scheduleConfig!.timeSlotSettings.bufferTimeMinutes,
        onBufferTimeChanged: (bufferTime) {
        setState(() {
            _scheduleConfig = _scheduleConfig!.copyWith(
              timeSlotSettings: _scheduleConfig!.timeSlotSettings.copyWith(
                bufferTimeMinutes: bufferTime,
              ),
            );
          });
          // Appeler onScheduleChanged pour sauvegarder
          widget.onScheduleChanged?.call(_scheduleConfig!);
        },
      ),
    );
  }

  void _showMaxAdvanceDialog(ThemeData theme, AppLocalizations l10n) {
    showDialog(
      context: this.context,
      builder: (context) => AdvanceBookingDialog(
        currentMaxAdvanceDays: _scheduleConfig!.timeSlotSettings.maxAdvanceBookingDays,
        onMaxAdvanceDaysChanged: (advanceDays) {
          setState(() {
            _scheduleConfig = _scheduleConfig!.copyWith(
              timeSlotSettings: _scheduleConfig!.timeSlotSettings.copyWith(
                maxAdvanceBookingDays: advanceDays,
              ),
            );
          });
          // Appeler onScheduleChanged pour sauvegarder
          widget.onScheduleChanged?.call(_scheduleConfig!);
        },
      ),
    );
  }

  void _showMinAdvanceDialog(ThemeData theme, AppLocalizations l10n) {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: const Text('Réservation minimum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Heures minimum avant la réservation'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Heures',
                suffixText: 'h',
              ),
              controller: TextEditingController(
                text: _scheduleConfig!.timeSlotSettings.minAdvanceBookingHours.toString(),
              ),
              onChanged: (value) {
                final hours = int.tryParse(value);
                if (hours != null && hours >= 0) {
                  setState(() {
                    _scheduleConfig = _scheduleConfig!.copyWith(
                      timeSlotSettings: _scheduleConfig!.timeSlotSettings.copyWith(
                        minAdvanceBookingHours: hours,
                      ),
                    );
                  });
                  // Appeler onScheduleChanged pour sauvegarder
                  widget.onScheduleChanged?.call(_scheduleConfig!);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}




