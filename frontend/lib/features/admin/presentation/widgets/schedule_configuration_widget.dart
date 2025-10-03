import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

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

class _ScheduleConfigurationWidgetState extends ConsumerState<ScheduleConfigurationWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScheduleConfig? _scheduleConfig;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScheduleConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadScheduleConfig() {
    if (widget.config != null) {
      setState(() {
        _scheduleConfig = _convertApiDataToScheduleConfig(widget.config!);
      });
    } else {
      setState(() {
        _scheduleConfig = _getDefaultScheduleConfig();
      });
    }
  }

  ScheduleConfig _getDefaultScheduleConfig() {
    return ScheduleConfig(
      id: 'schedule_1',
      restaurantId: 'restaurant_1',
      daySchedules: DayOfWeek.values.map((day) {
        return DaySchedule(
          dayOfWeek: day.english,
          isOpen: day != DayOfWeek.sunday, // Fermé le dimanche par défaut
          timeSlots: _generateDefaultTimeSlots(day),
          notes: '',
        );
      }).toList(),
      timeSlotSettings: const TimeSlotSettings(
        slotDurationMinutes: 30,
        bufferTimeMinutes: 15,
        maxAdvanceBookingDays: 30,
        minAdvanceBookingHours: 2,
        allowSameDayBooking: true,
        allowWeekendBooking: true,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<TimeSlot> _generateDefaultTimeSlots(DayOfWeek day) {
    if (day == DayOfWeek.sunday) return [];
    
    final slots = <TimeSlot>[];
    
    // Créneaux du déjeuner (12h-14h)
    for (int hour = 12; hour < 14; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        slots.add(TimeSlot(
          time: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          isAvailable: true,
          capacity: 20,
          isRecommended: hour == 12 && minute == 30, // 12h30 recommandé
        ));
      }
    }
    
    // Créneaux du dîner (19h-22h)
    for (int hour = 19; hour < 22; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        slots.add(TimeSlot(
          time: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          isAvailable: true,
          capacity: 20,
          isRecommended: hour == 19 && minute == 30, // 19h30 recommandé
        ));
      }
    }
    
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        children: [
          // En-tête avec actions
          _buildHeader(theme, l10n),
          const SizedBox(height: 16),

          // Contenu principal
          Expanded(
            child: _scheduleConfig == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScheduleTab(theme, l10n),
                      _buildSettingsTab(theme, l10n),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.scheduleConfiguration,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SimpleButton(
                onPressed: _isLoading ? null : _saveSchedule,
                text: _isLoading ? l10n.saving : l10n.save,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                isLoading: _isLoading,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.calendar_today),
                text: l10n.schedule,
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: l10n.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Configuration par jour
          ...DayOfWeek.values.map((day) {
            final daySchedule = _scheduleConfig!.daySchedules
                .firstWhere((d) => d.dayOfWeek == day.english);
            return _buildDayScheduleCard(theme, l10n, day, daySchedule);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDayScheduleCard(ThemeData theme, AppLocalizations l10n, DayOfWeek day, DaySchedule daySchedule) {
    return BentoCard(
      title: day.getLocalizedName('fr'),
      child: Column(
        children: [
          // En-tête du jour
          Row(
            children: [
              Expanded(
                child: Text(
                  day.getLocalizedName('fr'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: daySchedule.isOpen,
                onChanged: (value) {
                  _updateDaySchedule(day, daySchedule.copyWith(isOpen: value));
                },
              ),
            ],
          ),

          if (daySchedule.isOpen) ...[
            const SizedBox(height: 16),
            
            // Créneaux horaires
            _buildTimeSlotsSection(theme, l10n, day, daySchedule),
            
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: TextEditingController(text: daySchedule.notes ?? ''),
              decoration: InputDecoration(
                labelText: l10n.notes,
                hintText: l10n.notesHint,
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
              onChanged: (value) {
                _updateDaySchedule(day, daySchedule.copyWith(notes: value));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(ThemeData theme, AppLocalizations l10n, DayOfWeek day, DaySchedule daySchedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.timeSlots,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SimpleButton(
              onPressed: () => _addTimeSlot(day),
              text: l10n.addTimeSlot,
              type: ButtonType.secondary,
              size: ButtonSize.small,
              icon: Icons.add,
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Liste des créneaux
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: daySchedule.timeSlots.map((slot) {
            return _buildTimeSlotChip(theme, l10n, day, slot);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(ThemeData theme, AppLocalizations l10n, DayOfWeek day, TimeSlot slot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: slot.isAvailable 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: slot.isAvailable 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slot.time,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: slot.isAvailable 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            slot.isAvailable ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: slot.isAvailable 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTimeSlot(day, slot),
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme, AppLocalizations l10n) {
    final settings = _scheduleConfig!.timeSlotSettings;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Paramètres généraux
          BentoCard(
            title: l10n.generalSettings,
            child: Column(
              children: [
                _buildSettingRow(
                  theme,
                  l10n.slotDuration,
                  '${settings.slotDurationMinutes} min',
                  Icons.timer,
                  () => _showDurationDialog(settings),
                ),
                _buildSettingRow(
                  theme,
                  l10n.bufferTime,
                  '${settings.bufferTimeMinutes} min',
                  Icons.pause,
                  () => _showBufferTimeDialog(settings),
                ),
                _buildSettingRow(
                  theme,
                  l10n.maxAdvanceBooking,
                  '${settings.maxAdvanceBookingDays} jours',
                  Icons.calendar_month,
                  () => _showMaxAdvanceDialog(settings),
                ),
                _buildSettingRow(
                  theme,
                  l10n.minAdvanceBooking,
                  '${settings.minAdvanceBookingHours} heures',
                  Icons.schedule,
                  () => _showMinAdvanceDialog(settings),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options de réservation
          BentoCard(
            title: l10n.bookingOptions,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.allowSameDayBooking),
                  subtitle: Text(l10n.allowSameDayBookingDescription),
                  value: settings.allowSameDayBooking,
                  onChanged: (value) {
                    _updateSettings(settings.copyWith(allowSameDayBooking: value));
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.allowWeekendBooking),
                  subtitle: Text(l10n.allowWeekendBookingDescription),
                  value: settings.allowWeekendBooking,
                  onChanged: (value) {
                    _updateSettings(settings.copyWith(allowWeekendBooking: value));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _updateDaySchedule(DayOfWeek day, DaySchedule newSchedule) {
    setState(() {
      final daySchedules = List<DaySchedule>.from(_scheduleConfig!.daySchedules);
      final index = daySchedules.indexWhere((d) => d.dayOfWeek == day.english);
      if (index != -1) {
        daySchedules[index] = newSchedule;
        _scheduleConfig = _scheduleConfig!.copyWith(daySchedules: daySchedules);
      }
    });
  }

  void _updateSettings(TimeSlotSettings newSettings) {
    setState(() {
      _scheduleConfig = _scheduleConfig!.copyWith(timeSlotSettings: newSettings);
    });
  }

  void _addTimeSlot(DayOfWeek day) {
    // TODO: Ouvrir un dialog pour ajouter un créneau
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ajouter un créneau pour ${day.getLocalizedName('fr')}')),
    );
  }

  void _removeTimeSlot(DayOfWeek day, TimeSlot slot) {
    setState(() {
      final daySchedules = List<DaySchedule>.from(_scheduleConfig!.daySchedules);
      final dayIndex = daySchedules.indexWhere((d) => d.dayOfWeek == day.english);
      if (dayIndex != -1) {
        final timeSlots = List<TimeSlot>.from(daySchedules[dayIndex].timeSlots);
        timeSlots.removeWhere((t) => t.time == slot.time);
        daySchedules[dayIndex] = daySchedules[dayIndex].copyWith(timeSlots: timeSlots);
        _scheduleConfig = _scheduleConfig!.copyWith(daySchedules: daySchedules);
      }
    });
  }

  Future<void> _saveSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onScheduleChanged != null && _scheduleConfig != null) {
        await widget.onScheduleChanged!(_scheduleConfig!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.scheduleSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Convertit les données de l'API en ScheduleConfig
  ScheduleConfig _convertApiDataToScheduleConfig(Map<String, dynamic> apiData) {
    final daySchedules = <DaySchedule>[];
    
    if (apiData['daySchedules'] != null) {
      for (final dayData in apiData['daySchedules']) {
        final timeSlots = <TimeSlot>[];
        
        if (dayData['timeSlots'] != null) {
          for (final slotData in dayData['timeSlots']) {
            timeSlots.add(TimeSlot(
              time: slotData['time'] ?? '',
              isAvailable: slotData['isAvailable'] ?? true,
              capacity: slotData['capacity'] ?? 20,
              isRecommended: slotData['isRecommended'] ?? false,
            ));
          }
        }
        
        daySchedules.add(DaySchedule(
          dayOfWeek: dayData['dayOfWeek'] ?? '',
          isOpen: dayData['isOpen'] ?? true,
          notes: dayData['notes'],
          timeSlots: timeSlots,
        ));
      }
    }

    return ScheduleConfig(
      id: apiData['id'] ?? '',
      restaurantId: apiData['restaurantId'] ?? '',
      daySchedules: daySchedules,
      timeSlotSettings: TimeSlotSettings(
        slotDurationMinutes: apiData['slotDurationMinutes'] ?? 30,
        bufferTimeMinutes: apiData['bufferTimeMinutes'] ?? 15,
        maxAdvanceBookingDays: apiData['maxAdvanceBookingDays'] ?? 30,
        minAdvanceBookingHours: apiData['minAdvanceBookingHours'] ?? 2,
        allowSameDayBooking: apiData['allowSameDayBooking'] ?? true,
        allowWeekendBooking: apiData['allowWeekendBooking'] ?? true,
      ),
      createdAt: apiData['createdAt'] != null 
          ? DateTime.parse(apiData['createdAt']) 
          : DateTime.now(),
      updatedAt: apiData['updatedAt'] != null 
          ? DateTime.parse(apiData['updatedAt']) 
          : DateTime.now(),
    );
  }

  void _showDurationDialog(TimeSlotSettings settings) {
    // TODO: Implémenter le dialog de durée
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dialog de durée à implémenter')),
    );
  }

  void _showBufferTimeDialog(TimeSlotSettings settings) {
    // TODO: Implémenter le dialog de temps de pause
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dialog de temps de pause à implémenter')),
    );
  }

  void _showMaxAdvanceDialog(TimeSlotSettings settings) {
    // TODO: Implémenter le dialog de réservation avancée
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dialog de réservation avancée à implémenter')),
    );
  }

  void _showMinAdvanceDialog(TimeSlotSettings settings) {
    // TODO: Implémenter le dialog de réservation minimale
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dialog de réservation minimale à implémenter')),
    );
  }
}
