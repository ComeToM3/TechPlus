import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour les informations de réservation
class ReservationInfoWidget extends ConsumerStatefulWidget {
  final ReservationFormData formData;
  final Function(ReservationFormData) onFormDataChanged;
  final VoidCallback? onValidate;

  const ReservationInfoWidget({
    super.key,
    required this.formData,
    required this.onFormDataChanged,
    this.onValidate,
  });

  @override
  ConsumerState<ReservationInfoWidget> createState() => _ReservationInfoWidgetState();
}

class _ReservationInfoWidgetState extends ConsumerState<ReservationInfoWidget> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _partySizeController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  final _adminNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _partySizeController.dispose();
    _specialRequestsController.dispose();
    _adminNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(theme, l10n),
              const SizedBox(height: 16),

              // Informations client
              _buildClientInfo(theme, l10n),
              const SizedBox(height: 16),

              // Informations de réservation
              _buildReservationInfo(theme, l10n),
              const SizedBox(height: 16),

              // Demandes spéciales
              _buildSpecialRequests(theme, l10n),
              const SizedBox(height: 16),

              // Notes admin
              _buildAdminNotes(theme, l10n),
              const SizedBox(height: 16),

              // Actions
              _buildActions(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.reservationInformation,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isFormValid() 
                ? Colors.green.withOpacity(0.2) 
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isFormValid() ? l10n.valid : l10n.incomplete,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _isFormValid() ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfo(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clientInformation,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _clientNameController,
                label: l10n.clientName,
                hintText: l10n.clientNameHint,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.clientNameRequired;
                  }
                  return null;
                },
                onChanged: _updateFormData,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _partySizeController,
                label: l10n.partySize,
                hintText: l10n.partySizeHint,
                prefixIcon: Icons.group,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.partySizeRequired;
                  }
                  final size = int.tryParse(value);
                  if (size == null || size < 1 || size > 20) {
                    return l10n.partySizeInvalid;
                  }
                  return null;
                },
                onChanged: _updateFormData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _clientEmailController,
                label: l10n.email,
                hintText: l10n.emailHint,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return l10n.emailInvalid;
                    }
                  }
                  return null;
                },
                onChanged: _updateFormData,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _clientPhoneController,
                label: l10n.phone,
                hintText: l10n.phoneHint,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: _updateFormData,
              ),
            ),
          ],
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(theme, l10n.date, _formatDate(widget.formData.date)),
              const SizedBox(height: 8),
              _buildInfoRow(theme, l10n.time, widget.formData.time ?? l10n.notSelected),
              const SizedBox(height: 8),
              _buildInfoRow(theme, l10n.partySize, '${widget.formData.partySize} ${l10n.people}'),
              if (widget.formData.tableNumber != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(theme, l10n.table, '${l10n.table} ${widget.formData.tableNumber}'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequests(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.specialRequests,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _specialRequestsController,
          label: l10n.specialRequests,
          hintText: l10n.specialRequestsHint,
          prefixIcon: Icons.star,
          maxLines: 3,
          onChanged: _updateFormData,
        ),
      ],
    );
  }

  Widget _buildAdminNotes(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminNotes,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _adminNotesController,
          label: l10n.adminNotes,
          hintText: l10n.adminNotesHint,
          prefixIcon: Icons.note,
          maxLines: 2,
          onChanged: _updateFormData,
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: _validateForm,
            text: l10n.validate,
            type: ButtonType.primary,
            size: ButtonSize.medium,
            icon: Icons.check,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SimpleButton(
            onPressed: _clearForm,
            text: l10n.clear,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
            icon: Icons.clear,
          ),
        ),
      ],
    );
  }

  void _initializeForm() {
    _clientNameController.text = widget.formData.clientName ?? '';
    _clientEmailController.text = widget.formData.clientEmail ?? '';
    _clientPhoneController.text = widget.formData.clientPhone ?? '';
    _partySizeController.text = widget.formData.partySize.toString();
    _specialRequestsController.text = widget.formData.specialRequests ?? '';
    _adminNotesController.text = widget.formData.adminNotes ?? '';
  }

  void _updateFormData(String value) {
    final updatedData = widget.formData.copyWith(
      clientName: _clientNameController.text,
      clientEmail: _clientEmailController.text,
      clientPhone: _clientPhoneController.text,
      partySize: int.tryParse(_partySizeController.text) ?? widget.formData.partySize,
      specialRequests: _specialRequestsController.text,
      adminNotes: _adminNotesController.text,
    );
    widget.onFormDataChanged(updatedData);
  }

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onValidate?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.formValidated),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.formValidationFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _clientNameController.clear();
    _clientEmailController.clear();
    _clientPhoneController.clear();
    _partySizeController.clear();
    _specialRequestsController.clear();
    _adminNotesController.clear();
    
    final clearedData = ReservationFormData(
      clientName: '',
      clientEmail: '',
      clientPhone: '',
      partySize: 1,
      specialRequests: '',
      adminNotes: '',
      date: widget.formData.date,
      time: widget.formData.time,
      tableNumber: widget.formData.tableNumber,
    );
    widget.onFormDataChanged(clearedData);
  }

  bool _isFormValid() {
    return _clientNameController.text.isNotEmpty &&
           _partySizeController.text.isNotEmpty &&
           int.tryParse(_partySizeController.text) != null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return AppLocalizations.of(context)!.notSelected;
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Modèle pour les données du formulaire de réservation
class ReservationFormData {
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final int partySize;
  final String? specialRequests;
  final String? adminNotes;
  final DateTime? date;
  final String? time;
  final int? tableNumber;

  const ReservationFormData({
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.partySize,
    this.specialRequests,
    this.adminNotes,
    this.date,
    this.time,
    this.tableNumber,
  });

  ReservationFormData copyWith({
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    int? partySize,
    String? specialRequests,
    String? adminNotes,
    DateTime? date,
    String? time,
    int? tableNumber,
  }) {
    return ReservationFormData(
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      partySize: partySize ?? this.partySize,
      specialRequests: specialRequests ?? this.specialRequests,
      adminNotes: adminNotes ?? this.adminNotes,
      date: date ?? this.date,
      time: time ?? this.time,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }
}

