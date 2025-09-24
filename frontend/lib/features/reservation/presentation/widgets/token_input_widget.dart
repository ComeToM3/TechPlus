import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guest_management_provider.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Widget pour la saisie du token de gestion
class TokenInputWidget extends ConsumerStatefulWidget {
  const TokenInputWidget({super.key});

  @override
  ConsumerState<TokenInputWidget> createState() => _TokenInputWidgetState();
}

class _TokenInputWidgetState extends ConsumerState<TokenInputWidget> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestState = ref.watch(guestManagementProvider);

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
                  Icons.key,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Accès à votre réservation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
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
                  // Instructions
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
                            'Saisissez le token de gestion reçu par email pour accéder à votre réservation.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Champ de saisie du token
                  TextFormField(
                    controller: _tokenController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: 'Token de gestion',
                      hintText: 'Saisissez votre token de 32 caractères',
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
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
                      errorText: guestState.error != null && guestState.error!.contains('token')
                          ? guestState.error
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez saisir votre token de gestion';
                      }
                      if (value.trim().length < 10) {
                        return 'Le token doit contenir au moins 10 caractères';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Effacer l'erreur quand l'utilisateur tape
                      if (guestState.error != null) {
                        ref.read(guestManagementProvider.notifier).reset();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bouton de validation
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedButton(
                      onPressed: guestState.isLoading
                          ? null
                          : () => _validateToken(),
                      text: 'Accéder à ma réservation',
                      icon: Icons.search,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      isLoading: guestState.isLoading,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Aide et informations
                  _buildHelpSection(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Besoin d\'aide ?',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '• Le token de gestion vous a été envoyé par email lors de la confirmation de votre réservation\n'
            '• Il vous permet de modifier ou annuler votre réservation\n'
            '• Si vous ne trouvez pas l\'email, vérifiez vos spams\n'
            '• En cas de problème, contactez-nous au +33 1 23 45 67 89',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _validateToken() {
    if (_formKey.currentState?.validate() ?? false) {
      final token = _tokenController.text.trim();
      ref.read(guestManagementProvider.notifier).validateTokenAndLoadReservation(token);
    }
  }
}
