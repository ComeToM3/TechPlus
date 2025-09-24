import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../providers/table_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour la liste des tables
class TableListWidget extends ConsumerStatefulWidget {
  final Function(TableEntity)? onTableSelected;
  final Function(TableEntity)? onTableEdit;
  final Function(TableEntity)? onTableDelete;
  final bool showActions;

  const TableListWidget({
    super.key,
    this.onTableSelected,
    this.onTableEdit,
    this.onTableDelete,
    this.showActions = true,
  });

  @override
  ConsumerState<TableListWidget> createState() => _TableListWidgetState();
}

class _TableListWidgetState extends ConsumerState<TableListWidget> {
  TableStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: Column(
        children: [
          // Filtres et recherche
          _buildFilters(theme, l10n),
          const SizedBox(height: 16),

          // Liste des tables
          _buildTablesList(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filters,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchTables,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Filtres par statut
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip(theme, l10n, null, l10n.all),
                  const SizedBox(width: 8),
                  ...TableStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildStatusChip(theme, l10n, status, status.displayName),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, AppLocalizations l10n, TableStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildTablesList(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final tablesAsync = ref.watch(tablesProvider);
        final actionsState = ref.watch(tableActionsProvider);

        return tablesAsync.when(
          data: (tables) {
            final filteredTables = _filterTables(tables);
            
            if (filteredTables.isEmpty) {
              return _buildEmptyState(theme, l10n);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTables.length,
              itemBuilder: (context, index) {
                final table = filteredTables[index];
                return _buildTableCard(theme, l10n, table, actionsState);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(theme, l10n, error.toString()),
        );
      },
    );
  }

  Widget _buildTableCard(ThemeData theme, AppLocalizations l10n, TableEntity table, TableActionsState actionsState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: BentoCard(
        onTap: () => widget.onTableSelected?.call(table),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la table
              Row(
                children: [
                  // Numéro de table
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${table.number}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Informations de la table
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.table} ${table.number}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${table.capacity} ${l10n.seats}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (table.position != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            table.position!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Statut de la table
                  _buildStatusIndicator(theme, table.status),
                ],
              ),

              // Description
              if (table.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  table.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              // Actions
              if (widget.showActions) ...[
                const SizedBox(height: 12),
                _buildTableActions(theme, l10n, table, actionsState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, TableStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(theme, status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(theme, status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: _getStatusColor(theme, status),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(theme, status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableActions(ThemeData theme, AppLocalizations l10n, TableEntity table, TableActionsState actionsState) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: () => widget.onTableEdit?.call(table),
            text: l10n.edit,
            type: ButtonType.secondary,
            size: ButtonSize.small,
            icon: Icons.edit,
            isLoading: actionsState.isUpdating,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SimpleButton(
            onPressed: () => _showDeleteConfirmation(context, l10n, table),
            text: l10n.delete,
            type: ButtonType.danger,
            size: ButtonSize.small,
            icon: Icons.delete,
            isLoading: actionsState.isDeleting,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.table_restaurant,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? l10n.noTables : l10n.noTablesFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? l10n.noTablesDescription 
                : l10n.noTablesFoundDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingTables,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<TableEntity> _filterTables(List<TableEntity> tables) {
    var filtered = tables;

    // Filtrer par statut
    if (_selectedStatus != null) {
      filtered = filtered.where((table) => table.status == _selectedStatus).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((table) {
        return table.number.toString().contains(_searchQuery) ||
               (table.position?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (table.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  Color _getStatusColor(ThemeData theme, TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.blue;
      case TableStatus.outOfOrder:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.person;
      case TableStatus.reserved:
        return Icons.schedule;
      case TableStatus.maintenance:
        return Icons.build;
      case TableStatus.outOfOrder:
        return Icons.error;
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n, TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTable),
        content: Text(l10n.deleteTableConfirmation('${table.number}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onTableDelete?.call(table);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

