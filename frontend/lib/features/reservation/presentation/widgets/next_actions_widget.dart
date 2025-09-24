import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_flow_provider.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour afficher les actions suivantes après confirmation
class NextActionsWidget extends ConsumerWidget {
  const NextActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationFlowProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.next_plan,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Prochaines étapes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Actions principales
                _buildMainActions(context, theme, reservationState),
                
                const SizedBox(height: 16),
                
                // Actions secondaires
                _buildSecondaryActions(context, theme, reservationState),
                
                const SizedBox(height: 16),
                
                // Informations importantes
                _buildImportantInfo(theme, reservationState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(
    BuildContext context,
    ThemeData theme,
    ReservationFlowState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions principales',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bouton Gérer ma réservation
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: () => _goToManageReservation(context, state),
            text: 'Gérer ma réservation',
            icon: Icons.settings,
            type: ButtonType.primary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bouton Nouvelle réservation
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: () => _startNewReservation(context),
            text: 'Faire une nouvelle réservation',
            icon: Icons.add,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(
    BuildContext context,
    ThemeData theme,
    ReservationFlowState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Autres actions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Actions en ligne
        _buildActionTile(
          context,
          theme,
          Icons.home,
          'Retour à l\'accueil',
          'Découvrir notre restaurant',
          () => context.go('/'),
        ),
        
        _buildActionTile(
          context,
          theme,
          Icons.restaurant_menu,
          'Voir notre menu',
          'Découvrir nos plats',
          () => context.go('/menu'),
        ),
        
        _buildActionTile(
          context,
          theme,
          Icons.info,
          'À propos',
          'En savoir plus sur nous',
          () => context.go('/about'),
        ),
        
        _buildActionTile(
          context,
          theme,
          Icons.contact_phone,
          'Nous contacter',
          'Questions ou demandes spéciales',
          () => context.go('/contact'),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildImportantInfo(ThemeData theme, ReservationFlowState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations importantes',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            theme,
            Icons.access_time,
            'Arrivée',
            'Merci d\'arriver 5 minutes avant votre réservation.',
          ),
          
          _buildInfoItem(
            theme,
            Icons.phone,
            'Contact',
            'En cas de retard ou d\'annulation, appelez-nous au +33 1 23 45 67 89',
          ),
          
          _buildInfoItem(
            theme,
            Icons.email,
            'Confirmation',
            'Un email de confirmation a été envoyé à ${state.clientEmail}',
          ),
          
          if (state.managementToken != null)
            _buildInfoItem(
              theme,
              Icons.key,
              'Gestion',
              'Conservez votre token de gestion pour modifier ou annuler votre réservation.',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToManageReservation(BuildContext context, ReservationFlowState state) {
    if (state.managementToken != null) {
      context.go('/manage-reservation?token=${state.managementToken}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token de gestion non disponible'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startNewReservation(BuildContext context) {
    // Naviguer vers la nouvelle réservation
    context.go('/reservations/create');
  }
}
