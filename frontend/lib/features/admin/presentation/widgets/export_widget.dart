import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour l'export des données de réservations
class ExportWidget extends ConsumerStatefulWidget {
  final List<ReservationCalendar> reservations;
  final CalendarFilters? filters;
  final Function(ExportOptions) onExport;

  const ExportWidget({
    super.key,
    required this.reservations,
    this.filters,
    required this.onExport,
  });

  @override
  ConsumerState<ExportWidget> createState() => _ExportWidgetState();
}

class _ExportWidgetState extends ConsumerState<ExportWidget> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedFields = [];
  bool _includeCancelled = false;
  bool _includeCompleted = true;

  @override
  void initState() {
    super.initState();
    _startDate = widget.filters?.startDate;
    _endDate = widget.filters?.endDate;
    _selectedFields = _getDefaultFields();
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
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.exportData,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.reservations.length} ${l10n.reservations}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Format d'export
            _buildFormatSelection(theme, l10n),
            const SizedBox(height: 16),

            // Période d'export
            _buildDateRange(theme, l10n),
            const SizedBox(height: 16),

            // Champs à inclure
            _buildFieldSelection(theme, l10n),
            const SizedBox(height: 16),

            // Options avancées
            _buildAdvancedOptions(theme, l10n),
            const SizedBox(height: 16),

            // Actions
            _buildExportActions(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportFormat,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormatOption(
                theme,
                ExportFormat.csv,
                'CSV',
                Icons.table_chart,
                l10n.csvDescription,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormatOption(
                theme,
                ExportFormat.excel,
                'Excel',
                Icons.table_view,
                l10n.excelDescription,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormatOption(
                theme,
                ExportFormat.pdf,
                'PDF',
                Icons.picture_as_pdf,
                l10n.pdfDescription,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    ThemeData theme,
    ExportFormat format,
    String label,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRange(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportPeriod,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                theme,
                l10n.startDate,
                _startDate,
                (date) {
                  setState(() {
                    _startDate = date;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                theme,
                l10n.endDate,
                _endDate,
                (date) {
                  setState(() {
                    _endDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime? date,
    Function(DateTime?) onDateChanged,
  ) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (selectedDate != null) {
          onDateChanged(selectedDate);
        }
      },
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
                date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: date != null 
                      ? theme.colorScheme.onSurface 
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (date != null)
              IconButton(
                onPressed: () => onDateChanged(null),
                icon: const Icon(Icons.clear),
                iconSize: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSelection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.includeFields,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableFields().map((field) {
            final isSelected = _selectedFields.contains(field.key);
            return FilterChip(
              label: Text(field.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFields.add(field.key);
                  } else {
                    _selectedFields.remove(field.key);
                  }
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.advancedOptions,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text(l10n.includeCancelled),
                value: _includeCancelled,
                onChanged: (value) {
                  setState(() {
                    _includeCancelled = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text(l10n.includeCompleted),
                value: _includeCompleted,
                onChanged: (value) {
                  setState(() {
                    _includeCompleted = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: _performExport,
            text: l10n.export,
            type: ButtonType.primary,
            size: ButtonSize.medium,
            icon: Icons.download,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SimpleButton(
            onPressed: _previewExport,
            text: l10n.preview,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
            icon: Icons.visibility,
          ),
        ),
      ],
    );
  }

  void _performExport() {
    final options = ExportOptions(
      format: _selectedFormat,
      startDate: _startDate,
      endDate: _endDate,
      fields: _selectedFields,
      includeCancelled: _includeCancelled,
      includeCompleted: _includeCompleted,
    );
    widget.onExport(options);
  }

  void _previewExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.preview),
        content: const Text('Aperçu de l\'export à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  List<String> _getDefaultFields() {
    return ['date', 'time', 'clientName', 'partySize', 'status'];
  }

  List<ExportField> _getAvailableFields() {
    return [
      ExportField('date', 'Date'),
      ExportField('time', 'Heure'),
      ExportField('clientName', 'Nom du client'),
      ExportField('clientEmail', 'Email'),
      ExportField('clientPhone', 'Téléphone'),
      ExportField('partySize', 'Nombre de personnes'),
      ExportField('status', 'Statut'),
      ExportField('tableNumber', 'Table'),
      ExportField('notes', 'Notes'),
      ExportField('specialRequests', 'Demandes spéciales'),
      ExportField('estimatedAmount', 'Montant estimé'),
      ExportField('paymentStatus', 'Statut de paiement'),
    ];
  }
}

/// Options d'export
class ExportOptions {
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> fields;
  final bool includeCancelled;
  final bool includeCompleted;

  const ExportOptions({
    required this.format,
    this.startDate,
    this.endDate,
    required this.fields,
    this.includeCancelled = false,
    this.includeCompleted = true,
  });
}

/// Format d'export
enum ExportFormat {
  csv,
  excel,
  pdf,
}

/// Champ d'export
class ExportField {
  final String key;
  final String label;

  const ExportField(this.key, this.label);
}
