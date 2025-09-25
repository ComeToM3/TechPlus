import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour la configuration des paramètres de créneaux
class ScheduleSettingsWidget extends ConsumerStatefulWidget {
  final TimeSlotSettings settings;
  final Function(TimeSlotSettings) onSettingsChanged;

  const ScheduleSettingsWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  ConsumerState<ScheduleSettingsWidget> createState() => _ScheduleSettingsWidgetState();
}

class _ScheduleSettingsWidgetState extends ConsumerState<ScheduleSettingsWidget> {
  late TimeSlotSettings _currentSettings;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSettingsChanged(_currentSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsSaved),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Paramètres de durée
          BentoCard(
            title: l10n.durationSettings,
            child: Column(
              children: [
                _buildDurationSetting(
                  theme,
                  l10n.slotDuration,
                  _currentSettings.slotDurationMinutes,
                  (value) => _updateSettings(_currentSettings.copyWith(slotDurationMinutes: value)),
                  l10n.slotDurationDescription,
                ),
                const SizedBox(height: 16),
                _buildDurationSetting(
                  theme,
                  l10n.bufferTime,
                  _currentSettings.bufferTimeMinutes,
                  (value) => _updateSettings(_currentSettings.copyWith(bufferTimeMinutes: value)),
                  l10n.bufferTimeDescription,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Paramètres de réservation
          BentoCard(
            title: l10n.bookingSettings,
            child: Column(
              children: [
                _buildDurationSetting(
                  theme,
                  l10n.maxAdvanceBooking,
                  _currentSettings.maxAdvanceBookingDays,
                  (value) => _updateSettings(_currentSettings.copyWith(maxAdvanceBookingDays: value)),
                  l10n.maxAdvanceBookingDescription,
                ),
                const SizedBox(height: 16),
                _buildDurationSetting(
                  theme,
                  l10n.minAdvanceBooking,
                  _currentSettings.minAdvanceBookingHours,
                  (value) => _updateSettings(_currentSettings.copyWith(minAdvanceBookingHours: value)),
                  l10n.minAdvanceBookingDescription,
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
                _buildSwitchSetting(
                  theme,
                  l10n.allowSameDayBooking,
                  l10n.allowSameDayBookingDescription,
                  _currentSettings.allowSameDayBooking,
                  (value) => _updateSettings(_currentSettings.copyWith(allowSameDayBooking: value)),
                  Icons.today,
                ),
                const SizedBox(height: 16),
                _buildSwitchSetting(
                  theme,
                  l10n.allowWeekendBooking,
                  l10n.allowWeekendBookingDescription,
                  _currentSettings.allowWeekendBooking,
                  (value) => _updateSettings(_currentSettings.copyWith(allowWeekendBooking: value)),
                  Icons.weekend,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SimpleButton(
                onPressed: _handleSave,
                text: _isLoading ? l10n.saving : l10n.save,
                type: ButtonType.primary,
                size: ButtonSize.large,
                isLoading: _isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSetting(
    ThemeData theme,
    String title,
    int value,
    Function(int) onChanged,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 100,
              child: TextFormField(
                initialValue: value.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: title.contains('Heures') ? 'h' : 'min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0) {
                    onChanged(intValue);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.requiredField;
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return AppLocalizations.of(context)!.invalidValue;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    ThemeData theme,
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _updateSettings(TimeSlotSettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
  }
}
