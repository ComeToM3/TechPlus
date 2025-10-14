import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

/// Widget de protection pour les pages admin
/// Vérifie l'authentification et les droits admin
class AdminAuthGuard extends ConsumerWidget {
  final Widget child;
  final String? redirectTo;
  
  const AdminAuthGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authProvider);
    
    // Si en cours de chargement
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si pas authentifié, rediriger vers login
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectTo ?? '/admin/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si pas admin, rediriger vers login
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectTo ?? '/login');
      });
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Accès refusé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Vous n\'avez pas les droits d\'administrateur'),
            ],
          ),
        ),
      );
    }
    
    // Si tout est OK, afficher le contenu
    return child;
  }
}
