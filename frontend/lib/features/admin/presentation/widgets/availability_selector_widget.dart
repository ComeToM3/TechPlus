import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/availability_api.dart';
import '../../../../shared/providers/core_providers.dart';

/// Widget pour la sélection des créneaux disponibles
class AvailabilitySelectorWidget extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final int partySize;
  final Function(DateTime?, String?) onAvailabilityChanged;

  const AvailabilitySelectorWidget({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.partySize,
    required this.onAvailabilityChanged,
  });

  @override
  ConsumerState<AvailabilitySelectorWidget> createState() => _AvailabilitySelectorWidgetState();
}

class _AvailabilitySelectorWidgetState extends ConsumerState<AvailabilitySelectorWidget> {
  DateTime? _selectedDate;
  String? _selectedTime;
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = widget.selectedTime;
    if (_selectedDate != null) {
      _loadAvailableSlots(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            const SizedBox(height: 16),

            // Sélection de date
            _buildDateSelector(theme, l10n),
            const SizedBox(height: 16),

            // Créneaux disponibles
            if (_selectedDate != null) _buildTimeSlots(theme, l10n),

            // Informations
            _buildInfo(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.selectAvailability,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_selectedDate != null && _selectedTime != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.selected,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDate,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDate != null 
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : l10n.selectDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDate != null 
                          ? theme.colorScheme.onSurface 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(ThemeData theme, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return _buildNoSlotsAvailable(theme, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.availableSlots,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSlots.map((slot) {
            return _buildTimeSlotChip(theme, l10n, slot);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(ThemeData theme, AppLocalizations l10n, TimeSlot slot) {
    final isSelected = _selectedTime == slot.time;
    final isAvailable = slot.isAvailable;
    final isRecommended = slot.isRecommended;

    return InkWell(
      onTap: isAvailable ? () => _selectTime(slot.time) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : isAvailable 
                  ? (isRecommended 
                      ? theme.colorScheme.secondaryContainer 
                      : theme.colorScheme.surfaceContainerHighest)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : isAvailable 
                    ? (isRecommended 
                        ? theme.colorScheme.secondary 
                        : theme.colorScheme.outline.withOpacity(0.3))
                    : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              slot.time,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : isAvailable 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isRecommended && !isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 12,
                color: theme.colorScheme.secondary,
              ),
            ],
            if (!isAvailable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoSlotsAvailable(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSlotsAvailable,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noSlotsAvailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.availabilityInfo(widget.partySize.toString()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _selectedTime = null;
      });
      _loadAvailableSlots(selectedDate);
      widget.onAvailabilityChanged(selectedDate, null);
    }
  }

  void _selectTime(String time) {
    setState(() {
      _selectedTime = time;
    });
    widget.onAvailabilityChanged(_selectedDate, time);
  }

  void _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Appeler l'API réelle pour obtenir les créneaux
      final availabilityApi = ref.read(availabilityApiProvider);
      final slots = await availabilityApi.getAvailableSlots(
        date: date,
        partySize: widget.partySize,
      );
      
      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Afficher une erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des créneaux: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<TimeSlot> _generateAvailableSlots(DateTime date, int partySize) {
    final slots = <TimeSlot>[];
    final now = DateTime.now();
    final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
    
    // Heures d'ouverture : 12h00 - 14h00 et 19h00 - 22h00
    final lunchSlots = ['12:00', '12:30', '13:00', '13:30'];
    final dinnerSlots = ['19:00', '19:30', '20:00', '20:30', '21:00', '21:30'];

    // Créneaux du déjeuner
    for (final time in lunchSlots) {
      final isAvailable = !isToday || _isTimeAfterNow(time);
      final isRecommended = time == '12:30' || time == '13:00';
      slots.add(TimeSlot(
        time: time,
        isAvailable: isAvailable,
        isRecommended: isRecommended,
        capacity: partySize <= 4 ? 8 : 4, // Capacité réduite pour les gros groupes
      ));
    }

    // Créneaux du dîner
    for (final time in dinnerSlots) {
      final isAvailable = !isToday || _isTimeAfterNow(time);
      final isRecommended = time == '19:30' || time == '20:00';
      slots.add(TimeSlot(
        time: time,
        isAvailable: isAvailable,
        isRecommended: isRecommended,
        capacity: partySize <= 6 ? 10 : 6,
      ));
    }

    return slots;
  }

  bool _isTimeAfterNow(String time) {
    final now = DateTime.now();
    final timeParts = time.split(':');
    final slotHour = int.parse(timeParts[0]);
    final slotMinute = int.parse(timeParts[1]);
    final slotTime = DateTime(now.year, now.month, now.day, slotHour, slotMinute);
    return slotTime.isAfter(now);
  }
}

/// Modèle pour un créneau horaire
class TimeSlot {
  final String time;
  final bool isAvailable;
  final bool isRecommended;
  final int capacity;

  const TimeSlot({
    required this.time,
    required this.isAvailable,
    this.isRecommended = false,
    required this.capacity,
  });
}

