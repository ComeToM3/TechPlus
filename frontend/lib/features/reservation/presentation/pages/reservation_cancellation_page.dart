import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/guest_management_provider.dart';
import '../widgets/refund_policy_widget.dart';
import '../widgets/cancellation_confirmation_widget.dart';
import '../widgets/cancellation_notification_widget.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page d'annulation complète d'une réservation
class ReservationCancellationPage extends ConsumerStatefulWidget {
  const ReservationCancellationPage({super.key});

  @override
  ConsumerState<ReservationCancellationPage> createState() => _ReservationCancellationPageState();
}

class _ReservationCancellationPageState extends ConsumerState<ReservationCancellationPage> {
  bool _showConfirmation = false;
  bool _showNotification = false;
  String? _cancellationReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);

    if (guestState.reservationDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Annulation'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Aucune réservation trouvée'),
        ),
      );
    }

    final reservation = guestState.reservationDetails!;
    final reservationDate = DateTime.parse(reservation['date']);
    final reservationTime = reservation['time'];
    final partySize = reservation['partySize'];
    final clientName = reservation['clientName'];
    final hasPayment = reservation['requiresPayment'] ?? false;
    final depositAmount = (reservation['depositAmount'] ?? 0.0).toDouble();
    final paymentStatus = reservation['paymentStatus'];

    // Calculer les informations de remboursement
    final timeParts = reservationTime.split(':');
    final fullReservationDateTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    
    final timeUntilReservation = fullReservationDateTime.difference(DateTime.now());
    final hoursUntilReservation = timeUntilReservation.inHours;
    final isRefundable = hoursUntilReservation > 24;
    final refundAmount = isRefundable ? depositAmount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Annuler la réservation'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manage-reservation?token=${guestState.token}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, guestState),
            
            const SizedBox(height: 24),
            
            if (!_showConfirmation && !_showNotification) ...[
              // Politique de remboursement
              RefundPolicyWidget(
                reservationDate: reservationDate,
                reservationTime: reservationTime,
                hasPayment: hasPayment,
                depositAmount: depositAmount,
                paymentStatus: paymentStatus,
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              _buildInitialActions(theme, guestState),
            ],
            
            if (_showConfirmation && !_showNotification) ...[
              // Confirmation d'annulation
              CancellationConfirmationWidget(
                reservationDate: reservationDate,
                reservationTime: reservationTime,
                partySize: partySize,
                clientName: clientName,
                hasPayment: hasPayment,
                depositAmount: depositAmount,
                isRefundable: isRefundable,
                refundAmount: refundAmount,
                onConfirmCancellation: _confirmCancellation,
                onCancel: _cancelCancellation,
                isLoading: guestState.isLoading,
              ),
            ],
            
            if (_showNotification) ...[
              // Notification de confirmation
              CancellationNotificationWidget(
                reservationId: reservation['id'] ?? 'N/A',
                reservationDate: reservationDate,
                reservationTime: reservationTime,
                partySize: partySize,
                clientName: clientName,
                cancellationReason: _cancellationReason ?? 'Non spécifié',
                isRefundable: isRefundable,
                refundAmount: refundAmount,
                refundStatus: 'PENDING',
                onClose: _closeNotification,
                onViewDetails: () => context.go('/manage-reservation?token=${guestState.token}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, GuestManagementState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.errorContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel,
                color: theme.colorScheme.onError,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Annulation de réservation',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onError,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Vous êtes sur le point d\'annuler votre réservation. Veuillez consulter la politique de remboursement ci-dessous.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onError,
            ),
          ),
          
          if (state.reservationId != null) ...[
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'N° ${state.reservationId}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialActions(ThemeData theme, GuestManagementState state) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.go('/manage-reservation?token=${state.token}'),
            text: 'Retour à la gestion',
            icon: Icons.arrow_back,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: AnimatedButton(
            onPressed: _startCancellation,
            text: 'Continuer l\'annulation',
            icon: Icons.cancel,
            type: ButtonType.danger,
            size: ButtonSize.large,
          ),
        ),
      ],
    );
  }

  void _startCancellation() {
    setState(() {
      _showConfirmation = true;
    });
  }

  void _confirmCancellation(String reason) {
    final notifier = ref.read(guestManagementProvider.notifier);
    
    notifier.cancelReservation(reason: reason);
    
    setState(() {
      _cancellationReason = reason;
      _showConfirmation = false;
      _showNotification = true;
    });
    
    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelCancellation() {
    setState(() {
      _showConfirmation = false;
    });
  }

  void _closeNotification() {
    // Retourner à la page de gestion
    final guestState = ref.read(guestManagementProvider);
    context.go('/manage-reservation?token=${guestState.token}');
  }
}
