import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/index.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';

/// Page de connexion pour l'interface administrative
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
    final authNotifier = ref.read(authProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Rediriger si déjà connecté
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin/dashboard');
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 400,
              ),
              child: CustomAnimatedWidget(
                config: AnimationConfig(
                  type: AnimationType.fadeIn,
                  duration: AnimationConstants.fast,
                  curve: AnimationConstants.easeOut,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 20 : 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo et titre
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: isMobile ? 32 : 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: isMobile ? 16 : 20),
                              Text(
                                'Interface Administrative',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 20 : 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isMobile ? 8 : 12),
                              Text(
                                'Connectez-vous pour accéder au dashboard',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: isMobile ? 12 : 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Champ email
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'admin@restaurant.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Veuillez saisir un email valide';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Champ mot de passe
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Mot de passe',
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outlined,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Bouton de connexion
                          SimpleButton(
                            text: 'Se connecter',
                            onPressed: authState.isLoading ? null : () => _handleLogin(authNotifier),
                            isLoading: authState.isLoading,
                            type: ButtonType.primary,
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Message d'erreur
                          if (authState.error != null)
                            Container(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                                border: Border.all(
                                  color: theme.colorScheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme.colorScheme.error,
                                    size: isMobile ? 16 : 20,
                                  ),
                                  SizedBox(width: isMobile ? 8 : 12),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontSize: isMobile ? 10 : 12,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: isMobile ? 16 : 20,
                                      color: theme.colorScheme.error,
                                    ),
                                    onPressed: () => authNotifier.clearError(),
                                  ),
                                ],
                              ),
                            ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Informations de test
                          Container(
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comptes de test disponibles:',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 10 : 12,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 4 : 8),
                                        Text(
                                          'Admin: admin@techplus-restaurant.com / admin123',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: isMobile ? 9 : 11,
                                          ),
                                        ),
                                        Text(
                                          'Client: client@example.com / client123',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: isMobile ? 9 : 11,
                                          ),
                                        ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthNotifier authNotifier) async {
    if (_formKey.currentState!.validate()) {
      await authNotifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        context.go('/admin/dashboard');
      }
    }
  }
}