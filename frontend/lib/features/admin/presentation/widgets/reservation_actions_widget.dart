import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour les actions disponibles sur une réservation
class ReservationActionsWidget extends ConsumerStatefulWidget {
  final ReservationCalendar reservation;
  final Function(ReservationAction) onActionSelected;
  final VoidCallback? onEditReservation;
  final VoidCallback? onDuplicateReservation;

  const ReservationActionsWidget({
    super.key,
    required this.reservation,
    required this.onActionSelected,
    this.onEditReservation,
    this.onDuplicateReservation,
  });

  @override
  ConsumerState<ReservationActionsWidget> createState() => _ReservationActionsWidgetState();
}

class _ReservationActionsWidgetState extends ConsumerState<ReservationActionsWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            const SizedBox(height: 16),

            // Actions principales
            _buildMainActions(theme, l10n),
            const SizedBox(height: 16),

            // Actions de statut
            _buildStatusActions(theme, l10n),
            const SizedBox(height: 16),

            // Actions de communication
            _buildCommunicationActions(theme, l10n),
            const SizedBox(height: 16),

            // Actions de gestion
            _buildManagementActions(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.settings,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.availableActions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mainActions,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: widget.onEditReservation,
                text: l10n.edit,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                icon: Icons.edit,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SimpleButton(
                onPressed: widget.onDuplicateReservation,
                text: l10n.duplicate,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
                icon: Icons.copy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusActions(ThemeData theme, AppLocalizations l10n) {
    final status = widget.reservation.status.toLowerCase();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statusActions,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getStatusActions(status, theme, l10n),
        ),
      ],
    );
  }

  List<Widget> _getStatusActions(String status, ThemeData theme, AppLocalizations l10n) {
    final actions = <Widget>[];

    switch (status) {
      case 'pending':
        actions.addAll([
          _buildActionButton(
            theme,
            l10n.confirm,
            Icons.check_circle,
            ButtonType.success,
            () => _selectAction(ReservationAction.confirm),
          ),
          _buildActionButton(
            theme,
            l10n.cancel,
            Icons.cancel,
            ButtonType.danger,
            () => _selectAction(ReservationAction.cancel),
          ),
        ]);
        break;
      case 'confirmed':
        actions.addAll([
          _buildActionButton(
            theme,
            l10n.markCompleted,
            Icons.done,
            ButtonType.primary,
            () => _selectAction(ReservationAction.markCompleted),
          ),
          _buildActionButton(
            theme,
            l10n.markNoShow,
            Icons.person_off,
            ButtonType.danger,
            () => _selectAction(ReservationAction.markNoShow),
          ),
        ]);
        break;
      case 'completed':
        actions.add(
          _buildActionButton(
            theme,
            l10n.reopen,
            Icons.refresh,
            ButtonType.secondary,
            () => _selectAction(ReservationAction.reopen),
          ),
        );
        break;
      case 'cancelled':
        actions.add(
          _buildActionButton(
            theme,
            l10n.restore,
            Icons.restore,
            ButtonType.primary,
            () => _selectAction(ReservationAction.restore),
          ),
        );
        break;
    }

    return actions;
  }

  Widget _buildCommunicationActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.communication,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionButton(
              theme,
              l10n.sendEmail,
              Icons.email,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.sendEmail),
            ),
            _buildActionButton(
              theme,
              l10n.sendSms,
              Icons.sms,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.sendSms),
            ),
            _buildActionButton(
              theme,
              l10n.sendReminder,
              Icons.notifications,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.sendReminder),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.management,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionButton(
              theme,
              l10n.assignTable,
              Icons.table_restaurant,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.assignTable),
            ),
            _buildActionButton(
              theme,
              l10n.changeTime,
              Icons.access_time,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.changeTime),
            ),
            _buildActionButton(
              theme,
              l10n.addNote,
              Icons.note_add,
              ButtonType.secondary,
              () => _selectAction(ReservationAction.addNote),
            ),
            _buildActionButton(
              theme,
              l10n.delete,
              Icons.delete,
              ButtonType.danger,
              () => _selectAction(ReservationAction.delete),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String text,
    IconData icon,
    ButtonType type,
    VoidCallback onPressed,
  ) {
    return SimpleButton(
      onPressed: onPressed,
      text: text,
      type: type,
      size: ButtonSize.small,
      icon: icon,
    );
  }

  void _selectAction(ReservationAction action) {
    widget.onActionSelected(action);
  }
}

/// Énumération des actions disponibles sur une réservation
enum ReservationAction {
  // Actions de statut
  confirm,
  cancel,
  markCompleted,
  markNoShow,
  reopen,
  restore,
  
  // Actions de communication
  sendEmail,
  sendSms,
  sendReminder,
  
  // Actions de gestion
  assignTable,
  changeTime,
  addNote,
  delete,
}

/// Extension pour obtenir les labels des actions
extension ReservationActionExtension on ReservationAction {
  String get label {
    switch (this) {
      case ReservationAction.confirm:
        return 'Confirmer';
      case ReservationAction.cancel:
        return 'Annuler';
      case ReservationAction.markCompleted:
        return 'Marquer comme terminée';
      case ReservationAction.markNoShow:
        return 'Marquer comme no-show';
      case ReservationAction.reopen:
        return 'Rouvrir';
      case ReservationAction.restore:
        return 'Restaurer';
      case ReservationAction.sendEmail:
        return 'Envoyer un email';
      case ReservationAction.sendSms:
        return 'Envoyer un SMS';
      case ReservationAction.sendReminder:
        return 'Envoyer un rappel';
      case ReservationAction.assignTable:
        return 'Assigner une table';
      case ReservationAction.changeTime:
        return 'Changer l\'heure';
      case ReservationAction.addNote:
        return 'Ajouter une note';
      case ReservationAction.delete:
        return 'Supprimer';
    }
  }
}
