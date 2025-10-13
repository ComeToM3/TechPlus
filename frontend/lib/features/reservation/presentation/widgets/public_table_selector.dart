import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour sélectionner une table dans la réservation publique
/// Utilise le même style que les widgets admin mais adapté pour le public
class PublicTableSelector extends StatelessWidget {
  final String? selectedTableId;
  final List<Map<String, dynamic>> availableTables;
  final Function(Map<String, dynamic>) onTableSelected;
  final bool isLoading;

  const PublicTableSelector({
    super.key,
    this.selectedTableId,
    required this.availableTables,
    required this.onTableSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return _buildLoadingState(theme, l10n);
    }

    if (availableTables.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return _buildTables(theme, l10n);
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.loadingTables,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.noTablesAvailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTables(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectTable,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTables.map((table) {
              final isSelected = selectedTableId == table['id'];
              return _buildTableCard(theme, l10n, table, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(ThemeData theme, AppLocalizations l10n, Map<String, dynamic> table, bool isSelected) {
    return GestureDetector(
      onTap: () => onTableSelected(table),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_restaurant,
                  size: 16,
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${l10n.table} ${table['number']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group,
                  size: 14,
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${table['capacity']} ${l10n.people}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
