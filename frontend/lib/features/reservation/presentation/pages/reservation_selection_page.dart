import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_flow_provider.dart';
import '../widgets/interactive_calendar.dart';
import '../widgets/time_slot_selector.dart';
import '../widgets/party_size_selector.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de sélection pour la réservation (Étape 1)
class ReservationSelectionPage extends ConsumerStatefulWidget {
  const ReservationSelectionPage({super.key});

  @override
  ConsumerState<ReservationSelectionPage> createState() => _ReservationSelectionPageState();
}

class _ReservationSelectionPageState extends ConsumerState<ReservationSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);
    final availableDates = ref.watch(availableDatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une table'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
            tooltip: 'Retour à l\'accueil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme),
            
            const SizedBox(height: 24),
            
            // Étape 1: Sélection de la date
            _buildStepHeader(theme, 1, 'Sélectionnez une date', true),
            const SizedBox(height: 16),
            InteractiveCalendar(
              selectedDate: reservationState.selectedDate,
              availableDates: availableDates,
              onDateSelected: (date) {
                ref.read(reservationFlowProvider.notifier).selectDate(date);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Étape 2: Sélection du créneau
            _buildStepHeader(
              theme,
              2,
              'Choisissez un créneau',
              reservationState.selectedDate != null,
            ),
            const SizedBox(height: 16),
            if (reservationState.selectedDate != null)
              TimeSlotSelector(
                selectedTime: reservationState.selectedTime,
                availableTimes: reservationState.availableTimes,
                onTimeSelected: (time) {
                  ref.read(reservationFlowProvider.notifier).selectTime(time);
                },
              )
            else
              _buildDisabledCard(theme, 'Sélectionnez d\'abord une date'),
            
            const SizedBox(height: 24),
            
            // Étape 3: Nombre de personnes
            _buildStepHeader(
              theme,
              3,
              'Nombre de personnes',
              reservationState.selectedDate != null && reservationState.selectedTime != null,
            ),
            const SizedBox(height: 16),
            if (reservationState.selectedDate != null && reservationState.selectedTime != null)
              PartySizeSelector(
                partySize: reservationState.partySize,
                onPartySizeChanged: (size) {
                  ref.read(reservationFlowProvider.notifier).setPartySize(size);
                },
              )
            else
              _buildDisabledCard(theme, 'Sélectionnez d\'abord une date et un créneau'),
            
            const SizedBox(height: 32),
            
            // Bouton de validation
            _buildValidationButton(theme, reservationState),
            
            const SizedBox(height: 16),
            
            // Affichage des erreurs
            if (reservationState.error != null)
              _buildErrorCard(theme, reservationState.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réservez votre table',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez votre date, heure et nombre de personnes pour commencer votre réservation.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(ThemeData theme, int stepNumber, String title, bool isEnabled) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isEnabled
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isEnabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledCard(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationButton(ThemeData theme, ReservationFlowState state) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedButton(
        onPressed: state.canProceedToNextStep
            ? () => _proceedToNextStep()
            : null,
        text: 'Continuer',
        icon: Icons.arrow_forward,
        type: ButtonType.primary,
        size: ButtonSize.large,
        isLoading: state.isLoading,
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToNextStep() {
    final notifier = ref.read(reservationFlowProvider.notifier);
    
    if (notifier.validateSelection()) {
      // Naviguer vers l'étape suivante (informations client)
      context.go('/reservations/create/info');
    }
  }
}
