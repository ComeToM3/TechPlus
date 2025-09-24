import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/guest_management_provider.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour afficher les actions disponibles sur la réservation
class ReservationActionsWidget extends ConsumerStatefulWidget {
  const ReservationActionsWidget({super.key});

  @override
  ConsumerState<ReservationActionsWidget> createState() => _ReservationActionsWidgetState();
}

class _ReservationActionsWidgetState extends ConsumerState<ReservationActionsWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);
    final notifier = ref.read(guestManagementProvider.notifier);

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
                  Icons.settings,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Actions disponibles',
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
                _buildMainActions(theme, guestState, notifier),
                
                const SizedBox(height: 16),
                
                // Actions secondaires
                _buildSecondaryActions(theme, guestState),
                
                const SizedBox(height: 16),
                
                // Informations sur les limitations
                _buildLimitationsInfo(theme, guestState, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions(
    ThemeData theme,
    GuestManagementState state,
    GuestManagementNotifier notifier,
  ) {
    final canModify = notifier.canModifyReservation();
    final canCancel = notifier.canCancelReservation();

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
        
        // Bouton Modifier
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: canModify && !state.isLoading
                ? () => _showModifyDialog(context, state, notifier)
                : null,
            text: 'Modifier la réservation',
            icon: Icons.edit,
            type: ButtonType.primary,
            size: ButtonSize.large,
            isLoading: state.isLoading,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bouton Annuler
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: canCancel && !state.isLoading
                ? () => _showCancelDialog(context, state, notifier)
                : null,
            text: 'Annuler la réservation',
            icon: Icons.cancel,
            type: ButtonType.secondary,
            size: ButtonSize.large,
            isLoading: state.isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(ThemeData theme, GuestManagementState state) {
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
          theme,
          Icons.share,
          'Partager la réservation',
          'Envoyer les détails par email ou SMS',
          () => _shareReservation(state),
        ),
        
        _buildActionTile(
          theme,
          Icons.print,
          'Imprimer la réservation',
          'Générer un PDF pour impression',
          () => _printReservation(state),
        ),
        
        _buildActionTile(
          theme,
          Icons.phone,
          'Nous contacter',
          'Appeler le restaurant pour des questions',
          () => _contactRestaurant(),
        ),
      ],
    );
  }

  Widget _buildActionTile(
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

  Widget _buildLimitationsInfo(
    ThemeData theme,
    GuestManagementState state,
    GuestManagementNotifier notifier,
  ) {
    final canModify = notifier.canModifyReservation();
    final canCancel = notifier.canCancelReservation();
    
    if (canModify && canCancel) {
      return const SizedBox.shrink(); // Pas de limitations
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onErrorContainer,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Limitations',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          if (!canModify) ...[
            Text(
              '• Modification impossible : La réservation est dans moins de 24h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
          
          if (!canCancel) ...[
            Text(
              '• Annulation impossible : La réservation est dans moins de 24h',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
          
          if (state.status != 'CONFIRMED') ...[
            Text(
              '• Actions limitées : Réservation ${_getFormattedStatus(state.status)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showModifyDialog(
    BuildContext context,
    GuestManagementState state,
    GuestManagementNotifier notifier,
  ) {
    // Naviguer vers la page de modification complète
    context.go('/manage-reservation/modify?token=${state.token}');
  }

  void _showCancelDialog(
    BuildContext context,
    GuestManagementState state,
    GuestManagementNotifier notifier,
  ) {
    // Naviguer vers la page d'annulation complète
    context.go('/manage-reservation/cancel?token=${state.token}');
  }

  void _shareReservation(GuestManagementState state) {
    // TODO: Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de partage à implémenter'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _printReservation(GuestManagementState state) {
    // TODO: Implémenter l'impression
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction d\'impression à implémenter'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _contactRestaurant() {
    // TODO: Implémenter le contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de contact à implémenter'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getFormattedStatus(String? status) {
    switch (status) {
      case 'PENDING':
        return 'en attente';
      case 'CONFIRMED':
        return 'confirmée';
      case 'CANCELLED':
        return 'annulée';
      case 'COMPLETED':
        return 'terminée';
      case 'NO_SHOW':
        return 'absence';
      default:
        return 'inconnue';
    }
  }
}

/// Dialog pour modifier une réservation
class _ModifyReservationDialog extends ConsumerStatefulWidget {
  final GuestManagementState state;
  final GuestManagementNotifier notifier;

  const _ModifyReservationDialog({
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<_ModifyReservationDialog> createState() => _ModifyReservationDialogState();
}

class _ModifyReservationDialogState extends ConsumerState<_ModifyReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late String _selectedTime;
  late int _partySize;
  late String _specialRequests;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.state.reservationDate!;
    _selectedTime = widget.state.reservationTime!;
    _partySize = widget.state.partySize!;
    _specialRequests = widget.state.specialRequests ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la réservation'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            
            // Heure
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Heure'),
              subtitle: Text(_selectedTime),
              onTap: () {
                // TODO: Implémenter le sélecteur d'heure
              },
            ),
            
            // Nombre de personnes
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Nombre de personnes'),
              subtitle: Text('$_partySize'),
              onTap: () {
                // TODO: Implémenter le sélecteur de nombre de personnes
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.notifier.modifyReservation(
                newDate: _selectedDate,
                newTime: _selectedTime,
                newPartySize: _partySize,
                newSpecialRequests: _specialRequests,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}

/// Dialog pour annuler une réservation
class _CancelReservationDialog extends ConsumerStatefulWidget {
  final GuestManagementState state;
  final GuestManagementNotifier notifier;

  const _CancelReservationDialog({
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<_CancelReservationDialog> createState() => _CancelReservationDialogState();
}

class _CancelReservationDialogState extends ConsumerState<_CancelReservationDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Annuler la réservation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Êtes-vous sûr de vouloir annuler votre réservation ?',
            style: theme.textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Politique d\'annulation :',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.state.cancellationPolicy ?? 'Annulation gratuite jusqu\'à 24h avant',
            style: theme.textTheme.bodySmall,
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Raison de l\'annulation (optionnel)',
              hintText: 'Expliquez pourquoi vous annulez...',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Garder la réservation'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.notifier.cancelReservation(
              reason: _reasonController.text.trim().isEmpty 
                  ? null 
                  : _reasonController.text.trim(),
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Annuler la réservation'),
        ),
      ],
    );
  }
}
