import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour le plan interactif du restaurant
class InteractiveRestaurantLayoutWidget extends ConsumerStatefulWidget {
  final Function(TableEntity)? onTableSelected;
  final Function(TableEntity)? onTableEdit;
  final Function(TableEntity)? onTableDelete;
  final bool isEditable;

  const InteractiveRestaurantLayoutWidget({
    super.key,
    this.onTableSelected,
    this.onTableEdit,
    this.onTableDelete,
    this.isEditable = true,
  });

  @override
  ConsumerState<InteractiveRestaurantLayoutWidget> createState() => _InteractiveRestaurantLayoutWidgetState();
}

class _InteractiveRestaurantLayoutWidgetState extends ConsumerState<InteractiveRestaurantLayoutWidget> {
  final TransformationController _transformationController = TransformationController();
  TableEntity? _selectedTable;
  bool _isEditMode = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onTableTap(TableEntity table) {
    setState(() {
      _selectedTable = _selectedTable?.id == table.id ? null : table;
    });
    widget.onTableSelected?.call(table);
  }

  void _onTableEdit(TableEntity table) {
    widget.onTableEdit?.call(table);
  }

  void _onTableDelete(TableEntity table) {
    widget.onTableDelete?.call(table);
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedTable = null;
      }
    });
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
        title: l10n.restaurantLayout,
        subtitle: l10n.interactiveLayout,
        child: Column(
          children: [
            // Barre d'outils
            _buildToolbar(theme, l10n),
            const SizedBox(height: 16),

            // Plan du restaurant
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Container(
                      width: 800,
                      height: 600,
                      child: _buildRestaurantPlan(theme, l10n),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations de la table sélectionnée
            if (_selectedTable != null) _buildTableInfo(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        // Bouton d'édition
        SimpleButton(
          onPressed: _toggleEditMode,
          text: _isEditMode ? l10n.viewMode : l10n.editMode,
          type: _isEditMode ? ButtonType.primary : ButtonType.secondary,
          size: ButtonSize.small,
          icon: _isEditMode ? Icons.visibility : Icons.edit,
        ),
        const SizedBox(width: 8),

        // Bouton de réinitialisation
        SimpleButton(
          onPressed: _resetView,
          text: l10n.resetView,
          type: ButtonType.secondary,
          size: ButtonSize.small,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),

        // Bouton d'ajout (en mode édition)
        if (_isEditMode)
          SimpleButton(
            onPressed: () {
              // TODO: Ouvrir le formulaire de création de table
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.addTable)),
              );
            },
            text: l10n.addTable,
            type: ButtonType.primary,
            size: ButtonSize.small,
            icon: Icons.add,
          ),
      ],
    );
  }

  Widget _buildRestaurantPlan(ThemeData theme, AppLocalizations l10n) {
    return Stack(
      children: [
        // Arrière-plan du restaurant
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Zone d'entrée
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    l10n.entrance,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Zone principale du restaurant
              Expanded(
                child: Row(
                  children: [
                    // Zone gauche
                    Expanded(
                      flex: 2,
                      child: _buildTableGrid(theme, l10n, isLeftSide: true),
                    ),
                    
                    // Allée centrale
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    
                    // Zone droite
                    Expanded(
                      flex: 2,
                      child: _buildTableGrid(theme, l10n, isLeftSide: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tables (simulées pour l'instant)
        ..._buildTables(theme, l10n),
      ],
    );
  }

  Widget _buildTableGrid(ThemeData theme, AppLocalizations l10n, {required bool isLeftSide}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 8, // 8 tables par zone
        itemBuilder: (context, index) {
          final tableNumber = isLeftSide ? index + 1 : index + 9;
          return _buildTablePlaceholder(theme, l10n, tableNumber);
        },
      ),
    );
  }

  Widget _buildTablePlaceholder(ThemeData theme, AppLocalizations l10n, int tableNumber) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Text(
          'Table $tableNumber',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  List<Widget> _buildTables(ThemeData theme, AppLocalizations l10n) {
    // Tables simulées - à remplacer par les vraies données
    final tables = [
      TableEntity(
        id: '1',
        number: 1,
        capacity: 4,
        position: 'Gauche, près de la fenêtre',
        isActive: true,
        status: TableStatus.available,
        restaurantId: 'restaurant_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TableEntity(
        id: '2',
        number: 2,
        capacity: 6,
        position: 'Gauche, centre',
        isActive: true,
        status: TableStatus.occupied,
        restaurantId: 'restaurant_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TableEntity(
        id: '3',
        number: 3,
        capacity: 2,
        position: 'Droite, coin',
        isActive: true,
        status: TableStatus.reserved,
        restaurantId: 'restaurant_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return tables.map((table) {
      return Positioned(
        left: _getTablePosition(table.number).dx,
        top: _getTablePosition(table.number).dy,
        child: _buildTableWidget(theme, l10n, table),
      );
    }).toList();
  }

  Offset _getTablePosition(int tableNumber) {
    // Position simulée - à remplacer par la vraie logique
    switch (tableNumber) {
      case 1:
        return const Offset(50, 100);
      case 2:
        return const Offset(200, 100);
      case 3:
        return const Offset(350, 100);
      default:
        return const Offset(50, 200);
    }
  }

  Widget _buildTableWidget(ThemeData theme, AppLocalizations l10n, TableEntity table) {
    final isSelected = _selectedTable?.id == table.id;
    final statusColor = _getStatusColor(table.status, theme);

    return GestureDetector(
      onTap: () => _onTableTap(table),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : statusColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer 
                  : statusColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '${table.number}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer 
                    : statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${table.capacity}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer 
                    : statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableInfo(ThemeData theme, AppLocalizations l10n) {
    final table = _selectedTable!;
    
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
          Row(
            children: [
              Icon(
                Icons.table_restaurant,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.table} ${table.number}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_isEditMode) ...[
                IconButton(
                  onPressed: () => _onTableEdit(table),
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.edit,
                ),
                IconButton(
                  onPressed: () => _onTableDelete(table),
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.delete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${l10n.capacity}: ${table.capacity}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  table.position ?? l10n.noPosition,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(table.status, theme),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusLabel(table.status, l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getStatusColor(table.status, theme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
