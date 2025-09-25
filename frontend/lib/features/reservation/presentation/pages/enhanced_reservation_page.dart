import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/index.dart';
import '../../../../shared/errors/contextual_errors.dart';
import '../../../../shared/errors/enhanced_error_handler.dart';
import '../../../../shared/widgets/error/enhanced_error_display.dart';

/// Page de réservation améliorée avec gestion d'erreurs contextuelles
class EnhancedReservationPage extends ConsumerStatefulWidget {
  const EnhancedReservationPage({super.key});

  @override
  ConsumerState<EnhancedReservationPage> createState() => _EnhancedReservationPageState();
}

class _EnhancedReservationPageState extends ConsumerState<EnhancedReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _partySize = 2;
  String _specialRequests = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentError = ref.watch(currentErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une table'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Affichage des erreurs contextuelles
                if (currentError != null) ...[
                  EnhancedErrorDisplay(
                    error: currentError,
                    onRetry: () => _handleRetry(),
                    retryText: 'Réessayer la réservation',
                    showSuggestedActions: true,
                  ),
                  const SizedBox(height: 24),
                ],

                // Informations personnelles
                Text(
                  'Informations personnelles',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Votre nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'votre@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est obligatoire';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Format d\'email invalide';
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
                    hintText: '+33 1 23 45 67 89',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le téléphone est obligatoire';
                    }
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(' ', ''))) {
                      return 'Format de téléphone invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Détails de la réservation
                Text(
                  'Détails de la réservation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Sélection de la date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Sélectionner une date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sélection de l'heure
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Heure',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Sélectionner une heure',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre de personnes
                Row(
                  children: [
                    const Text('Nombre de personnes: '),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '$_partySize',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: _partySize < 12 ? () => setState(() => _partySize++) : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Demandes spéciales
                TextFormField(
                  onChanged: (value) => _specialRequests = value,
                  decoration: const InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    hintText: 'Allergies, préférences, etc.',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Bouton de réservation
                ElevatedButton(
                  onPressed: _handleReservation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Réserver une table'),
                ),
                const SizedBox(height: 16),

                // Boutons de test pour les erreurs contextuelles
                if (Theme.of(context).brightness == Brightness.light) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Tests d\'erreurs de réservation',
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTestButton(
                        'Créneau indisponible',
                        () => _testTimeSlotUnavailable(),
                        Colors.red,
                      ),
                      _buildTestButton(
                        'Trop de personnes',
                        () => _testMaxPartySizeExceeded(),
                        Colors.orange,
                      ),
                      _buildTestButton(
                        'Réservation trop tôt',
                        () => _testReservationTooEarly(),
                        Colors.amber,
                      ),
                      _buildTestButton(
                        'Restaurant fermé',
                        () => _testRestaurantClosed(),
                        Colors.grey,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _handleReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      _showValidationError();
      return;
    }

    try {
      // Créer la réservation via l'API
      final reservation = Reservation(
        id: '', // Sera généré par le backend
        date: _selectedDate!,
        time: _selectedTime!,
        duration: 90, // Durée par défaut
        partySize: _partySize,
        specialRequests: _specialRequestsController.text,
        clientName: _nameController.text,
        clientEmail: _emailController.text,
        clientPhone: _phoneController.text,
        status: 'PENDING',
        restaurantId: 'restaurant_1', // À récupérer depuis la configuration
      );

      // Appeler l'API backend pour créer la réservation
      final createdReservation = await _apiService.createReservation(reservation);
      
      // Succès
      EnhancedErrorHandler.showContextualSuccess(context, 'reservation_created');
      
    } catch (e) {
      // Créer une erreur contextuelle
      final errorFactory = ref.read(contextualErrorFactoryProvider);
      final error = errorFactory.fromException(e);
      
      // Ajouter l'erreur au provider
      ref.read(errorStateProvider.notifier).addError(error);
      
      // Afficher l'erreur
      EnhancedErrorHandler.showContextualError(context, error);
    }
  }

  void _handleRetry() {
    ref.read(errorStateProvider.notifier).clearCurrentError();
    _handleReservation();
  }

  void _showValidationError() {
    final error = ContextualValidationError.requiredField('date et heure');
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  // Méthodes de test pour les erreurs de réservation
  void _testTimeSlotUnavailable() {
    final error = ContextualReservationError.timeSlotUnavailable(maxPartySize: 8);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testMaxPartySizeExceeded() {
    final error = ContextualReservationError.maxPartySizeExceeded(6);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testReservationTooEarly() {
    final error = ContextualReservationError.reservationTooEarly();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testRestaurantClosed() {
    final error = ContextualReservationError.restaurantClosed();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }
}
