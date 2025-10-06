import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../domain/entities/reservation_history.dart';
import '../widgets/client_info_widget.dart';
import '../widgets/reservation_history_widget.dart';
import '../widgets/reservation_notes_widget.dart';
import '../widgets/reservation_actions_widget.dart';
import '../providers/reservation_calendar_provider.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';

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
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
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

  void _loadReservationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Appeler l'API backend pour récupérer les données de la réservation
      final reservation = await _apiService.getReservation(widget.reservationId);
      
      // Convertir en ReservationCalendar pour l'affichage
      _reservation = ReservationCalendar(
        id: reservation.id,
        clientName: reservation.clientName ?? '',
        clientEmail: reservation.clientEmail ?? '',
        clientPhone: reservation.clientPhone ?? '',
        date: reservation.date,
        time: reservation.time,
        partySize: reservation.partySize,
        status: reservation.status.toLowerCase(),
        createdAt: reservation.createdAt ?? DateTime.now(),
        updatedAt: reservation.updatedAt ?? DateTime.now(),
        tableNumber: reservation.tableId ?? '',
        specialRequests: reservation.specialRequests ?? '',
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Afficher une erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

  void _handleAction(ReservationAction action) async {
    try {
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      switch (action) {
        case ReservationAction.confirm:
          await _updateReservationStatus('confirmed', 'Réservation confirmée');
          break;
        case ReservationAction.cancel:
          await _updateReservationStatus('cancelled', 'Réservation annulée');
          break;
        case ReservationAction.markCompleted:
          await _updateReservationStatus('completed', 'Réservation marquée comme terminée');
          break;
        case ReservationAction.markNoShow:
          await _updateReservationStatus('no_show', 'Réservation marquée comme no-show');
          break;
        case ReservationAction.reopen:
          await _updateReservationStatus('confirmed', 'Réservation rouverte');
          break;
        case ReservationAction.restore:
          await _updateReservationStatus('pending', 'Réservation restaurée');
          break;
        case ReservationAction.sendEmail:
          _sendEmail();
          break;
        case ReservationAction.sendSms:
          _sendSms();
          break;
        case ReservationAction.sendReminder:
          _sendReminder();
          break;
        case ReservationAction.assignTable:
          _assignTable();
          break;
        case ReservationAction.changeTime:
          _changeTime();
          break;
        case ReservationAction.addNote:
          _addNoteDialog();
          break;
        case ReservationAction.delete:
          _deleteReservation();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'action: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateReservationStatus(String status, String message) async {
    try {
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      final result = await calendarNotifier.updateReservationStatus(
        id: _reservation.id,
        status: _stringToReservationStatus(status),
        notes: message,
      );
      
      if (mounted && result != null) {
        setState(() {
          _reservation = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du statut'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Envoi d\'email à implémenter')),
    );
  }

  void _sendSms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Envoi de SMS à implémenter')),
    );
  }

  void _sendReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Envoi de rappel à implémenter')),
    );
  }

  void _assignTable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignation de table à implémenter')),
    );
  }

  void _changeTime() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changement d\'heure à implémenter')),
    );
  }

  void _addNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNote),
        content: const Text('Ajout de note à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note ajoutée')),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _editClient() {
    // Fonctionnalité d'édition du client - à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en développement')),
    );
  }

  void _contactClient() {
    // Fonctionnalité de contact du client - à implémenter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en développement')),
    );
  }

  void _editReservation() {
    // Naviguer vers une page d'édition ou ouvrir un dialogue
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editReservation),
        content: const Text('Fonctionnalité d\'édition de réservation'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performEditReservation();
            },
            child: Text(AppLocalizations.of(context)!.edit),
          ),
        ],
      ),
    );
  }

  void _performEditReservation() async {
    try {
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      // Créer une copie modifiée de la réservation
      final updatedReservation = ReservationCalendar(
        id: _reservation.id,
        clientName: _reservation.clientName,
        clientEmail: _reservation.clientEmail,
        clientPhone: _reservation.clientPhone,
        date: _reservation.date,
        time: _reservation.time,
        partySize: _reservation.partySize,
        status: _reservation.status,
        createdAt: _reservation.createdAt,
        updatedAt: DateTime.now(),
        tableNumber: _reservation.tableNumber,
        specialRequests: _reservation.specialRequests,
      );

      final result = await calendarNotifier.updateReservation(updatedReservation);
      
      if (mounted && result != null) {
        setState(() {
          _reservation = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réservation mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              _performDeleteReservation();
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _performDeleteReservation() async {
    try {
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      final success = await calendarNotifier.deleteReservation(_reservation.id);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réservation supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Rediriger vers la liste des réservations
        context.go('/admin/dashboard/reservations');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  ReservationStatus _stringToReservationStatus(String status) {
    return ReservationStatus.fromString(status);
  }
}
