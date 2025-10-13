import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../reservation/presentation/widgets/reservation_form_widget.dart';
import '../../../reservation/presentation/providers/public_reservation_provider.dart';
import '../../../../core/navigation/unified_navigation.dart';

/// Page de création de réservation admin (version simplifiée)
/// Utilise le même formulaire que les clients
class CreateReservationPageNew extends ConsumerStatefulWidget {
  const CreateReservationPageNew({super.key});

  @override
  ConsumerState<CreateReservationPageNew> createState() => _CreateReservationPageNewState();
}

class _CreateReservationPageNewState extends ConsumerState<CreateReservationPageNew> {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard/reservations'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            const SizedBox(height: 24),
            
            // Formulaire de réservation (même que les clients)
            ReservationFormWidget(
              isAdminMode: true, // Mode admin
              onReservationCreated: _handleReservationCreated,
              onCancel: () => context.go('/admin/dashboard/reservations'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme, l10n),
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
            l10n.createReservation,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createReservationDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme, AppLocalizations l10n) {
    return UnifiedBottomNavigation(
      currentIndex: 1, // Réservations est l'index 1
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/admin/dashboard');
            break;
          case 1:
            context.go('/admin/dashboard/reservations');
            break;
          case 2:
            context.go('/admin/dashboard/tables');
            break;
          case 3:
            context.go('/admin/dashboard/schedule');
            break;
          case 4:
            context.go('/admin/dashboard/menu');
            break;
          case 5:
            context.go('/admin/dashboard/analytics');
            break;
          case 6:
            context.go('/admin/dashboard/reports');
            break;
        }
      },
    );
  }

  Future<void> _handleReservationCreated(Reservation reservation) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
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
        // Rediriger vers la liste des réservations
        context.go('/admin/dashboard/reservations');
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
    }
  }
}
