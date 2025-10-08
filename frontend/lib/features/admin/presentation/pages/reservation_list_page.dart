import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_calendar_provider.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Page de liste complète des réservations
class ReservationListPage extends ConsumerStatefulWidget {
  const ReservationListPage({super.key});

  @override
  ConsumerState<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends ConsumerState<ReservationListPage> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les réservations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationCalendarProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        actions: [
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
            // Barre de recherche et filtres
            _buildSearchAndFilters(theme, l10n),

            // Liste des réservations
            Expanded(
              child: _buildReservationsList(theme, l10n, calendarState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/dashboard/reservations/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchReservations,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(theme, l10n, 'all', l10n.all),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, 'pending', l10n.pending),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, 'confirmed', l10n.confirmed),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, 'cancelled', l10n.cancelled),
                const SizedBox(width: 8),
                _buildFilterChip(theme, l10n, 'completed', l10n.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, AppLocalizations l10n, String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildReservationsList(ThemeData theme, AppLocalizations l10n, dynamic calendarState) {
    if (calendarState.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              'Erreur: ${calendarState.error}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            SimpleButton(
              onPressed: () {
                ref.read(reservationCalendarProvider.notifier).refresh();
              },
              text: l10n.retry,
              type: ButtonType.primary,
            ),
          ],
        ),
      );
    }

    final reservations = _filterReservations(calendarState.reservations);

    if (reservations.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    // Trier les réservations par date (plus récentes en premier)
    final sortedReservations = List<ReservationCalendar>.from(reservations)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // En-tête compact avec statistiques
          _buildCompactHeader(theme, l10n, sortedReservations),
          const SizedBox(height: 8),
          
          // Liste compacte des réservations
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedReservations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final reservation = sortedReservations[index];
              return _buildCompactReservationCard(theme, l10n, reservation);
            },
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterReservations(List<dynamic> reservations) {
    var filtered = reservations;

    // Filtrer par statut
    if (_selectedFilter != 'all') {
      filtered = filtered.where((reservation) {
        return reservation.status.toLowerCase() == _selectedFilter;
      }).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((reservation) {
        return reservation.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               reservation.clientEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               reservation.clientPhone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  String _getEmptyMessage(AppLocalizations l10n) {
    if (_selectedFilter != 'all') {
      return 'Aucune réservation ${_selectedFilter}';
    }
    if (_searchQuery.isNotEmpty) {
      return 'Aucune réservation trouvée pour "$_searchQuery"';
    }
    return 'Aucune réservation';
  }

  /// Construit l'état vide avec un design compact
  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(l10n),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première réservation pour commencer',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SimpleButton(
            onPressed: () {
              context.go('/admin/dashboard/reservations/create');
            },
            text: l10n.createReservation,
            type: ButtonType.primary,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  /// Construit l'en-tête compact avec statistiques
  Widget _buildCompactHeader(ThemeData theme, AppLocalizations l10n, List<ReservationCalendar> reservations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Statistiques rapides
    final todayReservations = reservations.where((r) => 
      r.date.year == today.year && 
      r.date.month == today.month && 
      r.date.day == today.day
    ).length;
    
    final pendingReservations = reservations.where((r) => r.status.toLowerCase() == 'pending').length;
    final confirmedReservations = reservations.where((r) => r.status.toLowerCase() == 'confirmed').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${reservations.length} réservation${reservations.length > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Actions',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildQuickStats(theme, todayReservations, pendingReservations, confirmedReservations),
        ],
      ),
    );
  }

  /// Construit les statistiques rapides
  Widget _buildQuickStats(ThemeData theme, int today, int pending, int confirmed) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _buildStatChip(theme, 'Aujourd\'hui', today, Colors.blue),
        _buildStatChip(theme, 'En attente', pending, Colors.orange),
        _buildStatChip(theme, 'Confirmées', confirmed, Colors.green),
      ],
    );
  }

  /// Construit une puce de statistique
  Widget _buildStatChip(ThemeData theme, String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Construit une carte de réservation compacte
  Widget _buildCompactReservationCard(ThemeData theme, AppLocalizations l10n, ReservationCalendar reservation) {
    final status = reservation.status.toLowerCase();
    final statusColor = _getStatusColor(status, theme);
    final dateFormat = DateFormat('dd/MM');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/admin/dashboard/reservations/${reservation.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Avatar du client avec initiale
                _buildClientAvatar(theme, reservation),
                const SizedBox(width: 12),

                // Informations principales - tout sur une ligne
                Expanded(
                  child: Row(
                    children: [
                      // Nom du client
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reservation.clientName.isNotEmpty 
                                  ? reservation.clientName 
                                  : 'Client anonyme',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dateFormat.format(reservation.date)} à ${reservation.time}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Détails de la réservation
                      _buildReservationDetails(theme, l10n, reservation),
                      const SizedBox(width: 12),

                      // Statut - cliquable pour actions rapides
                      GestureDetector(
                        onTap: () => _showQuickActions(context, theme, l10n, reservation),
                        child: _buildStatusIndicator(theme, status, statusColor),
                      ),
                    ],
                  ),
                ),

                // Actions minimales
                const SizedBox(width: 8),
                _buildMinimalActions(theme, l10n, reservation),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit l'avatar du client
  Widget _buildClientAvatar(ThemeData theme, ReservationCalendar reservation) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          reservation.clientName.isNotEmpty 
              ? reservation.clientName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Construit les détails de la réservation
  Widget _buildReservationDetails(ThemeData theme, AppLocalizations l10n, ReservationCalendar reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${reservation.partySize}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (reservation.tableNumber != null) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${reservation.tableNumber}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Construit l'indicateur de statut
  Widget _buildStatusIndicator(ThemeData theme, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 10,
            color: statusColor,
          ),
          const SizedBox(width: 3),
          Text(
            _getStatusLabel(status, AppLocalizations.of(context)!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les actions minimales
  Widget _buildMinimalActions(ThemeData theme, AppLocalizations l10n, ReservationCalendar reservation) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton d'actions rapides
        IconButton(
          onPressed: () => _showQuickActions(context, theme, l10n, reservation),
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Actions rapides',
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Affiche les actions rapides pour une réservation
  void _showQuickActions(BuildContext context, ThemeData theme, AppLocalizations l10n, ReservationCalendar reservation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Actions pour ${reservation.clientName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions disponibles
            ..._buildQuickActionButtons(theme, l10n, reservation),
          ],
        ),
      ),
    );
  }

  /// Construit les boutons d'actions rapides
  List<Widget> _buildQuickActionButtons(ThemeData theme, AppLocalizations l10n, ReservationCalendar reservation) {
    final status = reservation.status.toLowerCase();
    final actions = <Widget>[];

    // Action: Voir les détails
    actions.add(
      _buildQuickActionButton(
        theme,
        l10n,
        'Voir les détails',
        Icons.visibility,
        Colors.blue,
        () {
          Navigator.pop(context);
          context.go('/admin/dashboard/reservations/${reservation.id}');
        },
      ),
    );

    // Actions selon le statut
    if (status == 'pending') {
      actions.add(
        _buildQuickActionButton(
          theme,
          l10n,
          'Confirmer',
          Icons.check_circle,
          Colors.green,
          () {
            Navigator.pop(context);
            _updateReservationStatus(reservation.id, 'confirmed', 'Réservation confirmée');
          },
        ),
      );
      actions.add(
        _buildQuickActionButton(
          theme,
          l10n,
          'Annuler',
          Icons.cancel,
          Colors.red,
          () {
            Navigator.pop(context);
            _updateReservationStatus(reservation.id, 'cancelled', 'Réservation annulée');
          },
        ),
      );
    } else if (status == 'confirmed') {
      actions.add(
        _buildQuickActionButton(
          theme,
          l10n,
          'Marquer terminée',
          Icons.done,
          Colors.blue,
          () {
            Navigator.pop(context);
            _updateReservationStatus(reservation.id, 'completed', 'Réservation terminée');
          },
        ),
      );
    }

    return actions;
  }

  /// Construit un bouton d'action rapide
  Widget _buildQuickActionButton(
    ThemeData theme,
    AppLocalizations l10n,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retourne l'icône du statut
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done;
      case 'no_show':
        return Icons.person_off;
      default:
        return Icons.help;
    }
  }

  Widget _buildReservationCard(ThemeData theme, AppLocalizations l10n, dynamic reservation) {
    final status = reservation.status.toLowerCase();
    final statusColor = _getStatusColor(status, theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
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
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                    Text(
                      '${reservation.partySize} ${l10n.people}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                        if (reservation.tableNumber != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.table_restaurant,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                      Text(
                        '${l10n.table} ${reservation.tableNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                          ),
                        ],
                      ],
                      ),
                  ],
                ),
              ),
              
              // Statut et actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  const SizedBox(height: 8),
              PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleQuickAction(value, reservation);
                    },
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
                      if (status == 'pending') ...[
                  PopupMenuItem(
                          value: 'confirm',
                    child: Row(
                      children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                              Text(l10n.confirm),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                          value: 'cancel',
                    child: Row(
                      children: [
                              const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                              Text(l10n.cancel),
                            ],
                          ),
                        ),
                      ],
                      if (status == 'confirmed') ...[
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              const Icon(Icons.done, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(l10n.markCompleted),
                      ],
                    ),
                  ),
                      ],
                ],
                child: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleQuickAction(String action, dynamic reservation) {
    switch (action) {
      case 'view':
        context.go('/admin/dashboard/reservations/${reservation.id}');
        break;
      case 'edit':
        // TODO: Implémenter l'édition rapide
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Édition rapide à implémenter')),
        );
        break;
      case 'confirm':
        _updateReservationStatus(reservation.id, 'confirmed', 'Réservation confirmée');
        break;
      case 'cancel':
        _updateReservationStatus(reservation.id, 'cancelled', 'Réservation annulée');
        break;
      case 'complete':
        _updateReservationStatus(reservation.id, 'completed', 'Réservation terminée');
        break;
    }
  }

  void _updateReservationStatus(String reservationId, String status, String message) async {
    try {
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      final result = await calendarNotifier.updateReservationStatus(
        id: reservationId,
        status: _stringToReservationStatus(status),
        notes: message,
      );
      
      if (mounted && result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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

  ReservationStatus _stringToReservationStatus(String status) {
    return ReservationStatus.fromString(status);
  }
}