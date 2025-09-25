import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/table_list_widget.dart';
import '../widgets/restaurant_layout_widget.dart';
import '../widgets/interactive_restaurant_layout_widget.dart';
import '../widgets/table_statistics_widget.dart';
import '../widgets/table_form_widget.dart';
import '../../domain/entities/table_entity.dart';
import '../providers/table_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de gestion des tables
class TableManagementPage extends ConsumerStatefulWidget {
  const TableManagementPage({super.key});

  @override
  ConsumerState<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends ConsumerState<TableManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text(l10n.tableManagement),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCreateTableDialog,
            icon: const Icon(Icons.add),
            tooltip: l10n.createTable,
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
              icon: const Icon(Icons.list),
              text: l10n.list,
            ),
            Tab(
              icon: const Icon(Icons.restaurant),
              text: l10n.layout,
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
            _buildTablesListTab(theme, l10n),
            _buildLayoutTab(theme, l10n),
            _buildStatisticsTab(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesListTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Actions rapides
          _buildQuickActions(theme, l10n),
          const SizedBox(height: 16),

          // Liste des tables
          TableListWidget(
            onTableSelected: _onTableSelected,
            onTableEdit: _onTableEdit,
            onTableDelete: _onTableDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Plan interactif du restaurant
          InteractiveRestaurantLayoutWidget(
            onTableSelected: _onTableSelected,
            onTableEdit: _onTableEdit,
            onTableDelete: _onTableDelete,
            isEditable: true,
          ),
          const SizedBox(height: 16),

          // Actions sur le plan
          _buildLayoutActions(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final tablesAsync = ref.watch(tablesProvider);
        
        return tablesAsync.when(
          data: (tables) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TableStatisticsWidget(
              tables: tables,
              onRefresh: _refreshData,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur lors du chargement des tables: $error',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SimpleButton(
                  onPressed: _refreshData,
                  text: l10n.retry,
                  type: ButtonType.primary,
                ),
              ],
            ),
          ),
        );
      },
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
                  child: ElevatedButton.icon(
                    onPressed: _showCreateTableDialog,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createTable),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showBulkActionsDialog,
                    icon: const Icon(Icons.select_all),
                    label: Text(l10n.bulkActions),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutActions(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.layoutActions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _editLayout,
                    text: l10n.editLayout,
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    icon: Icons.edit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _resetLayout,
                    text: l10n.resetLayout,
                    type: ButtonType.secondary,
                    size: ButtonSize.medium,
                    icon: Icons.refresh,
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
        final tablesAsync = ref.watch(tablesProvider);
        final statsAsync = ref.watch(tableStatsProvider);

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
                tablesAsync.when(
                  data: (tables) {
                    final totalTables = tables.length;
                    final availableTables = tables.where((t) => t.status == TableStatus.available).length;
                    final occupiedTables = tables.where((t) => t.status == TableStatus.occupied).length;
                    final totalCapacity = tables.fold(0, (sum, table) => sum + table.capacity);

                    return Column(
                      children: [
                        _buildStatRow(theme, l10n.totalTables, totalTables.toString()),
                        _buildStatRow(theme, l10n.availableTables, availableTables.toString()),
                        _buildStatRow(theme, l10n.occupiedTables, occupiedTables.toString()),
                        _buildStatRow(theme, l10n.totalCapacity, totalCapacity.toString()),
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

  Widget _buildTableStats(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(tableStatsProvider);

        return BentoCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tableStatistics,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                statsAsync.when(
                  data: (stats) {
                    if (stats.isEmpty) {
                      return Text(
                        l10n.noStatistics,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return _buildStatCard(theme, l10n, stat);
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

  Widget _buildStatCard(ThemeData theme, AppLocalizations l10n, TableStats stat) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.table} ${stat.tableId}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(theme, l10n.reservations, '${stat.totalReservations}'),
              ),
              Expanded(
                child: _buildStatItem(theme, l10n.occupancy, '${(stat.averageOccupancy * 100).toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _buildStatItem(theme, l10n.revenue, '${stat.revenue.toStringAsFixed(2)}€'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _onTableSelected(TableEntity table) {
    // TODO: Naviguer vers les détails de la table
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table ${table.number} sélectionnée')),
    );
  }

  void _onTableEdit(TableEntity table) {
    _showEditTableDialog(table);
  }

  void _onTableDelete(TableEntity table) {
    _showDeleteTableDialog(table);
  }

  void _showCreateTableDialog() {
    showDialog(
      context: context,
      builder: (context) => TableFormWidget(
        onSave: _handleCreateTable,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showEditTableDialog(TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => TableFormWidget(
        table: table,
        onSave: _handleUpdateTable,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showDeleteTableDialog(TableEntity table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTable),
        content: Text(AppLocalizations.of(context)!.deleteTableConfirmation('${table.number}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTable(table);
            },
            child: Text(AppLocalizations.of(context)!.delete),
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

  void _editLayout() {
    // TODO: Implémenter l'édition du plan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition du plan à implémenter')),
    );
  }

  void _resetLayout() {
    // TODO: Implémenter la réinitialisation du plan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réinitialisation du plan à implémenter')),
    );
  }

  void _deleteTable(TableEntity table) {
    ref.read(tableActionsProvider.notifier).deleteTable(table.id);
  }

  void _refreshData() {
    ref.invalidate(tablesProvider);
    ref.invalidate(tableStatsProvider);
    ref.invalidate(restaurantLayoutProvider);
  }

  Future<void> _handleCreateTable(TableEntity table) async {
    try {
      final createRequest = CreateTableRequest(
        number: table.number,
        capacity: table.capacity,
        position: table.position,
        description: table.description,
      );
      await ref.read(tableActionsProvider.notifier).createTable(createRequest);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _handleUpdateTable(TableEntity table) async {
    try {
      final updateRequest = UpdateTableRequest(
        number: table.number,
        capacity: table.capacity,
        position: table.position,
        isActive: table.isActive,
        status: table.status,
        description: table.description,
      );
      await ref.read(tableActionsProvider.notifier).updateTable(table.id, updateRequest);
    } catch (e) {
      rethrow;
    }
  }
}

