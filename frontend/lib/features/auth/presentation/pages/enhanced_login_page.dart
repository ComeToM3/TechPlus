import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/index.dart';
import '../../../../shared/errors/contextual_errors.dart';
import '../../../../shared/errors/enhanced_error_handler.dart';
import '../../../../shared/widgets/error/enhanced_error_display.dart';

/// Page de connexion améliorée avec gestion d'erreurs contextuelles
class EnhancedLoginPage extends ConsumerStatefulWidget {
  const EnhancedLoginPage({super.key});

  @override
  ConsumerState<EnhancedLoginPage> createState() => _EnhancedLoginPageState();
}

class _EnhancedLoginPageState extends ConsumerState<EnhancedLoginPage> {
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
    final currentError = ref.watch(currentErrorProvider);

    // Rediriger si déjà connecté
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo et titre
                Icon(
                  Icons.restaurant,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Connexion',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
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

                // Champ email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'votre@email.com',
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

                // Bouton de connexion
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
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
                const SizedBox(height: 16),

                // Boutons de test pour les erreurs contextuelles
                if (Theme.of(context).brightness == Brightness.light) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Tests d\'erreurs contextuelles',
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTestButton(
                        'Erreur Auth',
                        () => _testAuthError(),
                        Colors.orange,
                      ),
                      _buildTestButton(
                        'Erreur Réseau',
                        () => _testNetworkError(),
                        Colors.blue,
                      ),
                      _buildTestButton(
                        'Erreur Validation',
                        () => _testValidationError(),
                        Colors.amber,
                      ),
                      _buildTestButton(
                        'Erreur Réservation',
                        () => _testReservationError(),
                        Colors.red,
                      ),
                      _buildTestButton(
                        'Erreur Paiement',
                        () => _testPaymentError(),
                        Colors.purple,
                      ),
                      _buildTestButton(
                        'Erreur Serveur',
                        () => _testServerError(),
                        Colors.red.shade800,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Lien vers l'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ? '),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('S\'inscrire'),
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

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Appeler l'API backend pour la connexion
      final response = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Succès
      EnhancedErrorHandler.showContextualSuccess(context, 'login_success');
      
    } catch (e) {
      // Créer une erreur contextuelle
      final errorFactory = ref.read(contextualErrorFactoryProvider);
      final error = errorFactory.fromException(e);
      
      // Ajouter l'erreur au provider
      ref.read(errorStateProvider.notifier).addError(error);
      
      // Afficher l'erreur
      EnhancedErrorHandler.showContextualError(context, error);
    }
  }

  void _handleRetry() {
    ref.read(errorStateProvider.notifier).clearCurrentError();
    _handleLogin();
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mot de passe oublié'),
        content: const Text('Entrez votre email pour recevoir les instructions de réinitialisation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              EnhancedErrorHandler.showContextualSuccess(context, 'email_sent');
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  // Méthodes de test pour les erreurs contextuelles
  void _testAuthError() {
    final error = ContextualAuthError.invalidCredentials();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testNetworkError() {
    final error = ContextualNetworkError.connectionTimeout();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testValidationError() {
    final error = ContextualValidationError.invalidEmail();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testReservationError() {
    final error = ContextualReservationError.timeSlotUnavailable(maxPartySize: 8);
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testPaymentError() {
    final error = ContextualPaymentError.cardDeclined();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }

  void _testServerError() {
    final error = ContextualServerError.maintenanceMode();
    ref.read(errorStateProvider.notifier).addError(error);
    EnhancedErrorHandler.showContextualErrorDialog(context, error);
  }
}
