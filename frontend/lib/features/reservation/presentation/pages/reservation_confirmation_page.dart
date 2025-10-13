import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/public_reservation_provider.dart';
import 'package:intl/intl.dart';

/// Page de confirmation de réservation
class ReservationConfirmationPage extends ConsumerStatefulWidget {
  final String reservationId;
  
  const ReservationConfirmationPage({
    super.key,
    required this.reservationId,
  });

  @override
  ConsumerState<ReservationConfirmationPage> createState() => _ReservationConfirmationPageState();
}

class _ReservationConfirmationPageState extends ConsumerState<ReservationConfirmationPage> {
  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  Future<void> _loadReservation() async {
    // Charger la réservation avec le service public
    try {
      final reservation = await ref.read(publicReservationServiceProvider).getReservation(widget.reservationId);
      // Mettre à jour l'état local si nécessaire
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors du chargement de la réservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reservationState = ref.watch(publicReservationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationConfirmation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: reservationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : reservationState.error != null
                ? _buildErrorState(theme, l10n, reservationState.error!)
                : _buildConfirmationContent(theme, l10n, reservationState.currentReservation!),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              l10n.reservationNotFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SimpleButton(
              onPressed: () => context.go('/'),
              text: l10n.backToHome,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationContent(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de succès
          _buildSuccessHeader(theme, l10n),
          const SizedBox(height: 24),

          // Détails de la réservation
          _buildReservationDetails(theme, l10n, reservation),
          const SizedBox(height: 24),

          // Informations client
          _buildClientInfo(theme, l10n, reservation),
          const SizedBox(height: 24),

          // Actions
          _buildActions(theme, l10n, reservation),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.reservationConfirmed,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reservationConfirmedMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'fr');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reservationDetails,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            theme,
            Icons.calendar_today,
            l10n.date,
            dateFormat.format(reservation.date),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            theme,
            Icons.access_time,
            l10n.time,
            reservation.time,
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            theme,
            Icons.group,
            l10n.partySize,
            '${reservation.partySize} ${reservation.partySize == 1 ? l10n.person : l10n.people}',
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            theme,
            Icons.table_restaurant,
            l10n.table,
            reservation.tableId != null ? '${l10n.table} ${reservation.tableId}' : l10n.tableToBeAssigned,
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            theme,
            Icons.schedule,
            l10n.duration,
            '${reservation.duration} ${l10n.minutes}',
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(
            theme,
            Icons.info,
            l10n.status,
            _getStatusText(reservation.status, l10n),
            statusColor: _getStatusColor(reservation.status, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.clientInformation,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (reservation.clientName != null)
            _buildDetailRow(
              theme,
              Icons.person,
              l10n.name,
              reservation.clientName!,
            ),
          if (reservation.clientName != null) const SizedBox(height: 12),
          
          if (reservation.clientEmail != null)
            _buildDetailRow(
              theme,
              Icons.email,
              l10n.email,
              reservation.clientEmail!,
            ),
          if (reservation.clientEmail != null) const SizedBox(height: 12),
          
          if (reservation.clientPhone != null)
            _buildDetailRow(
              theme,
              Icons.phone,
              l10n.phone,
              reservation.clientPhone!,
            ),
          if (reservation.clientPhone != null) const SizedBox(height: 12),
          
          if (reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty) ...[
            _buildDetailRow(
              theme,
              Icons.note,
              l10n.specialRequests,
              reservation.specialRequests!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SimpleButton(
            onPressed: () => context.go('/'),
            text: l10n.backToHome,
            type: ButtonType.primary,
            icon: Icons.home,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: SimpleButton(
            onPressed: () => _showManagementOptions(theme, l10n, reservation),
            text: l10n.manageReservation,
            type: ButtonType.secondary,
            icon: Icons.edit,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: statusColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return l10n.pending;
      case 'CONFIRMED':
        return l10n.confirmed;
      case 'CANCELLED':
        return l10n.cancelled;
      case 'COMPLETED':
        return l10n.completed;
      case 'NO_SHOW':
        return l10n.noShow;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'NO_SHOW':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _showManagementOptions(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
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
              l10n.manageReservation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Options de gestion
            ListTile(
              leading: const Icon(Icons.visibility),
              title: Text(l10n.viewReservation),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la vue détaillée
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.modifyReservation),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la modification
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: Text(l10n.cancelReservation),
              onTap: () {
                Navigator.pop(context);
                _showCancelConfirmation(theme, l10n, reservation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(ThemeData theme, AppLocalizations l10n, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelReservation),
        content: Text(l10n.cancelReservationConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelReservation(reservation);
            },
            child: Text(
              l10n.confirm,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(publicReservationProvider.notifier).cancelReservationWithToken(
        reservation.managementToken ?? '',
        reason: 'Annulé par le client',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reservationCancelled),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/');
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
}