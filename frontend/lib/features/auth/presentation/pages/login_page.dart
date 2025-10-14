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
  void initState() {
    super.initState();
    // Pré-remplir avec les identifiants admin
    _emailController.text = 'admin@techplus-restaurant.com';
    _passwordController.text = 'admin123';
  }

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
                          
                          // Champ email avec bouton de copie
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
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
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  _emailController.text = 'admin@techplus-restaurant.com';
                                },
                                icon: const Icon(Icons.content_copy),
                                tooltip: 'Copier email admin',
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Champ mot de passe avec bouton de copie
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
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
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  _passwordController.text = 'admin123';
                                },
                                icon: const Icon(Icons.content_copy),
                                tooltip: 'Copier mot de passe admin',
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Bouton de connexion rapide admin
                          SimpleButton(
                            text: '🚀 Connexion Admin Rapide',
                            onPressed: authState.isLoading ? null : () => _handleQuickAdminLogin(authNotifier),
                            isLoading: authState.isLoading,
                            type: ButtonType.primary,
                          ),
                          
                          SizedBox(height: isMobile ? 12 : 16),
                          
                          // Bouton de connexion normal
                          SimpleButton(
                            text: 'Se connecter',
                            onPressed: authState.isLoading ? null : () => _handleLogin(authNotifier),
                            isLoading: authState.isLoading,
                            type: ButtonType.secondary,
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
                          
                          // Informations de test améliorées
                          Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.1),
                                  theme.colorScheme.primary.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      color: theme.colorScheme.primary,
                                      size: isMobile ? 20 : 24,
                                    ),
                                    SizedBox(width: isMobile ? 8 : 12),
                                    Text(
                                      '🔑 Identifiants Admin Pré-remplis',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 12 : 16),
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email: admin@techplus-restaurant.com',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'monospace',
                                          fontSize: isMobile ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? 4 : 8),
                                      Text(
                                        'Mot de passe: admin123',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'monospace',
                                          fontSize: isMobile ? 12 : 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isMobile ? 12 : 16),
                                Text(
                                  '💡 Utilisez le bouton "Connexion Admin Rapide" ci-dessus pour vous connecter automatiquement !',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: isMobile ? 10 : 12,
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
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

  Future<void> _handleQuickAdminLogin(AuthNotifier authNotifier) async {
    // Remplir automatiquement les champs avec les identifiants admin
    _emailController.text = 'admin@techplus-restaurant.com';
    _passwordController.text = 'admin123';
    
    // Se connecter directement
    await authNotifier.login(
      email: 'admin@techplus-restaurant.com',
      password: 'admin123',
    );
    
    if (mounted) {
      context.go('/admin/dashboard');
    }
  }
}