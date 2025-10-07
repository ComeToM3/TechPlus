import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/schedule_configuration_widget.dart';
import '../../domain/entities/schedule_entity.dart';
import '../providers/schedule_provider.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/unified_navigation.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/network/auth_token_manager.dart';
import '../widgets/public_navigation_button.dart';

/// Page de gestion des créneaux horaires
class ScheduleManagementPage extends ConsumerStatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  ConsumerState<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends ConsumerState<ScheduleManagementPage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Délayer l'appel pour éviter la modification du provider pendant la construction
    Future(() => _loadScheduleConfig());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ne pas recharger automatiquement pour éviter les boucles
  }

  Future<void> _loadScheduleConfig() async {
    if (_hasLoaded) return; // Éviter les appels multiples
    
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        await ref.read(scheduleProvider.notifier).loadScheduleConfig(
          token: authState.accessToken!,
        );
        _hasLoaded = true;
      } catch (e) {
        _hasLoaded = true; // Marquer comme chargé même en cas d'erreur pour éviter les boucles
      }
    }
  }

  ScheduleConfig _convertMapToScheduleConfig(Map<String, dynamic> data) {
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

    final timeSlotSettings = TimeSlotSettings(
      slotDurationMinutes: data['slotDurationMinutes'] as int? ?? 30,
      bufferTimeMinutes: data['bufferTimeMinutes'] as int? ?? 15,
      maxAdvanceBookingDays: data['maxAdvanceBookingDays'] as int? ?? 30,
      minAdvanceBookingHours: data['minAdvanceBookingHours'] as int? ?? 2,
      allowSameDayBooking: data['allowSameDayBooking'] as bool? ?? true,
      allowWeekendBooking: data['allowWeekendBooking'] as bool? ?? true,
      defaultCapacityPerSlot: data['defaultCapacityPerSlot'] as int? ?? 20,
    );

    return ScheduleConfig(
      id: data['id'] as String? ?? 'default',
      restaurantId: data['restaurantId'] as String? ?? 'restaurant_1',
      daySchedules: daySchedules,
      timeSlotSettings: timeSlotSettings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }



  // ScheduleConfig _getDefaultScheduleConfig() {
    // return ScheduleConfig(
    //   id: 'schedule_1',
    //   restaurantId: 'restaurant_1',
    //   daySchedules: DayOfWeek.values.map((day) {
    //     return DaySchedule(
    //       dayOfWeek: day.english,
    //       isOpen: day != DayOfWeek.sunday,
    //       timeSlots: _generateDefaultTimeSlots(day),
    //       notes: '',
    //     );
    //   }).toList(),
    //   timeSlotSettings: const TimeSlotSettings(
    //     slotDurationMinutes: 30,
    //     bufferTimeMinutes: 15,
    //     maxAdvanceBookingDays: 30,
    //     minAdvanceBookingHours: 2,
    //     allowSameDayBooking: true,
    //     allowWeekendBooking: true,
    //   ),
    //   createdAt: DateTime.now(),
    //   updatedAt: DateTime.now(),
    // );
  // }

  // List<TimeSlot> _generateDefaultTimeSlots(DayOfWeek day) {
    // if (day == DayOfWeek.sunday) return [];
    
    // final slots = <TimeSlot>[];
    
    // // Créneaux du déjeuner (12h-14h)
    // for (int hour = 12; hour < 14; hour++) {
    //   for (int minute = 0; minute < 60; minute += 30) {
    //     slots.add(TimeSlot(
    //       time: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    //       isAvailable: true,
    //       capacity: 20,
    //       isRecommended: hour == 12 && minute == 30,
    //     ));
    //   }
    // }
    
    // // Créneaux du dîner (19h-22h)
    // for (int hour = 19; hour < 22; hour++) {
    //   for (int minute = 0; minute < 60; minute += 30) {
    //     slots.add(TimeSlot(
    //       time: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    //       isAvailable: true,
    //       capacity: 20,
    //       isRecommended: hour == 19 && minute == 30,
    //     ));
    //   }
    // }
    
    // return slots;
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scheduleState = ref.watch(scheduleProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const PublicNavigationButton(),
        title: Text(l10n.schedule),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              return IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                tooltip: themeMode == ThemeMode.dark 
                    ? 'Passer au thème clair' 
                    : 'Passer au thème sombre',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Forcer la sauvegarde de la configuration actuelle
              final scheduleState = ref.read(scheduleProvider);
              if (scheduleState.config != null) {
                // Convertir Map en ScheduleConfig
                final scheduleConfig = _convertMapToScheduleConfig(scheduleState.config!);
                _handleScheduleChanged(scheduleConfig);
              }
            },
            tooltip: 'Sauvegarder la configuration',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _hasLoaded = false; // Réinitialiser le flag
              ref.read(scheduleProvider.notifier).loadScheduleConfig(
                token: authState.accessToken!,
              );
            },
            tooltip: 'Recharger la configuration',
          ),
        ],
      ),
      bottomNavigationBar: UnifiedBottomNavigation(
        currentIndex: 3, // Horaires est l'index 3
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/admin/dashboard');
              break;
            case 1:
              context.go('/admin/dashboard/reservations');
              break;
            case 2:
              context.go('/admin/dashboard/tables');
              break;
            case 3:
              context.go('/admin/dashboard/schedule');
              break;
            case 4:
              context.go('/admin/dashboard/menu');
              break;
            case 5:
              context.go('/admin/dashboard/analytics');
              break;
            case 6:
              context.go('/admin/dashboard/reports');
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec actions
            _buildPageHeader(context, theme, l10n, authState),
            const SizedBox(height: 16),
            
            // Contenu principal
            scheduleState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : scheduleState.error != null
                    ? _buildErrorState(theme, l10n, scheduleState.error!)
                    : _buildContent(theme, l10n, scheduleState.config),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, ThemeData theme, AppLocalizations l10n, dynamic authState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.scheduleManagement,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (authState.accessToken != null) {
                    _loadScheduleConfig();
                  }
                },
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
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n, String error) {
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
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
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


  Widget _buildContent(ThemeData theme, AppLocalizations l10n, Map<String, dynamic>? config) {
    return ScheduleConfigurationWidget(
      config: config,
      onScheduleChanged: _handleScheduleChanged,
      onSettingsChanged: _handleSettingsChanged,
    );
  }



  Future<void> _handleScheduleChanged(ScheduleConfig newSchedule) async {
    final authState = ref.read(authProvider);
    // Utiliser le token de développement si pas de token d'authentification
    final token = authState.accessToken ?? AuthTokenManager().accessToken;
    
    if (token != null) {
      try {
        // Convertir ScheduleConfig en Map pour l'API
        final scheduleData = {
          'id': newSchedule.id,
          'restaurantId': newSchedule.restaurantId,
          // Paramètres directs (format simplifié)
          'slotDurationMinutes': newSchedule.timeSlotSettings.slotDurationMinutes,
          'bufferTimeMinutes': newSchedule.timeSlotSettings.bufferTimeMinutes,
          'maxAdvanceBookingDays': newSchedule.timeSlotSettings.maxAdvanceBookingDays,
          'minAdvanceBookingHours': newSchedule.timeSlotSettings.minAdvanceBookingHours,
          'allowSameDayBooking': newSchedule.timeSlotSettings.allowSameDayBooking,
          'allowWeekendBooking': newSchedule.timeSlotSettings.allowWeekendBooking,
          'defaultCapacityPerSlot': newSchedule.timeSlotSettings.defaultCapacityPerSlot,
          'daySchedules': newSchedule.daySchedules.map((day) => {
            'dayOfWeek': day.dayOfWeek,
            'isOpen': day.isOpen,
            'openingTime': day.openingTime,
            'closingTime': day.closingTime,
            'notes': day.notes,
            'timeSlots': day.timeSlots.map((slot) => {
              'time': slot.time,
              'isAvailable': slot.isAvailable,
              'capacity': slot.capacity,
              'isRecommended': slot.isRecommended,
            }).toList(),
          }).toList(),
        };


        await ref.read(scheduleProvider.notifier).updateScheduleConfig(
          token: token!,
          scheduleData: scheduleData,
        );

        // Recharger les données depuis la base de données après la sauvegarde
        await _loadScheduleConfig();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Configuration sauvegardée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSettingsChanged(TimeSlotSettings newSettings) async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        // Récupérer la configuration actuelle
        final currentConfig = ref.read(scheduleProvider).config;
        if (currentConfig != null) {
          final scheduleData = {
            ...currentConfig,
            'timeSlotSettings': {
              'slotDurationMinutes': newSettings.slotDurationMinutes,
              'bufferTimeMinutes': newSettings.bufferTimeMinutes,
              'maxAdvanceBookingDays': newSettings.maxAdvanceBookingDays,
              'minAdvanceBookingHours': newSettings.minAdvanceBookingHours,
              'allowSameDayBooking': newSettings.allowSameDayBooking,
              'allowWeekendBooking': newSettings.allowWeekendBooking,
            },
          };

          await ref.read(scheduleProvider.notifier).updateScheduleConfig(
            token: authState.accessToken!,
            scheduleData: scheduleData,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Paramètres sauvegardés avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
