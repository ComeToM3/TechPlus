import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reservation_flow_provider.dart';

/// Formulaire pour les informations client
class ClientInfoForm extends ConsumerStatefulWidget {
  const ClientInfoForm({super.key});

  @override
  ConsumerState<ClientInfoForm> createState() => _ClientInfoFormState();
}

class _ClientInfoFormState extends ConsumerState<ClientInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _requestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final state = ref.read(reservationFlowProvider);
    _nameController.text = state.clientName;
    _emailController.text = state.clientEmail;
    _phoneController.text = state.clientPhone;
    _requestsController.text = state.specialRequests;
  }

  @override
  Widget build(BuildContext context) {
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
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Vos informations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulaire
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message d'information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ces informations nous permettront de vous contacter pour confirmer votre réservation.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Nom complet (requis)
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nom complet *',
                    hint: 'Votre nom et prénom',
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est requis';
                      }
                      if (value.trim().length < 2) {
                        return 'Le nom doit contenir au moins 2 caractères';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref.read(reservationFlowProvider.notifier).updateClientName(value);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email (requis)
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email *',
                    hint: 'votre.email@exemple.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'email est requis';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref.read(reservationFlowProvider.notifier).updateClientEmail(value);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Téléphone (optionnel)
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Téléphone (optionnel)',
                    hint: '514 123 4567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      _PhoneNumberFormatter(),
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final phoneRegex = RegExp(r'^(\+1\s?)?(\(?514\)?[\s\-]?)?[0-9]{3}[\s\-]?[0-9]{4}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Veuillez entrer un numéro valide (format québécois)';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      ref.read(reservationFlowProvider.notifier).updateClientPhone(value);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Demandes spéciales
                  _buildSpecialRequestsSection(theme),
                  
                  const SizedBox(height: 16),
                  
                  // Indicateur de validation
                  _buildValidationIndicator(theme, reservationState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildSpecialRequestsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demandes spéciales',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Allergies, préférences alimentaires, anniversaire, etc.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _requestsController,
          maxLines: 3,
          maxLength: 200,
          onChanged: (value) {
            ref.read(reservationFlowProvider.notifier).updateSpecialRequests(value);
          },
          decoration: InputDecoration(
            hintText: 'Décrivez vos demandes spéciales...',
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
            counterText: '', // Masquer le compteur par défaut
          ),
        ),
      ],
    );
  }

  Widget _buildValidationIndicator(ThemeData theme, ReservationFlowState state) {
    if (state.isClientInfoValid) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Informations valides',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Formatter pour le numéro de téléphone français
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }
    
    // Supprimer tous les espaces et caractères non numériques
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length > 10) {
      return oldValue;
    }
    
    String formatted = '';
    
    if (digitsOnly.startsWith('0')) {
      // Format: 06 12 34 56 78
      for (int i = 0; i < digitsOnly.length; i++) {
        if (i == 2 || i == 4 || i == 6 || i == 8) {
          formatted += ' ';
        }
        formatted += digitsOnly[i];
      }
    } else if (digitsOnly.startsWith('33')) {
      // Format: +33 6 12 34 56 78
      formatted = '+33 ';
      final remaining = digitsOnly.substring(2);
      for (int i = 0; i < remaining.length; i++) {
        if (i == 1 || i == 3 || i == 5 || i == 7) {
          formatted += ' ';
        }
        formatted += remaining[i];
      }
    } else {
      formatted = digitsOnly;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
