import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/table_provider.dart' as data;
import '../../domain/entities/table_entity.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/table_provider.dart';
import '../widgets/interactive_restaurant_layout_widget.dart';
import '../widgets/table_form_widget.dart';
import '../widgets/table_list_widget.dart';
import '../widgets/table_statistics_widget.dart';

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
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.accessToken != null) {
        ref.read(data.tableProvider.notifier).loadTables(token: authState.accessToken!);
        ref.read(data.tableProvider.notifier).loadStatistics(token: authState.accessToken!);
      }
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
        final tables = ref.watch(tablesProvider);
        final tableState = ref.watch(data.tableProvider);
        
        if (tableState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (tableState.error != null) {
          return Center(
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
                  'Erreur lors du chargement des tables: ${tableState.error}',
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
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TableStatisticsWidget(
            tables: tables,
            onRefresh: _refreshData,
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    return Card(
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
    return Card(
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

  Future<void> _deleteTable(TableEntity table) async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        await ref.read(data.tableProvider.notifier).deleteTable(
          token: authState.accessToken!,
          tableId: table.id,
        );
      } catch (e) {
        // Gérer l'erreur si nécessaire
        rethrow;
      }
    }
  }

  void _refreshData() {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      ref.read(data.tableProvider.notifier).refreshTables(token: authState.accessToken!);
    }
  }

  Future<void> _handleCreateTable(TableEntity table) async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        final tableData = {
          'number': table.number,
          'capacity': table.capacity,
          'position': table.position,
        };
        await ref.read(data.tableProvider.notifier).createTable(
          token: authState.accessToken!,
          tableData: tableData,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> _handleUpdateTable(TableEntity table) async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        final tableData = {
          'number': table.number,
          'capacity': table.capacity,
          'position': table.position,
          'isActive': table.isActive,
        };
        await ref.read(data.tableProvider.notifier).updateTable(
          token: authState.accessToken!,
          tableId: table.id,
          tableData: tableData,
        );
      } catch (e) {
        rethrow;
      }
    }
  }
}

