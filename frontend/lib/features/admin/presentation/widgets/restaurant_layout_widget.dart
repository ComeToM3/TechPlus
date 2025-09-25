import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/restaurant_layout_entity.dart';
import '../providers/table_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour le plan du restaurant
class RestaurantLayoutWidget extends ConsumerStatefulWidget {
  final Function(TableEntity)? onTableSelected;
  final Function(TablePosition)? onTablePositionChanged;
  final bool isEditable;

  const RestaurantLayoutWidget({
    super.key,
    this.onTableSelected,
    this.onTablePositionChanged,
    this.isEditable = false,
  });

  @override
  ConsumerState<RestaurantLayoutWidget> createState() => _RestaurantLayoutWidgetState();
}

class _RestaurantLayoutWidgetState extends ConsumerState<RestaurantLayoutWidget> {
  RestaurantLayout? _layout;
  List<TableEntity> _tables = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
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
            _buildHeader(theme, l10n),
            const SizedBox(height: 16),

            // Contenu
            if (_isLoading)
              _buildLoadingState(theme, l10n)
            else if (_error != null)
              _buildErrorState(theme, l10n)
            else if (_layout != null)
              _buildLayoutContent(theme, l10n)
            else
              _buildEmptyState(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.restaurant,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.restaurantLayout,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (widget.isEditable)
          SimpleButton(
            onPressed: _saveLayout,
            text: l10n.save,
            type: ButtonType.primary,
            size: ButtonSize.small,
            icon: Icons.save,
          ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
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
            l10n.errorLoadingLayout,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SimpleButton(
            onPressed: _loadData,
            text: l10n.retry,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noLayout,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noLayoutDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutContent(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Informations du plan
        _buildLayoutInfo(theme, l10n),
        const SizedBox(height: 16),

        // Plan visuel
        _buildVisualLayout(theme, l10n),
      ],
    );
  }

  Widget _buildLayoutInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _layout!.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_layout!.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _layout!.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.straighten,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${_layout!.dimensions.width}m × ${_layout!.dimensions.height}m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.table_restaurant,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${_layout!.tablePositions.length} ${l10n.tables}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualLayout(ThemeData theme, AppLocalizations l10n) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Fond du restaurant
            Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
            ),

            // Tables
            ..._layout!.tablePositions.map((position) {
              final table = _tables.firstWhere(
                (t) => t.id == position.tableId,
                orElse: () => TableEntity(
                  id: position.tableId,
                  number: 0,
                  capacity: 0,
                  isActive: true,
                  restaurantId: '',
                  status: TableStatus.available,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              return _buildTableWidget(theme, l10n, table, position);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableWidget(ThemeData theme, AppLocalizations l10n, TableEntity table, TablePosition position) {
    return Positioned(
      left: position.x * 4, // Échelle pour l'affichage
      top: position.y * 4,
      child: GestureDetector(
        onTap: () => widget.onTableSelected?.call(table),
        child: Container(
          width: position.width * 4,
          height: position.height * 4,
          decoration: BoxDecoration(
            color: _getTableColor(theme, table.status),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getTableBorderColor(theme, table.status),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Numéro de table
              Text(
                '${table.number}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _getTableTextColor(theme, table.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              // Capacité
              Text(
                '${table.capacity}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getTableTextColor(theme, table.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTableColor(ThemeData theme, TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green.withOpacity(0.3);
      case TableStatus.occupied:
        return Colors.red.withOpacity(0.3);
      case TableStatus.reserved:
        return Colors.orange.withOpacity(0.3);
      case TableStatus.maintenance:
        return Colors.blue.withOpacity(0.3);
      case TableStatus.outOfOrder:
        return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getTableBorderColor(ThemeData theme, TableStatus status) {
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

  Color _getTableTextColor(ThemeData theme, TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green.shade800;
      case TableStatus.occupied:
        return Colors.red.shade800;
      case TableStatus.reserved:
        return Colors.orange.shade800;
      case TableStatus.maintenance:
        return Colors.blue.shade800;
      case TableStatus.outOfOrder:
        return Colors.grey.shade800;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger le plan du restaurant
      final layout = await ref.read(restaurantLayoutProvider.future);

      setState(() {
        _layout = layout;
        _tables = layout.tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLayout() async {
    if (_layout == null) return;

    try {
      await ref.read(tableActionsProvider.notifier).updateRestaurantLayout(_layout!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.layoutSaved),
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
    }
  }
}

