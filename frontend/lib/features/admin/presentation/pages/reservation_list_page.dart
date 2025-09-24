import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../providers/reservation_calendar_provider.dart';
import '../widgets/reservation_filters_widget.dart';
import '../widgets/bulk_actions_widget.dart';
import '../widgets/export_widget.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de gestion des réservations en vue liste
class ReservationListPage extends ConsumerStatefulWidget {
  const ReservationListPage({super.key});

  @override
  ConsumerState<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends ConsumerState<ReservationListPage> {
  final List<String> _selectedReservations = [];
  bool _showFilters = false;
  bool _showExport = false;
  CalendarFilters _currentFilters = const CalendarFilters();

  @override
  void initState() {
    super.initState();
    // Charge les réservations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationCalendarProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final calendarState = ref.watch(reservationCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationList),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Bouton de filtres
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
                if (_showFilters) _showExport = false;
              });
            },
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            tooltip: l10n.filters,
          ),
          // Bouton d'export
          IconButton(
            onPressed: () {
              setState(() {
                _showExport = !_showExport;
                if (_showExport) _showFilters = false;
              });
            },
            icon: Icon(_showExport ? Icons.close : Icons.download),
            tooltip: l10n.export,
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
        child: Column(
          children: [
            // Filtres
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ReservationFiltersWidget(
                  initialFilters: _currentFilters,
                  onFiltersChanged: _onFiltersChanged,
                  onClearFilters: _onClearFilters,
                ),
              ),

            // Export
            if (_showExport)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ExportWidget(
                  reservations: calendarState.reservations,
                  filters: _currentFilters,
                  onExport: _onExport,
                ),
              ),

            // Actions en lot
            if (_selectedReservations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BulkActionsWidget(
                  selectedReservations: _selectedReservations,
                  onBulkAction: _onBulkAction,
                  onClearSelection: _clearSelection,
                ),
              ),

            // Liste des réservations
            Expanded(
              child: _buildReservationsList(context, calendarState, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(
    BuildContext context,
    dynamic calendarState,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    if (calendarState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (calendarState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingReservations,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              calendarState.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SimpleButton(
              onPressed: () {
                ref.read(reservationCalendarProvider.notifier).refresh();
              },
              text: l10n.retry,
              type: ButtonType.primary,
              size: ButtonSize.medium,
              icon: Icons.refresh,
            ),
          ],
        ),
      );
    }

    if (calendarState.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noReservations,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noReservationsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SimpleButton(
              onPressed: () {
                // TODO: Naviguer vers la création de réservation
                _showCreateReservationDialog();
              },
              text: l10n.createReservation,
              type: ButtonType.primary,
              size: ButtonSize.medium,
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: calendarState.reservations.length,
      itemBuilder: (context, index) {
        final reservation = calendarState.reservations[index];
        return _buildReservationCard(context, reservation, l10n);
      },
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ReservationCalendar reservation,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final status = ReservationStatus.fromString(reservation.status);
    final isSelected = _selectedReservations.contains(reservation.id);
    final statusColor = _getStatusColor(status, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: BentoCard(
        onTap: () => _toggleSelection(reservation.id),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected 
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Checkbox de sélection
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleSelection(reservation.id),
              ),
              
              // Indicateur de statut
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations de la réservation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reservation.clientName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${reservation.partySize} ${l10n.people}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (reservation.tableNumber != null)
                      Text(
                        '${l10n.table} ${reservation.tableNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleReservationAction(value, reservation),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        const Icon(Icons.visibility),
                        const SizedBox(width: 8),
                        Text(l10n.view),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 8),
                        Text(l10n.duplicate),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status, ThemeData theme) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
      case ReservationStatus.noShow:
        return Colors.grey;
    }
  }

  void _toggleSelection(String reservationId) {
    setState(() {
      if (_selectedReservations.contains(reservationId)) {
        _selectedReservations.remove(reservationId);
      } else {
        _selectedReservations.add(reservationId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedReservations.clear();
    });
  }

  void _onFiltersChanged(CalendarFilters filters) {
    setState(() {
      _currentFilters = filters;
    });
    ref.read(reservationCalendarProvider.notifier).applyFilters(filters);
  }

  void _onClearFilters() {
    setState(() {
      _currentFilters = const CalendarFilters();
    });
    ref.read(reservationCalendarProvider.notifier).applyFilters(_currentFilters);
  }

  void _onExport(ExportOptions options) {
    // TODO: Implémenter l'export des données
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export en ${options.format.name} en cours...'),
      ),
    );
  }

  void _onBulkAction(List<String> reservationIds, BulkAction action) {
    // TODO: Implémenter les actions en lot
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action ${action.name} sur ${reservationIds.length} réservations'),
      ),
    );
    _clearSelection();
  }

  void _handleReservationAction(String action, ReservationCalendar reservation) {
    switch (action) {
      case 'view':
        _showReservationDetails(reservation);
        break;
      case 'edit':
        _showEditReservation(reservation);
        break;
      case 'duplicate':
        _duplicateReservation(reservation);
        break;
      case 'delete':
        _deleteReservation(reservation);
        break;
    }
  }

  void _showReservationDetails(ReservationCalendar reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reservationDetails),
        content: Text('Détails de la réservation ${reservation.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showEditReservation(ReservationCalendar reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editReservation),
        content: Text('Modification de la réservation ${reservation.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _duplicateReservation(ReservationCalendar reservation) {
    // TODO: Implémenter la duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplication de réservation')),
    );
  }

  void _deleteReservation(ReservationCalendar reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteReservation),
        content: Text(AppLocalizations.of(context)!.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implémenter la suppression
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Réservation supprimée')),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete),
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
}
