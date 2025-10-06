import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_calendar_provider.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/navigation/unified_navigation.dart';
import 'create_reservation_page.dart';

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
        title: Text(l10n.reservations),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      bottomNavigationBar: UnifiedBottomNavigation(
        currentIndex: 1, // Réservations est l'index 1
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec actions
              _buildPageHeader(context, theme, l10n),
              const SizedBox(height: 24),
            
            // Statistiques rapides
            _buildQuickStats(context, calendarState, l10n),
            const SizedBox(height: 24),
            
            // Liste des réservations récentes
            _buildRecentReservations(context, theme, l10n),
            const SizedBox(height: 24),
            
            // Actions rapides
            _buildQuickActions(context, l10n),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.reservationManagement,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Row(
          children: [
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
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    dynamic calendarState,
    AppLocalizations l10n,
  ) {
    // final theme = Theme.of(context);
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
            'Réservations confirmées',
            '${statistics?['confirmedReservations']?.toString() ?? '0'}',
            Icons.check_circle,
            Colors.green,
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

  Widget _buildRecentReservations(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final calendarState = ref.watch(reservationCalendarProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Réservations récentes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la liste complète des réservations
                context.go('/admin/dashboard/reservations/list');
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (calendarState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (calendarState.error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              'Erreur: ${calendarState.error}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          )
        else if (calendarState.reservations.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune réservation récente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _buildReservationsList(theme, l10n, calendarState.reservations.take(5).toList()),
      ],
    );
  }

  Widget _buildReservationsList(ThemeData theme, AppLocalizations l10n, List<dynamic> reservations) {
    return Column(
      children: reservations.map((reservation) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildReservationCard(theme, l10n, reservation),
        );
      }).toList(),
    );
  }

  Widget _buildReservationCard(ThemeData theme, AppLocalizations l10n, dynamic reservation) {
    final status = reservation.status.toLowerCase();
    final statusColor = _getStatusColor(status, theme);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Naviguer vers les détails de la réservation
          context.go('/admin/dashboard/reservations/${reservation.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar du client
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  reservation.clientName.isNotEmpty 
                      ? reservation.clientName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations de la réservation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.clientName.isNotEmpty 
                          ? reservation.clientName 
                          : 'Client anonyme',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.partySize} ${l10n.people}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  _getStatusLabel(status, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
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

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'no_show':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'confirmed':
        return l10n.confirmed;
      case 'cancelled':
        return l10n.cancelled;
      case 'completed':
        return l10n.completed;
      case 'no_show':
        return l10n.noShow;
      default:
        return status;
    }
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
    // Naviguer vers la page de création de réservation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateReservationPage(),
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
