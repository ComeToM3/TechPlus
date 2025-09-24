import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour afficher les informations client d'une réservation
class ClientInfoWidget extends ConsumerStatefulWidget {
  final ReservationCalendar reservation;
  final VoidCallback? onEditClient;
  final VoidCallback? onContactClient;

  const ClientInfoWidget({
    super.key,
    required this.reservation,
    this.onEditClient,
    this.onContactClient,
  });

  @override
  ConsumerState<ClientInfoWidget> createState() => _ClientInfoWidgetState();
}

class _ClientInfoWidgetState extends ConsumerState<ClientInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
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

            // Informations principales
            _buildMainInfo(theme, l10n),
            const SizedBox(height: 16),

            // Informations de contact
            _buildContactInfo(theme, l10n),
            const SizedBox(height: 16),

            // Informations de réservation
            _buildReservationInfo(theme, l10n),
            const SizedBox(height: 16),

            // Actions
            _buildActions(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.person,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.clientInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (widget.onEditClient != null)
          IconButton(
            onPressed: widget.onEditClient,
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            iconSize: 18,
          ),
      ],
    );
  }

  Widget _buildMainInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInformation,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          Icons.person_outline,
          l10n.name,
          widget.reservation.clientName ?? l10n.notSpecified,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          Icons.group,
          l10n.partySize,
          '${widget.reservation.partySize} ${l10n.people}',
        ),
        if (widget.reservation.specialRequests != null && 
            widget.reservation.specialRequests!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            Icons.star_outline,
            l10n.specialRequests,
            widget.reservation.specialRequests!,
            isMultiline: true,
          ),
        ],
      ],
    );
  }

  Widget _buildContactInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.contactInformation,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.reservation.clientEmail != null)
          _buildContactRow(
            theme,
            Icons.email_outlined,
            l10n.email,
            widget.reservation.clientEmail!,
            () => _copyToClipboard(widget.reservation.clientEmail!),
          ),
        if (widget.reservation.clientPhone != null) ...[
          const SizedBox(height: 8),
          _buildContactRow(
            theme,
            Icons.phone_outlined,
            l10n.phone,
            widget.reservation.clientPhone!,
            () => _copyToClipboard(widget.reservation.clientPhone!),
          ),
        ],
        if (widget.reservation.clientEmail == null && 
            widget.reservation.clientPhone == null)
          _buildInfoRow(
            theme,
            Icons.info_outline,
            l10n.noContactInfo,
            l10n.noContactInfoDescription,
          ),
      ],
    );
  }

  Widget _buildReservationInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reservationDetails,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          Icons.calendar_today,
          l10n.date,
          '${widget.reservation.date.day}/${widget.reservation.date.month}/${widget.reservation.date.year}',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          Icons.access_time,
          l10n.time,
          widget.reservation.time,
        ),
        if (widget.reservation.tableNumber != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            Icons.table_restaurant,
            l10n.table,
            '${l10n.table} ${widget.reservation.tableNumber}',
          ),
        ],
        const SizedBox(height: 8),
        _buildInfoRow(
          theme,
          Icons.info,
          l10n.status,
          _getStatusLabel(widget.reservation.status, l10n),
          statusColor: _getStatusColor(widget.reservation.status, theme),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        if (widget.reservation.clientEmail != null)
          Expanded(
            child: SimpleButton(
              onPressed: () => _sendEmail(widget.reservation.clientEmail!),
              text: l10n.sendEmail,
              type: ButtonType.secondary,
              size: ButtonSize.small,
              icon: Icons.email,
            ),
          ),
        if (widget.reservation.clientPhone != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SimpleButton(
              onPressed: () => _makeCall(widget.reservation.clientPhone!),
              text: l10n.call,
              type: ButtonType.secondary,
              size: ButtonSize.small,
              icon: Icons.phone,
            ),
          ),
        ],
        if (widget.onContactClient != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SimpleButton(
              onPressed: widget.onContactClient,
              text: l10n.contact,
              type: ButtonType.primary,
              size: ButtonSize.small,
              icon: Icons.message,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    bool isMultiline = false,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: statusColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor ?? theme.colorScheme.onSurface,
                  fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'confirmed':
        return l10n.confirmed;
      case 'cancelled':
        return l10n.cancelled;
      case 'completed':
        return l10n.completed;
      case 'no_show':
        return l10n.noShow;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'no_show':
        return Colors.grey;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  void _copyToClipboard(String text) {
    // TODO: Implémenter la copie dans le presse-papiers
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copié: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendEmail(String email) {
    // TODO: Implémenter l'envoi d'email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de l\'email pour: $email'),
      ),
    );
  }

  void _makeCall(String phone) {
    // TODO: Implémenter l'appel téléphonique
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appel vers: $phone'),
      ),
    );
  }
}
