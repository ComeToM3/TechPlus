import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/guest_management_provider.dart';
import '../widgets/token_input_widget.dart';
import '../widgets/reservation_display_widget.dart';
import '../widgets/reservation_actions_widget.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de gestion des réservations pour les guests
class GuestManagementPage extends ConsumerStatefulWidget {
  final String? token;
  
  const GuestManagementPage({
    super.key,
    this.token,
  });

  @override
  ConsumerState<GuestManagementPage> createState() => _GuestManagementPageState();
}

class _GuestManagementPageState extends ConsumerState<GuestManagementPage> {
  @override
  void initState() {
    super.initState();
    // Si un token est fourni via l'URL, le valider automatiquement
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(guestManagementProvider.notifier).validateTokenAndLoadReservation(widget.token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer ma réservation'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
          tooltip: 'Retour à l\'accueil',
        ),
        actions: [
          if (guestState.hasReservationData)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshReservation(),
              tooltip: 'Actualiser',
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
            
            // Contenu principal
            if (!guestState.hasReservationData) ...[
              // Saisie du token
              const TokenInputWidget(),
            ] else ...[
              // Affichage de la réservation et actions
              const ReservationDisplayWidget(),
              const SizedBox(height: 24),
              const ReservationActionsWidget(),
            ],
            
            const SizedBox(height: 24),
            
            // Affichage des erreurs
            if (guestState.error != null)
              _buildErrorCard(theme, guestState.error!),
            
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
          colors: state.hasReservationData
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer,
                ]
              : [
                  theme.colorScheme.secondary,
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
          Row(
            children: [
              Icon(
                state.hasReservationData
                    ? Icons.restaurant
                    : Icons.key,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                state.hasReservationData
                    ? 'Votre réservation'
                    : 'Accès à votre réservation',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            state.hasReservationData
                ? 'Gérez votre réservation en toute simplicité. Modifiez, annulez ou consultez les détails.'
                : 'Saisissez votre token de gestion pour accéder à votre réservation et la gérer.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationActions(ThemeData theme, GuestManagementState state) {
    return Row(
      children: [
        // Bouton retour
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.go('/'),
            text: 'Retour à l\'accueil',
            icon: Icons.home,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Bouton nouvelle réservation
        Expanded(
          child: AnimatedButton(
            onPressed: () => context.go('/reservations/create'),
            text: 'Nouvelle réservation',
            icon: Icons.add,
            type: ButtonType.primary,
            size: ButtonSize.large,
          ),
        ),
      ],
    );
  }

  void _refreshReservation() {
    final currentState = ref.read(guestManagementProvider);
    if (currentState.token != null) {
      ref.read(guestManagementProvider.notifier).validateTokenAndLoadReservation(currentState.token!);
    }
  }
}
