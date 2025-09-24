import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../../shared/widgets/forms/form_builder.dart';
import '../../../domain/entities/report_entity.dart';
import '../../providers/report_provider.dart';

/// Widget pour les filtres de rapport
class ReportFiltersWidget extends ConsumerStatefulWidget {
  final ReportFilters? initialFilters;
  final Function(ReportFilters) onFiltersChanged;

  const ReportFiltersWidget({
    super.key,
    this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<ReportFiltersWidget> createState() => _ReportFiltersWidgetState();
}

class _ReportFiltersWidgetState extends ConsumerState<ReportFiltersWidget> {
  late ReportFilters _filters;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? ReportFilters(
      reportType: ReportType.daily,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BentoCard(
      title: l10n.reportFilters,
      subtitle: l10n.reportFiltersDescription,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de rapport
            _buildReportTypeSelector(l10n),
            const SizedBox(height: 16),
            
            // Période
            _buildDateRangeSelector(l10n),
            const SizedBox(height: 16),
            
            // Filtres avancés
            _buildAdvancedFilters(l10n),
            const SizedBox(height: 24),
            
            // Actions
            _buildActions(l10n),
          ],
        ),
    );
  }

  Widget _buildReportTypeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ReportType.values.map((type) {
            return FilterChip(
              label: Text(_getReportTypeLabel(l10n, type)),
              selected: _filters.reportType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _filters = _filters.copyWith(reportType: type);
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dateRange,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                l10n.startDate,
                _filters.startDate,
                (date) {
                  setState(() {
                    _filters = _filters.copyWith(startDate: date);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                l10n.endDate,
                _filters.endDate,
                (date) {
                  setState(() {
                    _filters = _filters.copyWith(endDate: date);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : label,
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters(AppLocalizations l10n) {
    return ExpansionTile(
      title: Text(l10n.advancedFilters),
      children: [
        // Statuts
        _buildStatusFilters(l10n),
        const SizedBox(height: 16),
        
        // Tables
        _buildTableFilters(l10n),
        const SizedBox(height: 16),
        
        // Options
        _buildOptionsFilters(l10n),
      ],
    );
  }

  Widget _buildStatusFilters(AppLocalizations l10n) {
    final statuses = ['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reservationStatus,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: statuses.map((status) {
            final isSelected = _filters.statuses?.contains(status) ?? false;
            return FilterChip(
              label: Text(_getStatusLabel(l10n, status)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentStatuses = _filters.statuses ?? [];
                  if (selected) {
                    _filters = _filters.copyWith(
                      statuses: [...currentStatuses, status],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      statuses: currentStatuses.where((s) => s != status).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTableFilters(AppLocalizations l10n) {
    // Simuler des tables disponibles
    final tables = List.generate(10, (index) => 'Table ${index + 1}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tables,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tables.map((table) {
            final isSelected = _filters.tables?.contains(table) ?? false;
            return FilterChip(
              label: Text(table),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentTables = _filters.tables ?? [];
                  if (selected) {
                    _filters = _filters.copyWith(
                      tables: [...currentTables, table],
                    );
                  } else {
                    _filters = _filters.copyWith(
                      tables: currentTables.where((t) => t != table).toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsFilters(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.options,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: Text(l10n.includeCancelled),
          value: _filters.includeCancelled,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(includeCancelled: value ?? true);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text(l10n.includeNoShow),
          value: _filters.includeNoShow,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(includeNoShow: value ?? true);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: () {
              widget.onFiltersChanged(_filters);
            },
            text: l10n.applyFilters,
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SimpleButton(
            onPressed: _resetFilters,
            text: l10n.resetFilters,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = ReportFilters(
        reportType: ReportType.daily,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    });
  }

  String _getReportTypeLabel(AppLocalizations l10n, ReportType type) {
    switch (type) {
      case ReportType.daily:
        return l10n.daily;
      case ReportType.weekly:
        return l10n.weekly;
      case ReportType.monthly:
        return l10n.monthly;
      case ReportType.custom:
        return l10n.custom;
    }
  }

  String _getStatusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'PENDING':
        return l10n.pending;
      case 'CONFIRMED':
        return l10n.confirmed;
      case 'CANCELLED':
        return l10n.cancelled;
      case 'COMPLETED':
        return l10n.completed;
      case 'NO_SHOW':
        return l10n.noShow;
      default:
        return status;
    }
  }
}
