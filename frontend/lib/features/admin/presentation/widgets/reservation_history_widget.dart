import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_history.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour afficher l'historique des modifications d'une réservation
class ReservationHistoryWidget extends ConsumerStatefulWidget {
  final List<ReservationHistory> history;
  final VoidCallback? onRefresh;

  const ReservationHistoryWidget({
    super.key,
    required this.history,
    this.onRefresh,
  });

  @override
  ConsumerState<ReservationHistoryWidget> createState() => _ReservationHistoryWidgetState();
}

class _ReservationHistoryWidgetState extends ConsumerState<ReservationHistoryWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromRight,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            
            // Historique
            if (_isExpanded) ...[
              const Divider(height: 1),
              _buildHistoryList(theme, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return InkWell(
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
              Icons.history,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.modificationHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.history.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (widget.onRefresh != null)
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                iconSize: 18,
              ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, AppLocalizations l10n) {
    if (widget.history.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.history.asMap().entries.map((entry) {
          final index = entry.key;
          final historyItem = entry.value;
          final isLast = index == widget.history.length - 1;

          return _buildHistoryItem(theme, l10n, historyItem, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noHistory,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noHistoryDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    ThemeData theme,
    AppLocalizations l10n,
    ReservationHistory historyItem,
    bool isLast,
  ) {
    final action = HistoryAction.fromString(historyItem.action);
    final actionColor = _getActionColor(action, theme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action and timestamp
              Row(
                children: [
                  Icon(
                    _getActionIcon(action),
                    size: 16,
                    color: actionColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: actionColor,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimestamp(historyItem.timestamp, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Description
              if (historyItem.description.isNotEmpty)
                Text(
                  historyItem.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),

              // Changes
              if (historyItem.oldValue != null || historyItem.newValue != null)
                _buildChanges(theme, l10n, historyItem),

              // Author
              if (historyItem.changedBy != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${l10n.by} ${historyItem.changedBy}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChanges(
    ThemeData theme,
    AppLocalizations l10n,
    ReservationHistory historyItem,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (historyItem.oldValue != null) ...[
            Row(
              children: [
                Icon(
                  Icons.remove,
                  size: 14,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    historyItem.oldValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),
            if (historyItem.newValue != null) const SizedBox(height: 4),
          ],
          if (historyItem.newValue != null) ...[
            Row(
              children: [
                Icon(
                  Icons.add,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    historyItem.newValue!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getActionIcon(HistoryAction action) {
    switch (action) {
      case HistoryAction.created:
        return Icons.add_circle;
      case HistoryAction.updated:
        return Icons.edit;
      case HistoryAction.confirmed:
        return Icons.check_circle;
      case HistoryAction.cancelled:
        return Icons.cancel;
      case HistoryAction.completed:
        return Icons.done;
      case HistoryAction.noShow:
        return Icons.person_off;
      case HistoryAction.tableAssigned:
        return Icons.table_restaurant;
      case HistoryAction.tableUnassigned:
        return Icons.table_bar;
      case HistoryAction.paymentReceived:
        return Icons.payment;
      case HistoryAction.paymentRefunded:
        return Icons.refresh;
      case HistoryAction.noteAdded:
        return Icons.note_add;
      case HistoryAction.emailSent:
        return Icons.email;
      case HistoryAction.reminderSent:
        return Icons.notifications;
    }
  }

  Color _getActionColor(HistoryAction action, ThemeData theme) {
    switch (action) {
      case HistoryAction.created:
        return Colors.green;
      case HistoryAction.updated:
        return Colors.blue;
      case HistoryAction.confirmed:
        return Colors.green;
      case HistoryAction.cancelled:
        return Colors.red;
      case HistoryAction.completed:
        return Colors.blue;
      case HistoryAction.noShow:
        return Colors.grey;
      case HistoryAction.tableAssigned:
        return Colors.orange;
      case HistoryAction.tableUnassigned:
        return Colors.orange;
      case HistoryAction.paymentReceived:
        return Colors.green;
      case HistoryAction.paymentRefunded:
        return Colors.orange;
      case HistoryAction.noteAdded:
        return Colors.purple;
      case HistoryAction.emailSent:
        return Colors.blue;
      case HistoryAction.reminderSent:
        return Colors.amber;
    }
  }

  String _formatTimestamp(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return l10n.now;
    }
  }
}
