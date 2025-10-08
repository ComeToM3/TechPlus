import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/table_provider.dart' as data;
import '../../domain/entities/table_entity.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/unified_navigation.dart';
import '../widgets/public_navigation_button.dart';
import '../widgets/interactive_restaurant_layout_widget.dart';
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
  bool _isDeleting = false; // État pour éviter les suppressions multiples
  // int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // _selectedTabIndex = _tabController.index;
      });
    });
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.accessToken != null && !authState.isLoading) {
        ref.read(data.tableProvider.notifier).loadTables(token: authState.accessToken!);
        ref.read(data.tableProvider.notifier).loadStatistics(token: authState.accessToken!);
      } else if (!authState.isLoading) {
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

    // Écouter les changements d'authentification
    ref.listen(authProvider, (previous, next) {
      if (next.accessToken != null && !next.isLoading && previous?.accessToken != next.accessToken) {
        ref.read(data.tableProvider.notifier).loadTables(token: next.accessToken!);
        ref.read(data.tableProvider.notifier).loadStatistics(token: next.accessToken!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: const PublicNavigationButton(),
        title: Text(l10n.tables),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      bottomNavigationBar: UnifiedBottomNavigation(
        currentIndex: 2, // Tables est l'index 2
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/admin/dashboard');
              break;
            case 1:
              context.go('/admin/dashboard/reservations');
              break;
            case 2:
              context.go('/admin/dashboard/tables');
              break;
            case 3:
              context.go('/admin/dashboard/schedule');
              break;
            case 4:
              context.go('/admin/dashboard/menu');
              break;
            case 5:
              context.go('/admin/dashboard/analytics');
              break;
            case 6:
              context.go('/admin/dashboard/reports');
              break;
          }
        },
      ),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: Column(
          children: [
            // En-tête avec actions
            _buildPageHeader(context, theme, l10n),
            const SizedBox(height: 16),
          
          // TabBar pour la navigation
          TabBar(
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
          
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTablesListTab(theme, l10n),
                _buildLayoutTab(theme, l10n),
                _buildStatisticsTab(theme, l10n),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.tableManagement,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
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
          ),
        ],
      ),
    );
  }

  Widget _buildTablesListTab(ThemeData theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // Liste des tables (sans actions rapides ni filtres)
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        final tableState = ref.watch(data.tableProvider);
        final tables = tableState.items;
        
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TableStatisticsWidget(
            tables: tables,
            onRefresh: _refreshData,
          ),
        );
      },
    );
  }


  Widget _buildLayoutActions(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    _deleteTable(table);
  }

  void _showCreateTableDialog() {
    context.push('/admin/dashboard/tables/create');
  }

  void _showEditTableDialog(TableEntity table) {
    // Utiliser la même page de création mais avec les données pré-remplies
    context.push('/admin/dashboard/tables/create', extra: table);
  }



  void _editLayout() {
    // Fonctionnalité d'édition du plan - à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en développement')),
    );
  }

  void _resetLayout() {
    // Fonctionnalité de réinitialisation du plan - à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en développement')),
    );
  }

  Future<void> _deleteTable(TableEntity table) async {
    if (_isDeleting) return; // Éviter les suppressions multiples
    
    // Afficher une confirmation avant suppression
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTable),
        content: Text(AppLocalizations.of(context)!.deleteTableConfirmation('${table.number}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return; // Annulation
    
    setState(() {
      _isDeleting = true;
    });
    
    if (kDebugMode) {
    }
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        if (kDebugMode) {
        }
        await ref.read(data.tableProvider.notifier).deleteTable(
          token: authState.accessToken!,
          tableId: table.id,
        );
        if (kDebugMode) {
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Table ${table.number} supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    } else {
      if (kDebugMode) {
      }
      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _refreshData() {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      ref.read(data.tableProvider.notifier).refreshTables(token: authState.accessToken!);
    }
  }
}
