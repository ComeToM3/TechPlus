import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour le formulaire de création/modification de table
class TableFormWidget extends ConsumerStatefulWidget {
  final TableEntity? table;
  final Function(TableEntity) onSave;
  final VoidCallback? onCancel;

  const TableFormWidget({
    super.key,
    this.table,
    required this.onSave,
    this.onCancel,
  });

  @override
  ConsumerState<TableFormWidget> createState() => _TableFormWidgetState();
}

class _TableFormWidgetState extends ConsumerState<TableFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _positionController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isActive = true;
  TableStatus _status = TableStatus.available;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.table != null) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    final table = widget.table!;
    _numberController.text = table.number.toString();
    _capacityController.text = table.capacity.toString();
    _positionController.text = table.position ?? '';
    _notesController.text = table.description ?? '';
    _isActive = table.isActive;
    _status = table.status;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    _positionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final table = TableEntity(
        id: widget.table?.id ?? '',
        number: int.parse(_numberController.text),
        capacity: int.parse(_capacityController.text),
        position: _positionController.text.isEmpty ? null : _positionController.text,
        isActive: _isActive,
        status: _status,
        description: _notesController.text.isEmpty ? null : _notesController.text,
        restaurantId: widget.table?.restaurantId ?? 'restaurant_1',
        createdAt: widget.table?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await widget.onSave(table);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.table == null 
                ? AppLocalizations.of(context)!.tableCreated 
                : AppLocalizations.of(context)!.tableUpdated),
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
                      widget.table == null ? Icons.add : Icons.edit,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.table == null ? l10n.createTable : l10n.editTable,
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
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _numberController,
                                  labelText: l10n.tableNumber,
                                  hintText: '1',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.requiredField;
                                    }
                                    final number = int.tryParse(value);
                                    if (number == null || number <= 0) {
                                      return l10n.invalidNumber;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _capacityController,
                                  labelText: l10n.capacity,
                                  hintText: '4',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.requiredField;
                                    }
                                    final capacity = int.tryParse(value);
                                    if (capacity == null || capacity <= 0) {
                                      return l10n.invalidCapacity;
                                    }
                                    if (capacity > 20) {
                                      return l10n.capacityTooHigh;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _positionController,
                            labelText: l10n.position,
                            hintText: l10n.positionHint,
                            prefixIcon: Icons.location_on,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Statut et configuration
                    BentoCard(
                      title: l10n.statusAndConfiguration,
                      child: Column(
                        children: [
                          // Statut actif
                          Row(
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                color: _isActive 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.activeTable,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Statut de disponibilité
                          Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                color: _getStatusColor(_status, theme),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.availabilityStatus,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              DropdownButton<TableStatus>(
                                value: _status,
                                onChanged: (TableStatus? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _status = newValue;
                                    });
                                  }
                                },
                                items: TableStatus.values.map((TableStatus status) {
                                  return DropdownMenuItem<TableStatus>(
                                    value: status,
                                    child: Text(_getStatusLabel(status, l10n)),
                                  );
                                }).toList(),
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
                              : (widget.table == null ? l10n.create : l10n.save),
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

  Color _getStatusColor(TableStatus status, ThemeData theme) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.grey;
      case TableStatus.outOfOrder:
        return Colors.red.shade700;
    }
  }

  String _getStatusLabel(TableStatus status, AppLocalizations l10n) {
    switch (status) {
      case TableStatus.available:
        return l10n.available;
      case TableStatus.occupied:
        return l10n.occupied;
      case TableStatus.reserved:
        return l10n.reserved;
      case TableStatus.maintenance:
        return l10n.maintenance;
      case TableStatus.outOfOrder:
        return l10n.outOfOrder;
    }
  }
}
