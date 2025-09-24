import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

/// Page de connexion par token pour les clients
class TokenLoginPage extends ConsumerStatefulWidget {
  const TokenLoginPage({super.key});

  @override
  ConsumerState<TokenLoginPage> createState() => _TokenLoginPageState();
}

class _TokenLoginPageState extends ConsumerState<TokenLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion par Token'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo et titre
              _buildHeader(theme),
              
              const SizedBox(height: 40),
              
              // Formulaire de connexion par token
              _buildTokenForm(theme),
              
              const SizedBox(height: 24),
              
              // Liens
              _buildLinks(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.vpn_key,
            color: theme.colorScheme.onPrimary,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          'Connexion par Token',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Entrez votre token de réservation pour accéder à vos informations',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTokenForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Token
            CustomTextField(
              controller: _tokenController,
              labelText: 'Token de réservation',
              hintText: 'guest_xxxxxxxxx',
              prefixIcon: Icons.vpn_key,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir votre token';
                }
                if (!value.trim().startsWith('guest_')) {
                  return 'Le token doit commencer par "guest_"';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Bouton de connexion
            AnimatedButton(
              onPressed: _handleTokenLogin,
              text: 'Accéder à ma réservation',
              icon: Icons.login,
              type: ButtonType.primary,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinks(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Pas de token ?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextButton(
          onPressed: () => context.go('/reservations/create'),
          child: Text(
            'Créer une nouvelle réservation',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () => context.go('/'),
          child: Text(
            'Retour à l\'accueil',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _handleTokenLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final token = _tokenController.text.trim();
      
      // Rediriger vers la page de gestion avec le token
      context.go('/manage-reservation?token=$token');
    }
  }
}
