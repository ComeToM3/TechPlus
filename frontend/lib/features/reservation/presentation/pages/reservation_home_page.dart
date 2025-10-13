import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Page d'accueil pour les réservations
class ReservationHomePage extends ConsumerWidget {
  const ReservationHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservations),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(theme, l10n),
              const SizedBox(height: 32),

              // Actions principales
              _buildMainActions(theme, l10n),
              const SizedBox(height: 32),

              // Informations
              _buildInfoSection(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeToRestaurant,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.reservationDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Réserver une table
        _buildActionCard(
          theme,
          l10n,
          title: l10n.makeReservation,
          description: l10n.makeReservationDescription,
          icon: Icons.table_restaurant,
          color: theme.colorScheme.primary,
          onTap: () => context.go('/reservation'),
        ),
        const SizedBox(height: 16),

        // Voir mes réservations
        _buildActionCard(
          theme,
          l10n,
          title: l10n.myReservations,
          description: l10n.myReservationsDescription,
          icon: Icons.list_alt,
          color: theme.colorScheme.secondary,
          onTap: () => _showMyReservations(theme, l10n),
        ),
        const SizedBox(height: 16),

        // Gérer une réservation
        _buildActionCard(
          theme,
          l10n,
          title: l10n.manageReservation,
          description: l10n.manageReservationDescription,
          icon: Icons.edit,
          color: theme.colorScheme.tertiary,
          onTap: () => _showManageReservation(theme, l10n),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
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
                l10n.importantInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(theme, l10n, Icons.schedule, l10n.openingHours),
          const SizedBox(height: 8),
          _buildInfoItem(theme, l10n, Icons.group, l10n.maxPartySize),
          const SizedBox(height: 8),
          _buildInfoItem(theme, l10n, Icons.phone, l10n.contactInfo),
          const SizedBox(height: 8),
          _buildInfoItem(theme, l10n, Icons.cancel, l10n.cancellationPolicy),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, AppLocalizations l10n, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _showMyReservations(ThemeData theme, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myReservations),
        content: Text(l10n.myReservationsDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la gestion des réservations
            },
            child: Text(l10n.manageReservation),
          ),
        ],
      ),
    );
  }

  void _showManageReservation(ThemeData theme, AppLocalizations l10n) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manageReservation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterReservationToken),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.reservationToken,
                hintText: l10n.reservationTokenHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                // TODO: Naviguer vers la gestion de réservation avec le token
                context.go('/reservation/manage/${controller.text}');
              }
            },
            child: Text(l10n.continue),
          ),
        ],
      ),
    );
  }
}
