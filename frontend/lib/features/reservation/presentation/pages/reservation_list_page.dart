import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/reservation_providers.dart';

class ReservationListPage extends ConsumerStatefulWidget {
  const ReservationListPage({super.key});

  @override
  ConsumerState<ReservationListPage> createState() =>
      _ReservationListPageState();
}

class _ReservationListPageState extends ConsumerState<ReservationListPage> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationStateProvider.notifier).loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationStateProvider);

    // Afficher les erreurs
    ref.listen(reservationStateProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(reservationStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/home/reservations/create'),
          ),
        ],
      ),
      body: reservationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservationState.reservations.isEmpty
          ? _buildEmptyState()
          : _buildReservationList(reservationState.reservations),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home/reservations/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore de réservation.\nCréez-en une maintenant !',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home/reservations/create'),
            child: const Text('Créer une réservation'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationList(List<Reservation> reservations) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reservationStateProvider.notifier).loadReservations();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return _buildReservationCard(reservation);
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(reservation.status),
          child: Icon(_getStatusIcon(reservation.status), color: Colors.white),
        ),
        title: Text(
          reservation.clientName ?? 'Réservation',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${reservation.partySize} personne${reservation.partySize > 1 ? 's' : ''}',
            ),
            Text('${_formatDate(reservation.date)} à ${reservation.time}'),
            if (reservation.requiresPayment &&
                reservation.paymentStatus == 'COMPLETED')
              const Text(
                '✅ Paiement confirmé',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        trailing: _buildStatusChip(reservation.status),
        onTap: () => context.go('/home/reservations/${reservation.id}'),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'CONFIRMED':
        color = Colors.green;
        label = 'Confirmée';
        break;
      case 'CANCELLED':
        color = Colors.red;
        label = 'Annulée';
        break;
      case 'COMPLETED':
        color = Colors.blue;
        label = 'Terminée';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      case 'COMPLETED':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
