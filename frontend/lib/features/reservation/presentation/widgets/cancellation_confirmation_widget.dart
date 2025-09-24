import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour confirmer l'annulation d'une réservation
class CancellationConfirmationWidget extends ConsumerStatefulWidget {
  final DateTime reservationDate;
  final String reservationTime;
  final int partySize;
  final String clientName;
  final bool hasPayment;
  final double depositAmount;
  final bool isRefundable;
  final double refundAmount;
  final Function(String reason) onConfirmCancellation;
  final VoidCallback onCancel;
  final bool isLoading;

  const CancellationConfirmationWidget({
    super.key,
    required this.reservationDate,
    required this.reservationTime,
    required this.partySize,
    required this.clientName,
    required this.hasPayment,
    required this.depositAmount,
    required this.isRefundable,
    required this.refundAmount,
    required this.onConfirmCancellation,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  ConsumerState<CancellationConfirmationWidget> createState() => _CancellationConfirmationWidgetState();
}

class _CancellationConfirmationWidgetState extends ConsumerState<CancellationConfirmationWidget> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Motifs prédéfinis
  final List<String> _predefinedReasons = [
    'Changement de plans',
    'Problème de transport',
    'Maladie ou urgence',
    'Conflit d\'horaire',
    'Autre raison',
  ];
  
  String? _selectedReason;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              color: theme.colorScheme.errorContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Confirmer l\'annulation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé de la réservation
                  _buildReservationSummary(theme),
                  
                  const SizedBox(height: 16),
                  
                  // Impact financier
                  _buildFinancialImpact(theme),
                  
                  const SizedBox(height: 16),
                  
                  // Motif d'annulation
                  _buildCancellationReason(theme),
                  
                  const SizedBox(height: 16),
                  
                  // Avertissement
                  _buildWarning(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  _buildActions(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réservation à annuler',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildSummaryRow(theme, 'Nom', widget.clientName),
          _buildSummaryRow(theme, 'Date', DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(widget.reservationDate)),
          _buildSummaryRow(theme, 'Heure', widget.reservationTime),
          _buildSummaryRow(theme, 'Personnes', '${widget.partySize} ${widget.partySize == 1 ? 'personne' : 'personnes'}'),
        ],
      ),
    );
  }

  Widget _buildFinancialImpact(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isRefundable 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isRefundable 
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isRefundable ? Icons.monetization_on : Icons.cancel,
                color: widget.isRefundable 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Impact financier',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isRefundable 
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          if (widget.hasPayment) ...[
            _buildFinancialRow(theme, 'Acompte payé', '${widget.depositAmount.toStringAsFixed(2)}€'),
            
            if (widget.isRefundable) ...[
              _buildFinancialRow(theme, 'Remboursement', '${widget.refundAmount.toStringAsFixed(2)}€', isPositive: true),
              _buildFinancialRow(theme, 'Frais d\'annulation', '0,00€', isPositive: true),
            ] else ...[
              _buildFinancialRow(theme, 'Remboursement', '0,00€', isPositive: false),
              _buildFinancialRow(theme, 'Perte', '${widget.depositAmount.toStringAsFixed(2)}€', isPositive: false),
            ],
          ] else ...[
            _buildFinancialRow(theme, 'Acompte payé', 'Aucun'),
            _buildFinancialRow(theme, 'Frais d\'annulation', '0,00€', isPositive: true),
          ],
        ],
      ),
    );
  }

  Widget _buildCancellationReason(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motif d\'annulation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Motifs prédéfinis
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return FilterChip(
              label: Text(reason),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedReason = selected ? reason : null;
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Champ de texte libre
        TextFormField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: 'Détails (optionnel)',
            hintText: 'Précisez votre motif d\'annulation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
          maxLines: 3,
          maxLength: 500,
          validator: (value) {
            if (_selectedReason == null && (value == null || value.trim().isEmpty)) {
              return 'Veuillez sélectionner un motif ou saisir des détails';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWarning(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: theme.colorScheme.error,
            size: 20,
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attention',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  widget.isRefundable 
                      ? 'Cette action annulera définitivement votre réservation. Le remboursement sera traité automatiquement.'
                      : 'Cette action annulera définitivement votre réservation. L\'acompte ne sera pas remboursé.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            onPressed: widget.isLoading ? null : widget.onCancel,
            text: 'Annuler',
            icon: Icons.arrow_back,
            type: ButtonType.secondary,
            size: ButtonSize.large,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: AnimatedButton(
            onPressed: widget.isLoading ? null : _confirmCancellation,
            text: 'Confirmer l\'annulation',
            icon: Icons.cancel,
            type: ButtonType.danger,
            size: ButtonSize.large,
            isLoading: widget.isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(ThemeData theme, String label, String value, {bool? isPositive}) {
    Color? valueColor;
    if (isPositive != null) {
      valueColor = isPositive ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancellation() {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _selectedReason ?? _reasonController.text.trim();
      widget.onConfirmCancellation(reason);
    }
  }
}
