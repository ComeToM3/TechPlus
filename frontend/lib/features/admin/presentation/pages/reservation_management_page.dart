import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_calendar_provider.dart';
import '../widgets/reservation_calendar_widget.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de gestion des réservations avec calendrier
class ReservationManagementPage extends ConsumerStatefulWidget {
  const ReservationManagementPage({super.key});

  @override
  ConsumerState<ReservationManagementPage> createState() => _ReservationManagementPageState();
}

class _ReservationManagementPageState extends ConsumerState<ReservationManagementPage> {
  @override
  void initState() {
    super.initState();
    // Charge les statistiques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationCalendarProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final calendarState = ref.watch(reservationCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationManagement),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Bouton de filtres
          IconButton(
            onPressed: _showFiltersDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.filters,
          ),
          // Bouton de rafraîchissement
          IconButton(
            onPressed: () {
              ref.read(reservationCalendarProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques rapides
              _buildQuickStats(context, calendarState, l10n),
              const SizedBox(height: 24),
              
              // Calendrier des réservations
              ReservationCalendarWidget(
                onReservationTap: () {
                  // TODO: Naviguer vers les détails de la réservation
                  _showReservationDetails();
                },
                onCreateReservation: () {
                  // TODO: Naviguer vers la création de réservation
                  _showCreateReservationDialog();
                },
              ),
              const SizedBox(height: 24),
              
              // Actions rapides
              _buildQuickActions(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    dynamic calendarState,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final statistics = calendarState.statistics;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.todayReservations,
            statistics?['todayReservations']?.toString() ?? '0',
            Icons.today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.confirmedReservations,
            statistics?['confirmedReservations']?.toString() ?? '0',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.pendingReservations,
            statistics?['pendingReservations']?.toString() ?? '0',
            Icons.pending,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.totalRevenue,
            '€${statistics?['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
            Icons.euro,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () {
                  _showCreateReservationDialog();
                },
                text: l10n.createReservation,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                icon: Icons.add,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SimpleButton(
                onPressed: () {
                  _showFiltersDialog();
                },
                text: l10n.filters,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
                icon: Icons.filter_list,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SimpleButton(
                onPressed: () {
                  // TODO: Exporter les réservations
                  _showExportDialog();
                },
                text: l10n.export,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
                icon: Icons.download,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filters),
        content: const Text('Filtres à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showCreateReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createReservation),
        content: const Text('Création de réservation à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationDetails),
        content: const Text('Détails de réservation à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.export),
        content: const Text('Export des réservations à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}
