import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/reservation_providers.dart';

class CreateReservationPage extends ConsumerStatefulWidget {
  const CreateReservationPage({super.key});

  @override
  ConsumerState<CreateReservationPage> createState() =>
      _CreateReservationPageState();
}

class _CreateReservationPageState extends ConsumerState<CreateReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '19:00';
  int _partySize = 2;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 19, 0)),
    );
    if (time != null) {
      setState(() {
        _selectedTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final reservation = Reservation(
        id: '', // Sera généré par le serveur
        date: _selectedDate,
        time: _selectedTime,
        duration: _partySize <= 4
            ? 90
            : 120, // 1h30 pour 1-4 personnes, 2h pour 5+
        partySize: _partySize,
        status: 'PENDING',
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
        requiresPayment: _partySize >= AppConstants.paymentThreshold,
        depositAmount: _partySize >= AppConstants.paymentThreshold
            ? AppConstants.defaultDepositAmount
            : null,
        paymentStatus: _partySize >= AppConstants.paymentThreshold
            ? 'PENDING'
            : 'NONE',
        restaurantId: 'restaurant_1', // TODO: Récupérer depuis le contexte
      );

      await ref
          .read(reservationStateProvider.notifier)
          .createReservation(reservation);

      if (mounted) {
        context.go('/home/reservations');
      }
    }
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
      appBar: AppBar(title: const Text('Nouvelle réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations de base
              _buildSectionCard('Informations de base', [
                // Date
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
                // Heure
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Heure'),
                  subtitle: Text(_selectedTime),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectTime,
                ),
                // Nombre de personnes
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Nombre de personnes'),
                  subtitle: Text(
                    '$_partySize personne${_partySize > 1 ? 's' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _partySize > AppConstants.minPartySize
                            ? () => setState(() => _partySize--)
                            : null,
                      ),
                      Text('$_partySize'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _partySize < AppConstants.maxPartySize
                            ? () => setState(() => _partySize++)
                            : null,
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Informations client
              _buildSectionCard('Informations client', [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Veuillez saisir un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ]),

              const SizedBox(height: 16),

              // Notes et demandes
              _buildSectionCard('Notes et demandes spéciales', [
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialRequestsController,
                  decoration: const InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    prefixIcon: Icon(Icons.star),
                  ),
                  maxLines: 2,
                ),
              ]),

              if (_partySize >= AppConstants.paymentThreshold) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.payment,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Paiement requis',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Un acompte de ${AppConstants.defaultDepositAmount}€ est requis pour les réservations de ${AppConstants.paymentThreshold}+ personnes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: reservationState.isLoading ? null : _handleSubmit,
                child: reservationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Créer la réservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
