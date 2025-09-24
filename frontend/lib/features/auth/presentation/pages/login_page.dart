import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';

/// Page de connexion
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    // Rediriger si déjà connecté
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        // Redirection basée sur le rôle de l'utilisateur
        final user = next.user;
        if (user?.role == 'ADMIN' || user?.role == 'SUPER_ADMIN') {
          context.go('/admin/dashboard');
        } else {
          context.go('/');
        }
      }
    });

    return Scaffold(
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
              
              // Identifiants de test
              _buildTestCredentials(theme),
              
              const SizedBox(height: 24),
              
              // Formulaire de connexion
              _buildLoginForm(theme, authState),
              
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
          'Connexion',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Connectez-vous à votre compte',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTestCredentials(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Identifiants de test',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Email de test
          _buildCredentialRow(
            theme,
            'Email:',
            'admin@techplus-restaurant.com',
            () => _copyToClipboard('admin@techplus-restaurant.com'),
          ),
          
          const SizedBox(height: 8),
          
          // Mot de passe de test
          _buildCredentialRow(
            theme,
            'Password:',
            'admin123',
            () => _copyToClipboard('admin123'),
          ),
          
          const SizedBox(height: 12),
          
          // Bouton pour remplir automatiquement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fillTestCredentials,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Remplir automatiquement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(
    ThemeData theme,
    String label,
    String value,
    VoidCallback onCopy,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(
                    Icons.copy,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Copier',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    // Copier dans le presse-papiers
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copié: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _fillTestCredentials() {
    setState(() {
      _emailController.text = 'admin@techplus-restaurant.com';
      _passwordController.text = 'admin123';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identifiants de test remplis automatiquement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthState authState) {
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
                  return 'Veuillez saisir votre mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Se souvenir de moi
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Se souvenir de moi',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Naviguer vers la page de réinitialisation du mot de passe
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité de réinitialisation à venir'),
                      ),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
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
            
            // Bouton de connexion
            AnimatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              text: authState.isLoading ? 'Connexion...' : 'Se connecter',
              icon: authState.isLoading ? Icons.hourglass_empty : Icons.login,
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
            'Ou connectez-vous avec',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleLogin,
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
                  onPressed: _handleFacebookLogin,
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
          'Pas encore de compte ?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: 8),
        
        TextButton(
          onPressed: () => context.go('/register'),
          child: Text(
            'Créer un compte',
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

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleLogin() {
    // TODO: Implémenter la connexion Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Google à implémenter'),
      ),
    );
  }

  void _handleFacebookLogin() {
    // TODO: Implémenter la connexion Facebook
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Facebook à implémenter'),
      ),
    );
  }
}