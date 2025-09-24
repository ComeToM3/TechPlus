import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import '../providers/restaurant_config_provider.dart';

/// Widget pour la gestion des heures d'ouverture
class OpeningHoursWidget extends ConsumerStatefulWidget {
  const OpeningHoursWidget({super.key});

  @override
  ConsumerState<OpeningHoursWidget> createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends ConsumerState<OpeningHoursWidget> {
  List<OpeningHours> _openingHours = [];
  bool _isLoading = false;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadOpeningHours();
  }

  void _loadOpeningHours() {
    final hoursAsync = ref.read(openingHoursProvider);
    hoursAsync.whenData((hours) {
      setState(() {
        _openingHours = hours;
      });
    });
  }

  void _updateDay(int index, OpeningHours updatedHours) {
    setState(() {
      _openingHours[index] = updatedHours;
    });
  }

  Future<void> _saveOpeningHours() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(openingHoursNotifierProvider.notifier).updateOpeningHours(_openingHours);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.openingHoursSaved),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          BentoCard(
            title: l10n.openingHours,
            subtitle: l10n.configureOpeningHours,
            child: Column(
              children: [
                ...List.generate(_daysOfWeek.length, (index) {
                  final day = _daysOfWeek[index];
                  final dayHours = _openingHours.isNotEmpty 
                      ? _openingHours.firstWhere(
                          (h) => h.dayOfWeek == day,
                          orElse: () => OpeningHours(
                            dayOfWeek: day,
                            isOpen: false,
                          ),
                        )
                      : OpeningHours(
                          dayOfWeek: day,
                          isOpen: false,
                        );

                  return _DayHoursWidget(
                    day: day,
                    hours: dayHours,
                    onChanged: (updatedHours) => _updateDay(index, updatedHours),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton de sauvegarde
          Center(
            child: SimpleButton(
              onPressed: _isLoading ? null : _saveOpeningHours,
              text: _isLoading ? l10n.saving : l10n.save,
              type: ButtonType.primary,
              size: ButtonSize.large,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour les heures d'un jour spécifique
class _DayHoursWidget extends StatefulWidget {
  final String day;
  final OpeningHours hours;
  final Function(OpeningHours) onChanged;

  const _DayHoursWidget({
    required this.day,
    required this.hours,
    required this.onChanged,
  });

  @override
  State<_DayHoursWidget> createState() => _DayHoursWidgetState();
}

class _DayHoursWidgetState extends State<_DayHoursWidget> {
  late bool _isOpen;
  late String? _openTime;
  late String? _closeTime;
  late String? _breakStartTime;
  late String? _breakEndTime;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.hours.isOpen;
    _openTime = widget.hours.openTime;
    _closeTime = widget.hours.closeTime;
    _breakStartTime = widget.hours.breakStartTime;
    _breakEndTime = widget.hours.breakEndTime;
    _notes = widget.hours.notes;
  }

  void _updateHours() {
    widget.onChanged(OpeningHours(
      dayOfWeek: widget.day,
      isOpen: _isOpen,
      openTime: _openTime,
      closeTime: _closeTime,
      breakStartTime: _breakStartTime,
      breakEndTime: _breakEndTime,
      notes: _notes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du jour
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getDayName(widget.day),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _isOpen,
                  onChanged: (value) {
                    setState(() {
                      _isOpen = value;
                    });
                    _updateHours();
                  },
                ),
              ],
            ),

            if (_isOpen) ...[
              const SizedBox(height: 16),
              
              // Heures d'ouverture
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _openTime,
                      decoration: InputDecoration(
                        labelText: l10n.openTime,
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      onChanged: (value) {
                        _openTime = value;
                        _updateHours();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _closeTime,
                      decoration: InputDecoration(
                        labelText: l10n.closeTime,
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      onChanged: (value) {
                        _closeTime = value;
                        _updateHours();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pause déjeuner (optionnelle)
              ExpansionTile(
                title: Text(l10n.lunchBreak),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _breakStartTime,
                          decoration: InputDecoration(
                            labelText: l10n.breakStart,
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          onChanged: (value) {
                            _breakStartTime = value;
                            _updateHours();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _breakEndTime,
                          decoration: InputDecoration(
                            labelText: l10n.breakEnd,
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          onChanged: (value) {
                            _breakEndTime = value;
                            _updateHours();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
                onChanged: (value) {
                  _notes = value;
                  _updateHours();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDayName(String day) {
    switch (day) {
      case 'Monday':
        return 'Lundi';
      case 'Tuesday':
        return 'Mardi';
      case 'Wednesday':
        return 'Mercredi';
      case 'Thursday':
        return 'Jeudi';
      case 'Friday':
        return 'Vendredi';
      case 'Saturday':
        return 'Samedi';
      case 'Sunday':
        return 'Dimanche';
      default:
        return day;
    }
  }
}

