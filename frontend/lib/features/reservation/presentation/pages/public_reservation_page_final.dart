import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/public_reservation_provider.dart';

/// Page de réservation publique finale - Version simplifiée qui fonctionne
class PublicReservationPageFinal extends ConsumerStatefulWidget {
  const PublicReservationPageFinal({super.key});

  @override
  ConsumerState<PublicReservationPageFinal> createState() => _PublicReservationPageFinalState();
}

class _PublicReservationPageFinalState extends ConsumerState<PublicReservationPageFinal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 2;
  bool _isCreating = false;
  
  // Tables simulées pour la démo
  final List<Map<String, dynamic>> _availableTables = [
    {'id': '1', 'number': 1, 'capacity': 2},
    {'id': '2', 'number': 2, 'capacity': 4},
    {'id': '3', 'number': 3, 'capacity': 6},
    {'id': '4', 'number': 4, 'capacity': 8},
  ];
  
  String? _selectedTableId;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newReservation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reservations'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de date
              _buildDateSection(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de l'heure
              _buildTimeSection(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection du nombre de personnes
              _buildPartySizeSection(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de table
              if (_selectedTime != null) _buildTableSection(theme, l10n),
              if (_selectedTime != null) const SizedBox(height: 24),
              
              // Informations client
              _buildClientSection(theme, l10n),
              const SizedBox(height: 32),
              
              // Boutons d'action
              _buildActionButtons(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromTop,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onlineReservation,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onlineReservationDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner la date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Choisir une date',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(ThemeData theme, AppLocalizations l10n) {
    if (_selectedDate == null) return const SizedBox.shrink();

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner l\'heure',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['12:00', '13:00', '14:00', '19:00', '20:00', '21:00']
                    .map((time) => _buildTimeChip(theme, time))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(ThemeData theme, String time) {
    final isSelected = _selectedTime == time;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
          _selectedTableId = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPartySizeSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.partySize,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_partySize ${_partySize == 1 ? l10n.person : l10n.people}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _partySize < 20 ? () => setState(() => _partySize++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner une table',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTables
                    .where((table) => table['capacity'] >= _partySize)
                    .map((table) => _buildTableChip(theme, l10n, table))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableChip(ThemeData theme, AppLocalizations l10n, Map<String, dynamic> table) {
    final isSelected = _selectedTableId == table['id'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTableId = table['id']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.table} ${table['number']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${table['capacity']} ${l10n.people}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos Informations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nom
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  if (!value.contains('@')) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Demandes spéciales
              TextFormField(
                controller: _specialRequestsController,
                decoration: InputDecoration(
                  labelText: l10n.specialRequests,
                  prefixIcon: const Icon(Icons.note),
                  hintText: l10n.specialRequestsHint,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Row(
        children: [
          Expanded(
            child: SimpleButton(
              onPressed: () => context.go('/reservations'),
              text: l10n.cancel,
              type: ButtonType.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SimpleButton(
              onPressed: _isCreating ? null : _createReservation,
              text: _isCreating ? 'Création...' : l10n.createReservation,
              type: ButtonType.primary,
              isLoading: _isCreating,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
        _selectedTableId = null;
      });
    }
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseCompleteAllFields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final reservation = Reservation(
        id: '', // Sera généré par le backend
        date: _selectedDate!,
        time: _selectedTime!,
        duration: _partySize <= 4 ? 90 : 120,
        partySize: _partySize,
        status: 'PENDING',
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        specialRequests: _specialRequestsController.text.trim().isEmpty
            ? null
            : _specialRequestsController.text.trim(),
        restaurantId: 'restaurant_1', // TODO: Récupérer depuis la configuration
        tableId: _selectedTableId!,
      );

      final createdReservation = await ref
          .read(publicReservationProvider.notifier)
          .createPublicReservation(reservation);

      if (mounted && createdReservation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reservationCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // Rediriger vers la page de confirmation
        context.go('/reservation/confirmation/${createdReservation.id}');
      } else if (mounted) {
        final error = ref.read(publicReservationProvider).creationError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${error ?? l10n.unknownError}'),
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
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
