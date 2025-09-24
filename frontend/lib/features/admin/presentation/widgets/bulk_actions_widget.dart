import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour les actions en lot sur les réservations
class BulkActionsWidget extends ConsumerStatefulWidget {
  final List<String> selectedReservations;
  final Function(List<String>, BulkAction) onBulkAction;
  final VoidCallback? onClearSelection;

  const BulkActionsWidget({
    super.key,
    required this.selectedReservations,
    required this.onBulkAction,
    this.onClearSelection,
  });

  @override
  ConsumerState<BulkActionsWidget> createState() => _BulkActionsWidgetState();
}

class _BulkActionsWidgetState extends ConsumerState<BulkActionsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (widget.selectedReservations.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          children: [
            // En-tête des actions en lot
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.selectedItems(widget.selectedReservations.length.toString()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Actions disponibles
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Actions de statut
                    _buildStatusActions(theme, l10n),
                    const SizedBox(height: 16),
                    
                    // Actions de table
                    _buildTableActions(theme, l10n),
                    const SizedBox(height: 16),
                    
                    // Actions de notification
                    _buildNotificationActions(theme, l10n),
                    const SizedBox(height: 16),
                    
                    // Actions de suppression
                    _buildDeleteActions(theme, l10n),
                    const SizedBox(height: 16),
                    
                    // Actions de contrôle
                    _buildControlActions(theme, l10n),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.changeStatus,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.confirm),
                text: l10n.confirm,
                type: ButtonType.success,
                size: ButtonSize.small,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.cancel),
                text: l10n.cancel,
                type: ButtonType.danger,
                size: ButtonSize.small,
                icon: Icons.cancel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.markCompleted),
                text: l10n.markCompleted,
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: Icons.done,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignTable,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () => _showTableAssignmentDialog(),
                text: l10n.assignTable,
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: Icons.table_restaurant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.unassignTable),
                text: l10n.unassignTable,
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: Icons.table_bar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notifications,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.sendReminder),
                text: l10n.sendReminder,
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: Icons.notifications,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SimpleButton(
                onPressed: () => _performBulkAction(BulkAction.sendConfirmation),
                text: l10n.sendConfirmation,
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: Icons.email,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.delete,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () => _showDeleteConfirmationDialog(),
                text: l10n.deleteSelected,
                type: ButtonType.danger,
                size: ButtonSize.small,
                icon: Icons.delete,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: () => _selectAll(),
            text: l10n.selectAll,
            type: ButtonType.secondary,
            size: ButtonSize.small,
            icon: Icons.select_all,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SimpleButton(
            onPressed: widget.onClearSelection,
            text: l10n.clearSelection,
            type: ButtonType.secondary,
            size: ButtonSize.small,
            icon: Icons.clear,
          ),
        ),
      ],
    );
  }

  void _performBulkAction(BulkAction action) {
    widget.onBulkAction(widget.selectedReservations, action);
  }

  void _showTableAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.assignTable),
        content: const Text('Sélection de table à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteSelected),
        content: Text(AppLocalizations.of(context)!.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performBulkAction(BulkAction.delete);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _selectAll() {
    // TODO: Implémenter la sélection de toutes les réservations
  }
}

/// Énumération des actions en lot
enum BulkAction {
  confirm,
  cancel,
  markCompleted,
  assignTable,
  unassignTable,
  sendReminder,
  sendConfirmation,
  delete,
}
