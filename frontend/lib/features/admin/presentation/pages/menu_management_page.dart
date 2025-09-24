import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/menu_items_list_widget.dart';
import '../../domain/entities/menu_entity.dart';
import '../providers/menu_management_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de gestion du menu
class MenuManagementPage extends ConsumerStatefulWidget {
  const MenuManagementPage({super.key});

  @override
  ConsumerState<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends ConsumerState<MenuManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuManagement),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCreateItemDialog,
            icon: const Icon(Icons.add),
            tooltip: l10n.createMenuItem,
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.restaurant_menu),
              text: l10n.menuItems,
            ),
            Tab(
              icon: const Icon(Icons.category),
              text: l10n.categories,
            ),
            Tab(
              icon: const Icon(Icons.image),
              text: l10n.images,
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: l10n.statistics,
            ),
          ],
        ),
      ),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMenuItemsTab(theme, l10n),
            _buildCategoriesTab(theme, l10n),
            _buildImagesTab(theme, l10n),
            _buildStatisticsTab(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemsTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Actions rapides
          _buildQuickActions(theme, l10n),
          const SizedBox(height: 16),

          // Liste des articles
          MenuItemsListWidget(
            onItemSelected: _onItemSelected,
            onItemEdit: _onItemEdit,
            onItemDelete: _onItemDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Actions rapides pour les catégories
          _buildCategoryActions(theme, l10n),
          const SizedBox(height: 16),

          // Liste des catégories
          _buildCategoriesList(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildImagesTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gestion des images
          _buildImageManagement(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistiques générales
          _buildGeneralStats(theme, l10n),
          const SizedBox(height: 16),

          // Articles populaires
          _buildPopularItems(theme, l10n),
          const SizedBox(height: 16),

          // Catégories populaires
          _buildPopularCategories(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _showCreateItemDialog,
                    text: l10n.createMenuItem,
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    icon: Icons.add,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _showBulkActionsDialog,
                    text: l10n.bulkActions,
                    type: ButtonType.secondary,
                    size: ButtonSize.medium,
                    icon: Icons.select_all,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryActions(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryActions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _showCreateCategoryDialog,
                    text: l10n.createCategory,
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    icon: Icons.add,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _reorderCategories,
                    text: l10n.reorderCategories,
                    type: ButtonType.secondary,
                    size: ButtonSize.medium,
                    icon: Icons.sort,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);
        final actionsState = ref.watch(categoryActionsProvider);

        return categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return _buildEmptyCategoriesState(theme, l10n);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(theme, l10n, category, actionsState);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(theme, l10n, error.toString()),
        );
      },
    );
  }

  Widget _buildCategoryCard(ThemeData theme, AppLocalizations l10n, MenuCategoryEntity category, CategoryActionsState actionsState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: BentoCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image de la catégorie
              if (category.image != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(category.image!),
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
                    Icons.category,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(width: 12),

              // Informations de la catégorie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ordre: ${category.sortOrder}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (category.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description!,
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

              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.isActive 
                      ? Colors.green.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: category.isActive ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  category.isActive ? 'Active' : 'Inactive',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: category.isActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageManagement(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.imageManagement,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.imageManagementDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _uploadImage,
                    text: l10n.uploadImage,
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    icon: Icons.upload,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _optimizeImages,
                    text: l10n.optimizeImages,
                    type: ButtonType.secondary,
                    size: ButtonSize.medium,
                    icon: Icons.tune,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStats(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(menuStatsProvider);

        return BentoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.generalStatistics,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                statsAsync.when(
                  data: (stats) {
                    return Column(
                      children: [
                        _buildStatRow(theme, l10n.totalItems, stats.totalItems.toString()),
                        _buildStatRow(theme, l10n.availableItems, stats.availableItems.toString()),
                        _buildStatRow(theme, l10n.unavailableItems, stats.unavailableItems.toString()),
                        _buildStatRow(theme, l10n.totalCategories, stats.totalCategories.toString()),
                        _buildStatRow(theme, l10n.averagePrice, '${stats.averagePrice.toStringAsFixed(2)}€'),
                        _buildStatRow(theme, l10n.totalRevenue, '${stats.totalRevenue.toStringAsFixed(2)}€'),
                        _buildStatRow(theme, l10n.totalOrders, stats.totalOrders.toString()),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Erreur: $error'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularItems(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final popularItemsAsync = ref.watch(popularMenuItemsProvider);

        return BentoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.popularItems,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                popularItemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Text(
                        l10n.noPopularItems,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildPopularItemCard(theme, l10n, item);
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Erreur: $error'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularCategories(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final popularCategoriesAsync = ref.watch(popularCategoriesProvider);

        return BentoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.popularCategories,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                popularCategoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Text(
                        l10n.noPopularCategories,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildPopularCategoryCard(theme, l10n, category);
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Erreur: $error'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItemCard(ThemeData theme, AppLocalizations l10n, PopularMenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${item.orderCount} commandes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCategoryCard(ThemeData theme, AppLocalizations l10n, PopularCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${category.itemCount} articles',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.category,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noCategories,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noCategoriesDescription,
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
            l10n.errorLoadingData,
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

  void _onItemSelected(MenuItemEntity item) {
    // TODO: Naviguer vers les détails de l'article
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Article ${item.name} sélectionné')),
    );
  }

  void _onItemEdit(MenuItemEntity item) {
    _showEditItemDialog(item);
  }

  void _onItemDelete(MenuItemEntity item) {
    _showDeleteItemDialog(item);
  }

  void _showCreateItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createMenuItem),
        content: const Text('Formulaire de création d\'article à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.edit} ${item.name}'),
        content: const Text('Formulaire d\'édition d\'article à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteMenuItem),
        content: Text(AppLocalizations.of(context)!.deleteMenuItemConfirmation(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem(item);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createCategory),
        content: const Text('Formulaire de création de catégorie à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bulkActions),
        content: const Text('Actions en lot à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _reorderCategories() {
    // TODO: Implémenter la réorganisation des catégories
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réorganisation des catégories à implémenter')),
    );
  }

  void _uploadImage() {
    // TODO: Implémenter l'upload d'image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload d\'image à implémenter')),
    );
  }

  void _optimizeImages() {
    // TODO: Implémenter l'optimisation des images
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Optimisation des images à implémenter')),
    );
  }

  void _deleteItem(MenuItemEntity item) {
    ref.read(menuItemActionsProvider.notifier).deleteMenuItem(item.id);
  }

  void _refreshData() {
    ref.invalidate(menuItemsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(menuStatsProvider);
    ref.invalidate(popularMenuItemsProvider);
    ref.invalidate(popularCategoriesProvider);
  }
}

