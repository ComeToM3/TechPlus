import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/menu_entity.dart';
import '../providers/menu_management_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour la liste des articles de menu
class MenuItemsListWidget extends ConsumerStatefulWidget {
  final Function(MenuItemEntity)? onItemSelected;
  final Function(MenuItemEntity)? onItemEdit;
  final Function(MenuItemEntity)? onItemDelete;
  final bool showActions;

  const MenuItemsListWidget({
    super.key,
    this.onItemSelected,
    this.onItemEdit,
    this.onItemDelete,
    this.showActions = true,
  });

  @override
  ConsumerState<MenuItemsListWidget> createState() => _MenuItemsListWidgetState();
}

class _MenuItemsListWidgetState extends ConsumerState<MenuItemsListWidget> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showAvailableOnly = false;
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

          // Liste des articles
          _buildItemsList(theme, l10n),
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
                hintText: l10n.searchMenuItems,
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

            // Filtres
            Row(
              children: [
                Expanded(
                  child: _buildCategoryFilter(theme, l10n),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAvailabilityFilter(theme, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);
        
        return categoriesAsync.when(
          data: (categories) {
            return DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.category,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(l10n.allCategories),
                ),
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Erreur: $error'),
        );
      },
    );
  }

  Widget _buildAvailabilityFilter(ThemeData theme, AppLocalizations l10n) {
    return CheckboxListTile(
      title: Text(l10n.availableOnly),
      value: _showAvailableOnly,
      onChanged: (value) {
        setState(() {
          _showAvailableOnly = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildItemsList(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final itemsAsync = ref.watch(menuItemsProvider);
        final actionsState = ref.watch(menuItemActionsProvider);

        return itemsAsync.when(
          data: (items) {
            final filteredItems = _filterItems(items);
            
            if (filteredItems.isEmpty) {
              return _buildEmptyState(theme, l10n);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildItemCard(theme, l10n, item, actionsState);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(theme, l10n, error.toString()),
        );
      },
    );
  }

  Widget _buildItemCard(ThemeData theme, AppLocalizations l10n, MenuItemEntity item, MenuItemActionsState actionsState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: BentoCard(
        onTap: () => widget.onItemSelected?.call(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de l'article
              Row(
                children: [
                  // Image de l'article
                  if (item.image != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item.image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 12),

                  // Informations de l'article
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.price.toStringAsFixed(2)}€',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (item.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Statut de disponibilité
                  _buildAvailabilityIndicator(theme, item.isAvailable),
                ],
              ),

              // Allergènes et caractéristiques
              if (item.allergens.isNotEmpty || item.isVegetarian || item.isVegan || item.isGlutenFree || item.isSpicy) ...[
                const SizedBox(height: 8),
                _buildCharacteristics(theme, l10n, item),
              ],

              // Actions
              if (widget.showActions) ...[
                const SizedBox(height: 12),
                _buildItemActions(theme, l10n, item, actionsState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityIndicator(ThemeData theme, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable 
            ? Colors.green.withOpacity(0.2) 
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable ? 'Disponible' : 'Indisponible',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isAvailable ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristics(ThemeData theme, AppLocalizations l10n, MenuItemEntity item) {
    final characteristics = <Widget>[];

    // Allergènes
    if (item.allergens.isNotEmpty) {
      characteristics.add(
        Wrap(
          spacing: 4,
          children: item.allergens.map((allergen) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Text(
                allergen,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Caractéristiques alimentaires
    final foodCharacteristics = <String>[];
    if (item.isVegetarian) foodCharacteristics.add('Végétarien');
    if (item.isVegan) foodCharacteristics.add('Végan');
    if (item.isGlutenFree) foodCharacteristics.add('Sans gluten');
    if (item.isSpicy) foodCharacteristics.add('Épicé');

    if (foodCharacteristics.isNotEmpty) {
      characteristics.add(
        Wrap(
          spacing: 4,
          children: foodCharacteristics.map((characteristic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Text(
                characteristic,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: characteristics,
    );
  }

  Widget _buildItemActions(ThemeData theme, AppLocalizations l10n, MenuItemEntity item, MenuItemActionsState actionsState) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: () => widget.onItemEdit?.call(item),
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
            onPressed: () => _toggleAvailability(item),
            text: item.isAvailable ? l10n.makeUnavailable : l10n.makeAvailable,
            type: item.isAvailable ? ButtonType.danger : ButtonType.primary,
            size: ButtonSize.small,
            icon: item.isAvailable ? Icons.visibility_off : Icons.visibility,
            isLoading: actionsState.isUpdating,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SimpleButton(
            onPressed: () => _showDeleteConfirmation(context, l10n, item),
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
            Icons.restaurant_menu,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? l10n.noMenuItems : l10n.noMenuItemsFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? l10n.noMenuItemsDescription 
                : l10n.noMenuItemsFoundDescription,
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
            l10n.errorLoadingMenuItems,
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

  List<MenuItemEntity> _filterItems(List<MenuItemEntity> items) {
    var filtered = items;

    // Filtrer par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // Filtrer par disponibilité
    if (_showAvailableOnly) {
      filtered = filtered.where((item) => item.isAvailable).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void _toggleAvailability(MenuItemEntity item) {
    ref.read(menuItemActionsProvider.notifier).toggleMenuItemAvailability(item.id);
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n, MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMenuItem),
        content: Text(l10n.deleteMenuItemConfirmation(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onItemDelete?.call(item);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

