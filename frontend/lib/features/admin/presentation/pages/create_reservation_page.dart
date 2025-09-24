import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/client_selection_widget.dart';
import '../widgets/availability_selector_widget.dart';
import '../widgets/reservation_info_widget.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page de création de réservation par l'admin
class CreateReservationPage extends ConsumerStatefulWidget {
  const CreateReservationPage({super.key});

  @override
  ConsumerState<CreateReservationPage> createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends ConsumerState<CreateReservationPage> {
  String? _selectedClientId;
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 1;
  ReservationFormData _formData = const ReservationFormData(partySize: 1);
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createReservation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save),
            tooltip: l10n.saveDraft,
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
              // En-tête
              _buildHeader(theme, l10n),
              const SizedBox(height: 16),

              // Sélection client
              ClientSelectionWidget(
                selectedClientId: _selectedClientId,
                onClientSelected: _onClientSelected,
                onNewClient: _createNewClient,
              ),
              const SizedBox(height: 16),

              // Sélection disponibilité
              AvailabilitySelectorWidget(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                partySize: _partySize,
                onAvailabilityChanged: _onAvailabilityChanged,
              ),
              const SizedBox(height: 16),

              // Informations réservation
              ReservationInfoWidget(
                formData: _formData,
                onFormDataChanged: _onFormDataChanged,
                onValidate: _validateForm,
              ),
              const SizedBox(height: 16),

              // Actions finales
              _buildFinalActions(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.createReservation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isFormComplete() 
                        ? Colors.green.withOpacity(0.2) 
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isFormComplete() ? l10n.ready : l10n.incomplete,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _isFormComplete() ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.createReservationDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildProgressIndicator(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, AppLocalizations l10n) {
    final steps = [
      l10n.selectClient,
      l10n.selectAvailability,
      l10n.fillInformation,
    ];
    
    final completedSteps = [
      _selectedClientId != null,
      _selectedDate != null && _selectedTime != null,
      _formData.clientName != null && _formData.clientName!.isNotEmpty,
    ];

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = completedSteps[index];
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  size: 12,
                  color: isCompleted 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!isLast) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinalActions(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.finalActions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _isFormComplete() ? _createReservation : null,
                    text: l10n.createReservation,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    icon: Icons.add,
                    isLoading: _isCreating,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _previewReservation,
                    text: l10n.preview,
                    type: ButtonType.secondary,
                    size: ButtonSize.large,
                    icon: Icons.visibility,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SimpleButton(
                    onPressed: _saveDraft,
                    text: l10n.saveDraft,
                    type: ButtonType.secondary,
                    size: ButtonSize.medium,
                    icon: Icons.save,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleButton(
                    onPressed: _cancel,
                    text: l10n.cancel,
                    type: ButtonType.danger,
                    size: ButtonSize.medium,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onClientSelected(String? clientId) {
    setState(() {
      _selectedClientId = clientId;
    });
  }

  void _onAvailabilityChanged(DateTime? date, String? time) {
    setState(() {
      _selectedDate = date;
      _selectedTime = time;
      _formData = _formData.copyWith(
        date: date,
        time: time,
      );
    });
  }

  void _onFormDataChanged(ReservationFormData formData) {
    setState(() {
      _formData = formData;
      _partySize = formData.partySize;
    });
  }

  void _createNewClient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newClient),
        content: const Text('Création de nouveau client à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _validateForm() {
    // TODO: Implémenter la validation complète
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Validation du formulaire')),
    );
  }

  void _createReservation() async {
    if (!_isFormComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.formIncomplete),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // TODO: Implémenter la création de réservation
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reservationCreated),
            backgroundColor: Colors.green,
          ),
        );
        
        // Rediriger vers la liste des réservations
        context.go('/admin/dashboard/reservations');
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
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _previewReservation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.preview),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${_formData.clientName ?? 'Non sélectionné'}'),
            Text('Date: ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}'),
            Text('Heure: ${_selectedTime ?? 'Non sélectionnée'}'),
            Text('Personnes: ${_formData.partySize}'),
            if (_formData.specialRequests?.isNotEmpty == true)
              Text('Demandes: ${_formData.specialRequests}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    // TODO: Implémenter la sauvegarde de brouillon
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brouillon sauvegardé')),
    );
  }

  void _cancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancel),
        content: Text(AppLocalizations.of(context)!.cancelConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/admin/dashboard/reservations');
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  }

  bool _isFormComplete() {
    return _selectedClientId != null &&
           _selectedDate != null &&
           _selectedTime != null &&
           _formData.clientName != null &&
           _formData.clientName!.isNotEmpty;
  }
}

