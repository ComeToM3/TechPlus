import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

/// Page d'inscription
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    // Rediriger si déjà connecté
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        context.go('/');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Logo et titre
              _buildHeader(theme),
              
              const SizedBox(height: 32),
              
              // Formulaire d'inscription
              _buildRegisterForm(theme, authState),
              
              const SizedBox(height: 24),
              
              // Connexion OAuth2
              _buildOAuthSection(theme),
              
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
            Icons.restaurant,
            color: theme.colorScheme.onPrimary,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Titre
        Text(
          'Créer un compte',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Rejoignez-nous pour une expérience personnalisée',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme, AuthState authState) {
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
            // Nom complet
            CustomTextField(
              controller: _nameController,
              labelText: 'Nom complet',
              hintText: 'Votre nom et prénom',
              prefixIcon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir votre nom';
                }
                if (value.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            CustomTextField(
              controller: _emailController,
              labelText: 'Adresse email',
              hintText: 'votre.email@exemple.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir votre email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Veuillez saisir un email valide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Téléphone (optionnel)
            CustomTextField(
              controller: _phoneController,
              labelText: 'Numéro de téléphone (optionnel)',
              hintText: '+33 6 12 34 56 78',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!RegExp(r'^(\+33|0)[1-9](\d{8})$').hasMatch(value.trim().replaceAll(' ', ''))) {
                    return 'Veuillez saisir un numéro de téléphone valide';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Mot de passe
            CustomTextField(
              controller: _passwordController,
              labelText: 'Mot de passe',
              hintText: 'Votre mot de passe',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir un mot de passe';
                }
                if (value.length < 8) {
                  return 'Le mot de passe doit contenir au moins 8 caractères';
                }
                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                  return 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Confirmation du mot de passe
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirmer le mot de passe',
              hintText: 'Répétez votre mot de passe',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                }
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Accepter les conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'J\'accepte les '),
                          TextSpan(
                            text: 'conditions d\'utilisation',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' et la '),
                          TextSpan(
                            text: 'politique de confidentialité',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Message d'erreur
            if (authState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Bouton d'inscription
            AnimatedButton(
              onPressed: authState.isLoading ? null : _handleRegister,
              text: authState.isLoading ? 'Création du compte...' : 'Créer mon compte',
              icon: authState.isLoading ? Icons.hourglass_empty : Icons.person_add,
              type: ButtonType.primary,
              size: ButtonSize.large,
              isLoading: authState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthSection(ThemeData theme) {
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
      child: Column(
        children: [
          Text(
            'Ou créez un compte avec',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleRegister,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleFacebookRegister,
                  icon: const Icon(Icons.facebook, size: 24),
                  label: const Text('Facebook'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinks(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Déjà un compte ?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            'Se connecter',
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
            'Continuer sans compte',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter les conditions d\'utilisation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.read(authProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
    }
  }

  void _handleGoogleRegister() {
    // TODO: Implémenter l'inscription Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inscription Google à implémenter'),
      ),
    );
  }

  void _handleFacebookRegister() {
    // TODO: Implémenter l'inscription Facebook
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inscription Facebook à implémenter'),
      ),
    );
  }
}