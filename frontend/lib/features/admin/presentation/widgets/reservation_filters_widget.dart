import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour les filtres avancés des réservations
class ReservationFiltersWidget extends ConsumerStatefulWidget {
  final CalendarFilters initialFilters;
  final Function(CalendarFilters) onFiltersChanged;
  final VoidCallback? onClearFilters;

  const ReservationFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.onClearFilters,
  });

  @override
  ConsumerState<ReservationFiltersWidget> createState() => _ReservationFiltersWidgetState();
}

class _ReservationFiltersWidgetState extends ConsumerState<ReservationFiltersWidget> {
  late CalendarFilters _filters;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<ReservationStatus> _selectedStatuses = [];
  List<String> _selectedTables = [];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _searchController.text = _filters.searchQuery ?? '';
    _startDate = _filters.startDate;
    _endDate = _filters.endDate;
    _selectedStatuses = _filters.statusFilter;
    _selectedTables = _filters.tableFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête des filtres
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.advancedFilters,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.clearFilters),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Recherche
          _buildSearchField(theme, l10n),
          const SizedBox(height: 16),

          // Filtres par statut
          _buildStatusFilters(theme, l10n),
          const SizedBox(height: 16),

          // Filtres par table
          _buildTableFilters(theme, l10n),
          const SizedBox(height: 16),

          // Filtres par date
          _buildDateFilters(theme, l10n),
          const SizedBox(height: 16),

          // Actions
          _buildFilterActions(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.search,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _searchController,
          hintText: l10n.searchReservations,
          prefixIcon: Icons.search,
          onChanged: (value) {
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildStatusFilters(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.status,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReservationStatus.values.map((status) {
            final isSelected = _selectedStatuses.contains(status);
            return FilterChip(
              label: Text(status.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status);
                  } else {
                    _selectedStatuses.remove(status);
                  }
                });
                _updateFilters();
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTableFilters(ThemeData theme, AppLocalizations l10n) {
    // Simulation des tables disponibles
    final availableTables = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tables,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTables.map((table) {
            final isSelected = _selectedTables.contains(table);
            return FilterChip(
              label: Text(table),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTables.add(table);
                  } else {
                    _selectedTables.remove(table);
                  }
                });
                _updateFilters();
              },
              selectedColor: theme.colorScheme.secondaryContainer,
              checkmarkColor: theme.colorScheme.onSecondaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateFilters(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dateRange,
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
                  _updateFilters();
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
                  _updateFilters();
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

  Widget _buildFilterActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: _applyFilters,
            text: l10n.applyFilters,
            type: ButtonType.primary,
            size: ButtonSize.medium,
            icon: Icons.check,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SimpleButton(
            onPressed: _clearFilters,
            text: l10n.clearFilters,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
            icon: Icons.clear,
          ),
        ),
      ],
    );
  }

  void _updateFilters() {
    _filters = _filters.copyWith(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      statusFilter: _selectedStatuses,
      tableFilter: _selectedTables,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _applyFilters() {
    _updateFilters();
    widget.onFiltersChanged(_filters);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatuses.clear();
      _selectedTables.clear();
      _startDate = null;
      _endDate = null;
      _filters = const CalendarFilters();
    });
    widget.onFiltersChanged(_filters);
    widget.onClearFilters?.call();
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
           _selectedStatuses.isNotEmpty ||
           _selectedTables.isNotEmpty ||
           _startDate != null ||
           _endDate != null;
  }
}
