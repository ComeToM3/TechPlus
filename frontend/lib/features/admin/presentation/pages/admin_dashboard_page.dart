import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/metrics_card.dart';
import '../widgets/today_reservations_widget.dart';
import '../widgets/occupancy_rate_widget.dart';
import '../widgets/revenue_widget.dart';
import '../widgets/top_tables_widget.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page principale du dashboard admin
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Charger les métriques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dashboardNotifier.refreshMetrics(),
            tooltip: l10n.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/admin/settings'),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardNotifier.refreshMetrics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec actions rapides
              _buildHeader(context, l10n),
              const SizedBox(height: 24),
              
              // Gestion des états
              if (dashboardState.isLoading)
                _buildLoadingState(theme)
              else if (dashboardState.errorMessage != null)
                _buildErrorState(theme, dashboardState.errorMessage!, l10n)
              else if (dashboardState.metrics != null)
                _buildDashboardContent(context, dashboardState.metrics!, l10n)
              else
                _buildEmptyState(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeBack,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dashboardOverview,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: () => context.go('/admin/reservations/new'),
                    text: l10n.newReservation,
                    type: ButtonType.outline,
                    size: ButtonSize.medium,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SimpleButton(
                    onPressed: () => context.go('/admin/reservations'),
                    text: l10n.viewReservations,
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement des métriques...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingData,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SimpleButton(
            onPressed: () => ref.read(dashboardProvider.notifier).refreshMetrics(),
            text: l10n.retry,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDataAvailable,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noDataDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardMetrics metrics, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Métriques principales
        _buildMainMetrics(metrics, l10n),
        const SizedBox(height: 24),
        
        // Widgets détaillés
        _buildDetailedWidgets(context, metrics, l10n),
        const SizedBox(height: 24),
        
        // Graphiques et tendances
        _buildChartsSection(context, metrics, l10n),
        const SizedBox(height: 24),
        
        // Occupation des tables
        _buildTableOccupancySection(context, metrics, l10n),
      ],
    );
  }

  Widget _buildMainMetrics(DashboardMetrics metrics, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.scaleIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mainMetrics,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              ReservationMetricsCard(
                count: metrics.todayReservations,
                label: l10n.todayReservations,
                icon: Icons.today,
                color: Colors.blue,
                onTap: () => context.go('/admin/reservations?filter=today'),
              ),
              RevenueMetricsCard(
                amount: metrics.todayRevenue,
                label: l10n.todayRevenue,
                icon: Icons.euro,
                color: Colors.green,
                onTap: () => context.go('/admin/analytics/revenue'),
              ),
              OccupancyMetricsCard(
                occupied: metrics.occupiedTables,
                total: metrics.totalTables,
                label: l10n.tableOccupancy,
                icon: Icons.table_restaurant,
                color: Colors.orange,
                onTap: () => context.go('/admin/tables'),
              ),
              ReservationMetricsCard(
                count: metrics.pendingReservations,
                label: l10n.pendingReservations,
                icon: Icons.pending,
                color: Colors.amber,
                onTap: () => context.go('/admin/reservations?filter=pending'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedWidgets(BuildContext context, DashboardMetrics metrics, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailedMetrics,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Première ligne : Réservations du jour et Taux d'occupation
        Row(
          children: [
            Expanded(
              child: TodayReservationsWidget(
                metrics: metrics,
                onViewAll: () => context.go('/admin/reservations?filter=today'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OccupancyRateWidget(
                metrics: metrics,
                onViewAll: () => context.go('/admin/tables'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Deuxième ligne : Revenus et Top Tables
        Row(
          children: [
            Expanded(
              child: RevenueWidget(
                metrics: metrics,
                onViewAll: () => context.go('/admin/analytics/revenue'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TopTablesWidget(
                metrics: metrics,
                onViewAll: () => context.go('/admin/tables'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, DashboardMetrics metrics, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.scaleIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trendsAndAnalytics,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder pour les graphiques
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chartsComingSoon,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildTableOccupancySection(BuildContext context, DashboardMetrics metrics, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tableStatus,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SimpleButton(
                onPressed: () => context.go('/admin/tables'),
                text: l10n.viewAll,
                type: ButtonType.outline,
                size: ButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder pour l'occupation des tables
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tableMapComingSoon,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}
