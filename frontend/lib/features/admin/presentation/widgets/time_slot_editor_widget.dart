import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour éditer un créneau horaire
class TimeSlotEditorWidget extends ConsumerStatefulWidget {
  final TimeSlot? timeSlot;
  final Function(TimeSlot) onSave;
  final VoidCallback? onCancel;

  const TimeSlotEditorWidget({
    super.key,
    this.timeSlot,
    required this.onSave,
    this.onCancel,
  });

  @override
  ConsumerState<TimeSlotEditorWidget> createState() => _TimeSlotEditorWidgetState();
}

class _TimeSlotEditorWidgetState extends ConsumerState<TimeSlotEditorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isAvailable = true;
  bool _isRecommended = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.timeSlot != null) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    final slot = widget.timeSlot!;
    _timeController.text = slot.time;
    _capacityController.text = slot.capacity.toString();
    _notesController.text = slot.notes ?? '';
    _isAvailable = slot.isAvailable;
    _isRecommended = slot.isRecommended;
  }

  @override
  void dispose() {
    _timeController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final timeSlot = TimeSlot(
        time: _timeController.text,
        isAvailable: _isAvailable,
        capacity: int.parse(_capacityController.text),
        isRecommended: _isRecommended,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await widget.onSave(timeSlot);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.timeSlot == null 
                ? AppLocalizations.of(context)!.timeSlotCreated 
                : AppLocalizations.of(context)!.timeSlotUpdated),
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

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.timeSlot == null ? Icons.add : Icons.edit,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.timeSlot == null ? l10n.addTimeSlot : l10n.editTimeSlot,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu du formulaire
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations de base
                    BentoCard(
                      title: l10n.basicInformation,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _timeController,
                            labelText: l10n.time,
                            hintText: 'HH:MM',
                            prefixIcon: Icons.access_time,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.requiredField;
                              }
                              if (!_isValidTimeFormat(value)) {
                                return l10n.invalidTimeFormat;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _capacityController,
                            labelText: l10n.capacity,
                            hintText: '20',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.requiredField;
                              }
                              final capacity = int.tryParse(value);
                              if (capacity == null || capacity <= 0) {
                                return l10n.invalidCapacity;
                              }
                              if (capacity > 100) {
                                return l10n.capacityTooHigh;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Configuration du créneau
                    BentoCard(
                      title: l10n.slotConfiguration,
                      child: Column(
                        children: [
                          // Disponibilité
                          Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                color: _isAvailable 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.available,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              Switch(
                                value: _isAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _isAvailable = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Recommandé
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: _isRecommended 
                                    ? Colors.amber 
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.recommended,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              Switch(
                                value: _isRecommended,
                                onChanged: (value) {
                                  setState(() {
                                    _isRecommended = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes
                    BentoCard(
                      title: l10n.notes,
                      child: CustomTextField(
                        controller: _notesController,
                        labelText: l10n.internalNotes,
                        hintText: l10n.notesHint,
                        maxLines: 3,
                        prefixIcon: Icons.note,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SimpleButton(
                          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                          text: l10n.cancel,
                          type: ButtonType.secondary,
                          size: ButtonSize.medium,
                        ),
                        const SizedBox(width: 12),
                        SimpleButton(
                          onPressed: _isLoading ? null : _handleSave,
                          text: _isLoading 
                              ? l10n.saving 
                              : (widget.timeSlot == null ? l10n.create : l10n.save),
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }
}
