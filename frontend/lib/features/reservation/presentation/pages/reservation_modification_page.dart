import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/guest_management_provider.dart';
import '../widgets/modification_date_time_selector.dart';
import '../widgets/modification_party_size_selector.dart';
import '../widgets/modification_info_form.dart';
import '../widgets/modification_validation_widget.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de modification complète d'une réservation
class ReservationModificationPage extends ConsumerStatefulWidget {
  const ReservationModificationPage({super.key});

  @override
  ConsumerState<ReservationModificationPage> createState() => _ReservationModificationPageState();
}

class _ReservationModificationPageState extends ConsumerState<ReservationModificationPage> {
  // État des modifications
  late DateTime _newDate;
  late String _newTime;
  late int _newPartySize;
  late String _newName;
  late String _newEmail;
  late String _newPhone;
  late String _newSpecialRequests;

  // État original
  late DateTime _originalDate;
  late String _originalTime;
  late int _originalPartySize;
  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;
  late String _originalSpecialRequests;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final guestState = ref.read(guestManagementProvider);
    
    // Données originales
    _originalDate = guestState.reservationDate!;
    _originalTime = guestState.reservationTime!;
    _originalPartySize = guestState.partySize!;
    _originalName = guestState.clientName!;
    _originalEmail = guestState.clientEmail!;
    _originalPhone = guestState.clientPhone ?? '';
    _originalSpecialRequests = guestState.specialRequests ?? '';
    
    // Données modifiées (initialisées avec les originales)
    _newDate = _originalDate;
    _newTime = _originalTime;
    _newPartySize = _originalPartySize;
    _newName = _originalName;
    _newEmail = _originalEmail;
    _newPhone = _originalPhone;
    _newSpecialRequests = _originalSpecialRequests;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la réservation'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manage-reservation?token=${guestState.token}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToOriginal,
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, guestState),
            
            const SizedBox(height: 24),
            
            // Sélecteur de date/heure
            ModificationDateTimeSelector(
              initialDate: _originalDate,
              initialTime: _originalTime,
              onDateTimeChanged: (date, time) {
                setState(() {
                  _newDate = date;
                  _newTime = time;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sélecteur du nombre de personnes
            ModificationPartySizeSelector(
              initialPartySize: _originalPartySize,
              onPartySizeChanged: (partySize) {
                setState(() {
                  _newPartySize = partySize;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Formulaire d'informations
            ModificationInfoForm(
              initialName: _originalName,
              initialEmail: _originalEmail,
              initialPhone: _originalPhone,
              initialSpecialRequests: _originalSpecialRequests,
              onInfoChanged: (name, email, phone, specialRequests) {
                setState(() {
                  _newName = name;
                  _newEmail = email;
                  _newPhone = phone;
                  _newSpecialRequests = specialRequests;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Validation des changements
            if (_hasChanges())
              ModificationValidationWidget(
                newDate: _newDate,
                newTime: _newTime,
                newPartySize: _newPartySize,
                newName: _newName,
                newEmail: _newEmail,
                newPhone: _newPhone,
                newSpecialRequests: _newSpecialRequests,
                originalDate: _originalDate,
                originalTime: _originalTime,
                originalPartySize: _originalPartySize,
                originalName: _originalName,
                originalEmail: _originalEmail,
                originalPhone: _originalPhone,
                originalSpecialRequests: _originalSpecialRequests,
                onConfirm: _confirmModifications,
                onCancel: _cancelModifications,
                isLoading: guestState.isLoading,
              ),
            
            const SizedBox(height: 24),
            
            // Actions de navigation
            _buildNavigationActions(theme, guestState),
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
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
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
                Icons.edit,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Modification de la réservation',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Modifiez les détails de votre réservation. Tous les changements seront validés avant application.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
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
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationActions(ThemeData theme, GuestManagementState state) {
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
            onPressed: _hasChanges() ? _resetToOriginal : null,
            text: 'Réinitialiser',
            icon: Icons.refresh,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
      ],
    );
  }

  bool _hasChanges() {
    return _newDate != _originalDate ||
           _newTime != _originalTime ||
           _newPartySize != _originalPartySize ||
           _newName != _originalName ||
           _newEmail != _originalEmail ||
           _newPhone != _originalPhone ||
           _newSpecialRequests != _originalSpecialRequests;
  }

  void _resetToOriginal() {
    setState(() {
      _newDate = _originalDate;
      _newTime = _originalTime;
      _newPartySize = _originalPartySize;
      _newName = _originalName;
      _newEmail = _originalEmail;
      _newPhone = _originalPhone;
      _newSpecialRequests = _originalSpecialRequests;
    });
  }

  void _confirmModifications() {
    final notifier = ref.read(guestManagementProvider.notifier);
    
    notifier.modifyReservation(
      newDate: _newDate,
      newTime: _newTime,
      newPartySize: _newPartySize,
      newSpecialRequests: _newSpecialRequests,
    );
    
    // Mettre à jour les données originales après modification
    _originalDate = _newDate;
    _originalTime = _newTime;
    _originalPartySize = _newPartySize;
    _originalName = _newName;
    _originalEmail = _newEmail;
    _originalPhone = _newPhone;
    _originalSpecialRequests = _newSpecialRequests;
    
    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation modifiée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelModifications() {
    _resetToOriginal();
  }
}
