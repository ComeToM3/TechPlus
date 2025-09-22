import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reservation_providers.dart';

class ReservationDetailPage extends ConsumerWidget {
  final String reservationId;

  const ReservationDetailPage({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationStateProvider);

    // Trouver la réservation par ID
    final reservation = reservationState.reservations
        .where((r) => r.id == reservationId)
        .firstOrNull;

    if (reservation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Réservation')),
        body: const Center(child: Text('Réservation non trouvée')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implémenter l'édition
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Informations générales', [
              _buildInfoRow('Date', _formatDate(reservation.date)),
              _buildInfoRow('Heure', reservation.time),
              _buildInfoRow('Durée', '${reservation.duration} minutes'),
              _buildInfoRow('Nombre de personnes', '${reservation.partySize}'),
              _buildInfoRow('Statut', reservation.status),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Informations client', [
              _buildInfoRow('Nom', reservation.clientName ?? 'Non renseigné'),
              _buildInfoRow(
                'Email',
                reservation.clientEmail ?? 'Non renseigné',
              ),
              _buildInfoRow(
                'Téléphone',
                reservation.clientPhone ?? 'Non renseigné',
              ),
            ]),
            if (reservation.notes != null ||
                reservation.specialRequests != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Notes et demandes', [
                if (reservation.notes != null)
                  _buildInfoRow('Notes', reservation.notes!),
                if (reservation.specialRequests != null)
                  _buildInfoRow(
                    'Demandes spéciales',
                    reservation.specialRequests!,
                  ),
              ]),
            ],
            if (reservation.requiresPayment) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Paiement', [
                _buildInfoRow('Acompte requis', 'Oui'),
                if (reservation.depositAmount != null)
                  _buildInfoRow('Montant', '${reservation.depositAmount}€'),
                _buildInfoRow('Statut paiement', reservation.paymentStatus),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
