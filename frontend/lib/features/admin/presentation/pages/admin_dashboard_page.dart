import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/dashboard_provider.dart';
import '../../data/models/dashboard_metrics_model.dart';
import '../../../../generated/l10n/app_localizations.dart';

import 'reservation_management_page.dart';
import 'table_management_page.dart';
import 'schedule_management_page.dart';
import 'analytics_page.dart';
import 'reports_page.dart';
import 'menu_management_page.dart';

/// Dashboard principal moderne et responsive pour l'administration
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
    final metricsState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, l10n),
      drawer: _buildDrawer(theme, l10n),
      body: Row(
        children: [
          // Sidebar pour desktop
          if (MediaQuery.of(context).size.width > 768)
            _buildDesktopSidebar(theme, l10n),
          
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Header avec métriques rapides
                _buildMetricsHeader(theme, l10n, metricsState),
                
                // Contenu des onglets
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(theme, l10n, metricsState),
                      const ReservationManagementPage(),
                      const TableManagementPage(),
                      const ScheduleManagementPage(),
                      const MenuManagementPage(),
                      const AnalyticsPage(),
                      const ReportsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.restaurant,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'TechPlus Admin',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Bouton de notification
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        
        // Bouton de profil
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                // Navigation vers profil
                break;
              case 'settings':
                context.go('/admin/dashboard/settings');
                break;
              case 'logout':
                // Logout logic
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Paramètres'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Déconnexion'),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(ThemeData theme, AppLocalizations l10n) {
    return Drawer(
      child: Column(
        children: [
          // Header du drawer
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.restaurant,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TechPlus',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Administration',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  theme,
                  Icons.dashboard,
                  'Tableau de bord',
                  () => _tabController.animateTo(0),
                  isSelected: _selectedTabIndex == 0,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.restaurant_menu,
                  'Réservations',
                  () => _tabController.animateTo(1),
                  isSelected: _selectedTabIndex == 1,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.table_restaurant,
                  'Gestion des tables',
                  () => _tabController.animateTo(2),
                  isSelected: _selectedTabIndex == 2,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.schedule,
                  'Horaires',
                  () => _tabController.animateTo(3),
                  isSelected: _selectedTabIndex == 3,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.menu_book,
                  'Menu',
                  () => _tabController.animateTo(4),
                  isSelected: _selectedTabIndex == 4,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.analytics,
                  'Analytiques',
                  () => _tabController.animateTo(5),
                  isSelected: _selectedTabIndex == 5,
                ),
                _buildDrawerItem(
                  theme,
                  Icons.assessment,
                  'Rapports',
                  () => _tabController.animateTo(6),
                  isSelected: _selectedTabIndex == 6,
                ),
                const Divider(),
                _buildDrawerItem(
                  theme,
                  Icons.settings,
                  'Paramètres',
                  () => context.go('/admin/dashboard/settings'),
                ),
                _buildDrawerItem(
                  theme,
                  Icons.help,
                  'Aide',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
    );
  }

  Widget _buildDesktopSidebar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.restaurant,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TechPlus',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Administration',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  theme,
                  Icons.dashboard,
                  'Tableau de bord',
                  () => _tabController.animateTo(0),
                  isSelected: _selectedTabIndex == 0,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.restaurant_menu,
                  'Réservations',
                  () => _tabController.animateTo(1),
                  isSelected: _selectedTabIndex == 1,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.table_restaurant,
                  'Gestion des tables',
                  () => _tabController.animateTo(2),
                  isSelected: _selectedTabIndex == 2,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.schedule,
                  'Horaires',
                  () => _tabController.animateTo(3),
                  isSelected: _selectedTabIndex == 3,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.menu_book,
                  'Menu',
                  () => _tabController.animateTo(4),
                  isSelected: _selectedTabIndex == 4,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.analytics,
                  'Analytiques',
                  () => _tabController.animateTo(5),
                  isSelected: _selectedTabIndex == 5,
                ),
                _buildSidebarItem(
                  theme,
                  Icons.assessment,
                  'Rapports',
                  () => _tabController.animateTo(6),
                  isSelected: _selectedTabIndex == 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMetricsHeader(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: metricsState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : metricsState.error != null
              ? Text('Erreur: ${metricsState.error}')
              : metricsState.metrics != null
                  ? Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                'Réservations aujourd\'hui',
                metricsState.metrics!.todayReservations.toString(),
                Icons.restaurant_menu,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Revenus aujourd\'hui',
                '${metricsState.metrics!.todayRevenue.toStringAsFixed(2)}\$',
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Tables occupées',
                '${metricsState.metrics!.occupiedTables}/${metricsState.metrics!.totalTables}',
                Icons.table_restaurant,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                theme,
                'Taux d\'occupation',
                '${(metricsState.metrics!.occupancyRate * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        )
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          Text(
            'Vue d\'ensemble',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          
          // Grille de cartes d'action
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 
                          MediaQuery.of(context).size.width > 768 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                theme,
                'Nouvelle réservation',
                Icons.add_circle_outline,
                Colors.blue,
                () => context.go('/admin/dashboard/reservations/create'),
              ),
              _buildActionCard(
                theme,
                'Gérer les tables',
                Icons.table_restaurant,
                Colors.green,
                () => _tabController.animateTo(2),
              ),
              _buildActionCard(
                theme,
                'Modifier les horaires',
                Icons.schedule,
                Colors.orange,
                () => _tabController.animateTo(3),
              ),
              _buildActionCard(
                theme,
                'Gérer le menu',
                Icons.menu_book,
                Colors.purple,
                () => _tabController.animateTo(4),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Graphiques et statistiques
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildChartCard(theme, 'Réservations récentes'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatsCard(theme, l10n, metricsState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(ThemeData theme, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          // Placeholder pour le graphique
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Graphique des réservations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          metricsState.isLoading 
              ? const CircularProgressIndicator()
              : metricsState.error != null
                  ? Text('Erreur: ${metricsState.error}')
                  : metricsState.metrics != null
                      ? Column(
                          children: [
                            _buildStatRow(theme, 'Réservations totales', metricsState.metrics!.totalReservations.toString()),
                            _buildStatRow(theme, 'Revenus totaux', '${metricsState.metrics!.totalRevenue.toStringAsFixed(2)}\$'),
                            _buildStatRow(theme, 'Tables disponibles', (metricsState.metrics!.totalTables - metricsState.metrics!.occupiedTables).toString()),
                            _buildStatRow(theme, 'Taux d\'occupation', '${(metricsState.metrics!.occupancyRate * 100).toStringAsFixed(1)}%'),
                          ],
                        )
                      : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}