import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../domain/entities/reservation_history.dart';
import '../widgets/client_info_widget.dart';
import '../widgets/reservation_history_widget.dart';
import '../widgets/reservation_notes_widget.dart';
import '../widgets/reservation_actions_widget.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de détails d'une réservation
class ReservationDetailsPage extends ConsumerStatefulWidget {
  final String reservationId;

  const ReservationDetailsPage({
    super.key,
    required this.reservationId,
  });

  @override
  ConsumerState<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends ConsumerState<ReservationDetailsPage> {
  // Données simulées pour la démonstration
  late ReservationCalendar _reservation;
  List<ReservationHistory> _history = [];
  List<ReservationNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.reservationDetails),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationDetails),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
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
            children: [
              // En-tête de la réservation
              _buildReservationHeader(theme, l10n),
              const SizedBox(height: 16),

              // Informations client
              ClientInfoWidget(
                reservation: _reservation,
                onEditClient: _editClient,
                onContactClient: _contactClient,
              ),
              const SizedBox(height: 16),

              // Actions disponibles
              ReservationActionsWidget(
                reservation: _reservation,
                onActionSelected: _handleAction,
                onEditReservation: _editReservation,
                onDuplicateReservation: _duplicateReservation,
              ),
              const SizedBox(height: 16),

              // Historique des modifications
              ReservationHistoryWidget(
                history: _history,
                onRefresh: _refreshHistory,
              ),
              const SizedBox(height: 16),

              // Notes internes
              ReservationNotesWidget(
                notes: _notes,
                onAddNote: _addNote,
                onEditNote: _editNote,
                onDeleteNote: _deleteNote,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationHeader(ThemeData theme, AppLocalizations l10n) {
    final status = _reservation.status.toLowerCase();
    final statusColor = _getStatusColor(status, theme);
    final statusLabel = _getStatusLabel(status, l10n);

    return BentoCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reservationDetails,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_reservation.id}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informations principales
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    theme,
                    l10n.date,
                    '${_reservation.date.day}/${_reservation.date.month}/${_reservation.date.year}',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    theme,
                    l10n.time,
                    _reservation.time,
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    theme,
                    l10n.partySize,
                    '${_reservation.partySize} ${l10n.people}',
                    Icons.group,
                  ),
                ),
              ],
            ),

            if (_reservation.tableNumber != null) ...[
              const SizedBox(height: 12),
              _buildInfoColumn(
                theme,
                l10n.table,
                '${l10n.table} ${_reservation.tableNumber}',
                Icons.table_restaurant,
              ),
            ],

            if (_reservation.specialRequests != null && 
                _reservation.specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoColumn(
                theme,
                l10n.specialRequests,
                _reservation.specialRequests!,
                Icons.star,
                isMultiline: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis,
        ),
      ],
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

  void _loadReservationData() {
    // Simulation du chargement des données
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      // Données simulées
      _reservation = ReservationCalendar(
        id: widget.reservationId,
        clientName: 'Jean Tremblay',
        clientEmail: 'jean.tremblay@email.ca',
        clientPhone: '+1 514 123 4567',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '19:30',
        partySize: 4,
        status: 'confirmed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        tableNumber: '5',
        specialRequests: 'Table près de la fenêtre, anniversaire',
      );

      _history = [
        ReservationHistory(
          id: '1',
          reservationId: widget.reservationId,
          action: 'CREATED',
          description: 'Réservation créée',
          changedBy: 'Système',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ReservationHistory(
          id: '2',
          reservationId: widget.reservationId,
          action: 'CONFIRMED',
          description: 'Réservation confirmée',
          changedBy: 'Admin',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      _notes = [
        ReservationNote(
          id: '1',
          reservationId: widget.reservationId,
          content: 'Client VIP, traitement prioritaire',
          author: 'Admin',
          type: NoteType.special,
          isPrivate: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    });
  }

  void _refreshData() {
    _loadReservationData();
  }

  void _refreshHistory() {
    // TODO: Implémenter le rafraîchissement de l'historique
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historique rafraîchi')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editReservation();
        break;
      case 'duplicate':
        _duplicateReservation();
        break;
      case 'delete':
        _deleteReservation();
        break;
    }
  }

  void _handleAction(ReservationAction action) {
    // TODO: Implémenter les actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action: ${action.label}'),
      ),
    );
  }

  void _editClient() {
    // TODO: Implémenter l'édition du client
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition du client')),
    );
  }

  void _contactClient() {
    // TODO: Implémenter le contact du client
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact du client')),
    );
  }

  void _editReservation() {
    // TODO: Implémenter l'édition de la réservation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition de la réservation')),
    );
  }

  void _duplicateReservation() {
    // TODO: Implémenter la duplication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplication de la réservation')),
    );
  }

  void _deleteReservation() {
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

  void _addNote(ReservationNote note) {
    setState(() {
      _notes.add(note);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note ajoutée')),
    );
  }

  void _editNote(ReservationNote note) {
    // TODO: Implémenter l'édition de la note
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition de la note')),
    );
  }

  void _deleteNote(ReservationNote note) {
    setState(() {
      _notes.remove(note);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note supprimée')),
    );
  }
}
