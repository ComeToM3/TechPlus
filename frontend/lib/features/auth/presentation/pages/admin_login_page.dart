import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/index.dart';
import '../../../../shared/errors/enhanced_error_handler.dart';
import '../../../../shared/widgets/error/enhanced_error_display.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/errors/contextual_errors.dart';
import '../providers/oauth_provider.dart';
import '../widgets/oauth_test_widget.dart';

/// Page de connexion admin avec OAuth
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
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
    final oauthState = ref.watch(oauthProvider);
    final currentError = ref.watch(currentErrorProvider);

    // Rediriger si déjà connecté
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        final user = next.user;
        if (user?.role == UserRole.ADMIN || user?.role == UserRole.SUPER_ADMIN) {
          context.go('/admin/dashboard');
        }
      }
    });

    // Rediriger si OAuth connecté
    ref.listen<OAuthState>(oauthProvider, (previous, next) {
      if (next.isSignedIn && previous?.isSignedIn != true) {
        final user = next.user;
        if (user?.role == UserRole.ADMIN || user?.role == UserRole.SUPER_ADMIN) {
          context.go('/admin/dashboard');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo et titre
                Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Connexion Admin',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Accès administrateur avec OAuth',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Affichage des erreurs contextuelles
                if (currentError != null) ...[
                  EnhancedErrorDisplay(
                    error: currentError,
                    onRetry: () => _handleRetry(),
                    retryText: 'Réessayer la connexion',
                    showSuggestedActions: true,
                  ),
                  const SizedBox(height: 24),
                ],

                // Test de configuration OAuth
                const OAuthTestWidget(),

                const SizedBox(height: 24),

                // Section OAuth
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connexion OAuth (Recommandé)',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Utilisez votre compte Google, Facebook ou Apple pour vous connecter en tant qu\'administrateur.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Boutons OAuth
                        if (oauthState.isLoading) ...[
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ] else ...[
                          // Google
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleGoogleSignIn(),
                              icon: const Icon(Icons.login, color: Colors.white),
                              label: const Text('Se connecter avec Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Facebook
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleFacebookSignIn(),
                              icon: const Icon(Icons.facebook, color: Colors.white),
                              label: const Text('Se connecter avec Facebook'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Apple
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAppleSignIn(),
                              icon: const Icon(Icons.apple, color: Colors.white),
                              label: const Text('Se connecter avec Apple'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Section connexion classique
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connexion classique',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Utilisez vos identifiants administrateur pour vous connecter.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Champ email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email administrateur',
                            hintText: 'admin@restaurant.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'L\'email est obligatoire';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Format d\'email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Champ mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: 'Votre mot de passe',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe est obligatoire';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Options
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
                            const Text('Se souvenir de moi'),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _showForgotPasswordDialog(),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bouton de connexion classique
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleClassicLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Se connecter'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lien vers la page publique
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas administrateur ? '),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Retour au site public'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      await ref.read(oauthProvider.notifier).signInWithGoogle();
    } catch (e) {
      EnhancedErrorHandler.showContextualError(
        context,
        ContextualAuthError(
          errorKey: 'oauth_google_failed',
          message: 'Erreur de connexion Google: ${e.toString()}',
        ),
      );
    }
  }

  void _handleFacebookSignIn() async {
    try {
      await ref.read(oauthProvider.notifier).signInWithFacebook();
    } catch (e) {
      EnhancedErrorHandler.showContextualError(
        context,
        ContextualAuthError(
          errorKey: 'oauth_facebook_failed',
          message: 'Erreur de connexion Facebook: ${e.toString()}',
        ),
      );
    }
  }

  void _handleAppleSignIn() async {
    try {
      await ref.read(oauthProvider.notifier).signInWithApple();
    } catch (e) {
      EnhancedErrorHandler.showContextualError(
        context,
        ContextualAuthError(
          errorKey: 'oauth_apple_failed',
          message: 'Erreur de connexion Apple: ${e.toString()}',
        ),
      );
    }
  }

  void _handleClassicLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      EnhancedErrorHandler.showContextualError(
        context,
        ContextualAuthError(
          errorKey: 'invalid_credentials',
          message: 'Erreur de connexion: ${e.toString()}',
        ),
      );
    }
  }

  void _handleRetry() {
    ref.read(errorStateProvider.notifier).clearCurrentError();
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mot de passe oublié'),
        content: const Text('Contactez le support technique pour réinitialiser votre mot de passe administrateur.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
