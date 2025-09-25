import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/schedule_configuration_widget.dart';
import '../widgets/time_slot_editor_widget.dart';
import '../widgets/schedule_settings_widget.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de gestion des créneaux horaires
class ScheduleManagementPage extends ConsumerStatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  ConsumerState<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends ConsumerState<ScheduleManagementPage> {
  bool _isLoading = false;
  ScheduleConfig? _scheduleConfig;

  @override
  void initState() {
    super.initState();
    _loadScheduleConfig();
  }

  Future<void> _loadScheduleConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Charger depuis l'API
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      
      setState(() {
        _scheduleConfig = _getDefaultScheduleConfig();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
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

  ScheduleConfig _getDefaultScheduleConfig() {
    return ScheduleConfig(
      id: 'schedule_1',
      restaurantId: 'restaurant_1',
      daySchedules: DayOfWeek.values.map((day) {
        return DaySchedule(
          dayOfWeek: day.english,
          isOpen: day != DayOfWeek.sunday,
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
          isRecommended: hour == 12 && minute == 30,
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
          isRecommended: hour == 19 && minute == 30,
        ));
      }
    }
    
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scheduleManagement),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadScheduleConfig,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
          IconButton(
            onPressed: _showQuickActions,
            icon: const Icon(Icons.more_vert),
            tooltip: l10n.actions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scheduleConfig == null
              ? _buildErrorState(theme, l10n)
              : _buildContent(theme, l10n),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingSchedule,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          SimpleButton(
            onPressed: _loadScheduleConfig,
            text: l10n.retry,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        children: [
          // En-tête avec informations
          _buildHeader(theme, l10n),
          const SizedBox(height: 16),

          // Contenu principal
          Expanded(
            child: ScheduleConfigurationWidget(
              onScheduleChanged: _handleScheduleChanged,
              onSettingsChanged: _handleSettingsChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildStatusChip(theme, l10n),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.scheduleConfigurationDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
            _buildInfoItem(theme, l10n, l10n.totalDays, '${_scheduleConfig!.daySchedules.length}'),
            const SizedBox(width: 24),
            _buildInfoItem(theme, l10n, l10n.openDays, '${_scheduleConfig!.daySchedules.where((d) => d.isOpen).length}'),
            const SizedBox(width: 24),
            _buildInfoItem(theme, l10n, l10n.totalSlots, '${_scheduleConfig!.daySchedules.fold(0, (sum, d) => sum + d.timeSlots.length)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, AppLocalizations l10n) {
    final openDays = _scheduleConfig!.daySchedules.where((d) => d.isOpen).length;
    final isActive = openDays > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pause_circle,
            size: 16,
            color: isActive 
                ? theme.colorScheme.onPrimaryContainer 
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? l10n.active : l10n.inactive,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, AppLocalizations l10n, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _handleScheduleChanged(ScheduleConfig newSchedule) {
    setState(() {
      _scheduleConfig = newSchedule;
    });
  }

  void _handleSettingsChanged(TimeSlotSettings newSettings) {
    setState(() {
      _scheduleConfig = _scheduleConfig!.copyWith(timeSlotSettings: newSettings);
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(AppLocalizations.of(context)!.copySchedule),
              onTap: () {
                Navigator.pop(context);
                _copySchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(AppLocalizations.of(context)!.resetSchedule),
              onTap: () {
                Navigator.pop(context);
                _resetSchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(AppLocalizations.of(context)!.exportSchedule),
              onTap: () {
                Navigator.pop(context);
                _exportSchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: Text(AppLocalizations.of(context)!.importSchedule),
              onTap: () {
                Navigator.pop(context);
                _importSchedule();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copySchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copySchedule)),
    );
  }

  void _resetSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetSchedule),
        content: Text(AppLocalizations.of(context)!.resetScheduleConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadScheduleConfig();
            },
            child: Text(AppLocalizations.of(context)!.reset),
          ),
        ],
      ),
    );
  }

  void _exportSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.exportSchedule)),
    );
  }

  void _importSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.importSchedule)),
    );
  }
}
