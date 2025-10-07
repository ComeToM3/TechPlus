import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dashboard_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/unified_navigation.dart';
import '../../../../core/providers/theme_provider.dart';
import '../widgets/public_navigation_button.dart';

// Imports supprimés car non utilisés directement dans cette page
// La navigation se fait via GoRouter

/// Dashboard principal moderne et responsive pour l'administration
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final metricsState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme, l10n),
      body: _buildLayout(theme, l10n, metricsState),
      bottomNavigationBar: _buildBottomNavigationBar(theme, l10n),
    );
  }


  PreferredSizeWidget _buildAppBar(ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      leading: const PublicNavigationButton(),
      title: Text(
        'TechPlus Admin',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Bouton de basculement de thème
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeProvider);
            return IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
              ),
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              tooltip: themeMode == ThemeMode.dark 
                  ? 'Passer au thème clair' 
                  : 'Passer au thème sombre',
            );
          },
        ),
        
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

  Widget _buildLayout(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return Column(
      children: [
        // Header avec métriques rapides
        _buildMetricsHeader(theme, l10n, metricsState),
        
        // Contenu principal - seulement l'overview
        Expanded(
          child: _buildOverviewTab(theme, l10n, metricsState),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme, AppLocalizations l10n) {
    return UnifiedBottomNavigation(
      currentIndex: 0, // Dashboard est l'index 0
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
    );
  }




  Widget _buildMetricsHeader(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          : metricsState.errorMessage != null
              ? Text('Erreur: ${metricsState.errorMessage}')
              : metricsState.metrics != null
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 768;
                        final isTablet = constraints.maxWidth < 1024;
                        
                        if (isMobile) {
                          // Layout mobile : 2 colonnes
                          return Column(
                            children: [
                              Row(
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'En attente',
                                      metricsState.metrics!.pendingReservations.toString(),
                                      Icons.schedule,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'Confirmées',
                                      metricsState.metrics!.confirmedReservations.toString(),
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'Tables occupées',
                                      '${metricsState.metrics!.occupiedTables}/${metricsState.metrics!.totalTables}',
                                      Icons.table_restaurant,
                                      Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (isTablet) {
                          // Layout tablette : 2 lignes de 2 colonnes
                          return Column(
                            children: [
                              Row(
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'En attente',
                                      metricsState.metrics!.pendingReservations.toString(),
                                      Icons.schedule,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'Confirmées',
                                      metricsState.metrics!.confirmedReservations.toString(),
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      theme,
                                      'Tables occupées',
                                      '${metricsState.metrics!.occupiedTables}/${metricsState.metrics!.totalTables}',
                                      Icons.table_restaurant,
                                      Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Layout desktop : 4 colonnes
                          return Row(
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
                                  'En attente',
                                  metricsState.metrics!.pendingReservations.toString(),
                                  Icons.schedule,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMetricCard(
                                  theme,
                                  'Confirmées',
                                  metricsState.metrics!.confirmedReservations.toString(),
                                  Icons.check_circle,
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
                                  Colors.purple,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    )
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: isMobile 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Row(
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
      },
    );
  }

  Widget _buildOverviewTab(ThemeData theme, AppLocalizations l10n, DashboardState metricsState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          
              // Grille de cartes d'action responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  final isTablet = constraints.maxWidth < 1024;
                  
                  int crossAxisCount;
                  double childAspectRatio;
                  
                  if (isMobile) {
                    crossAxisCount = 4; // 4 colonnes sur mobile
                    childAspectRatio = 1.0; // Carré pour les bulles
                  } else if (isTablet) {
                    crossAxisCount = 4;
                    childAspectRatio = 2.5; // Plus horizontal
                  } else {
                    crossAxisCount = constraints.maxWidth > 1200 ? 4 : 4;
                    childAspectRatio = 2.0; // Plus horizontal
                  }
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 2 : 8,
                    mainAxisSpacing: isMobile ? 2 : 8,
                    childAspectRatio: childAspectRatio,
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
                        () => context.go('/admin/dashboard/tables'),
                      ),
                      _buildActionCard(
                        theme,
                        'Modifier les horaires',
                        Icons.schedule,
                        Colors.orange,
                        () => context.go('/admin/dashboard/schedule'),
                      ),
                      _buildActionCard(
                        theme,
                        'Gérer le menu',
                        Icons.menu_book,
                        Colors.purple,
                        () => context.go('/admin/dashboard/menu'),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Graphiques et statistiques responsive
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  
                  if (isMobile) {
                    // Layout mobile : colonnes empilées
                    return Column(
                      children: [
                        _buildChartCard(theme, 'Réservations récentes'),
                        const SizedBox(height: 16),
                        _buildStatsCard(theme, l10n, metricsState),
                      ],
                    );
                  } else {
                    // Layout desktop/tablette : côte à côte
                    return Row(
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
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(ThemeData theme, String title, IconData icon, Color color, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: isMobile 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4), // Moins de padding pour agrandir l'icône
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, color: color, size: 24), // Icône encore plus grande
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 60, // Largeur fixe pour forcer le texte sur deux lignes
                        child: Text(
                          title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: 8, // Texte plus petit pour les bulles carrées
                            height: 1.0, // Hauteur de ligne très réduite
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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
              : metricsState.errorMessage != null
                  ? Text('Erreur: ${metricsState.errorMessage}')
                  : metricsState.metrics != null
                      ? Column(
                          children: [
                            _buildStatRow(theme, 'Réservations totales', metricsState.metrics!.totalReservations.toString()),
                            _buildStatRow(theme, 'Confirmées', metricsState.metrics!.confirmedReservations.toString()),
                            _buildStatRow(theme, 'En attente', metricsState.metrics!.pendingReservations.toString()),
                            _buildStatRow(theme, 'Tables disponibles', (metricsState.metrics!.totalTables - metricsState.metrics!.occupiedTables).toString()),
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