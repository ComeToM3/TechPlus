import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Widget pour gérer la session utilisateur
class SessionManager extends ConsumerStatefulWidget {
  final Widget child;

  const SessionManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends ConsumerState<SessionManager> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    // Vérifier la session au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  void _checkSession() {
    final authState = ref.read(authProvider);
    
    if (authState.isAuthenticated && authState.accessToken != null) {
      // Vérifier la validité du token
      _validateToken();
    }
  }

  void _validateToken() {
    // TODO: Implémenter la validation du token
    // Pour l'instant, on simule une validation
    Future.delayed(const Duration(seconds: 1), () {
      // Si le token est expiré, essayer de le rafraîchir
      _refreshTokenIfNeeded();
    });
  }

  void _refreshTokenIfNeeded() {
    final authState = ref.read(authProvider);
    
    if (authState.refreshToken != null) {
      // TODO: Vérifier si le token d'accès est expiré
      // Pour l'instant, on simule un rafraîchissement périodique
      _scheduleTokenRefresh();
    }
  }

  void _scheduleTokenRefresh() {
    // Rafraîchir le token toutes les 50 minutes (tokens JWT expirent généralement après 1h)
    Future.delayed(const Duration(minutes: 50), () {
      if (mounted) {
        ref.read(authProvider.notifier).refreshAccessToken();
        _scheduleTokenRefresh(); // Programmer le prochain rafraîchissement
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Écouter les changements d'état d'authentification
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        _handleAuthStateChange(next);
      }
      
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _handleAuthError(next.errorMessage!);
      }
    });

    return widget.child;
  }

  void _handleAuthStateChange(AuthState authState) {
    if (!authState.isAuthenticated) {
      // L'utilisateur s'est déconnecté
      _handleLogout();
    } else {
      // L'utilisateur s'est connecté
      _handleLogin();
    }
  }

  void _handleLogin() {
    // TODO: Implémenter les actions post-connexion
    // - Charger les données utilisateur
    // - Synchroniser les préférences
    // - Mettre à jour les notifications
  }

  void _handleLogout() {
    // TODO: Implémenter les actions post-déconnexion
    // - Nettoyer les données locales
    // - Rediriger vers la page d'accueil
    // - Afficher un message de déconnexion
  }

  void _handleAuthError(String errorMessage) {
    // Afficher une notification d'erreur
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () {
              ref.read(authProvider.notifier).clearError();
            },
          ),
        ),
      );
    }
  }
}

/// Widget pour afficher l'état de la session
class SessionStatusWidget extends ConsumerWidget {
  const SessionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (!authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.onPrimaryContainer,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Connecté',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher les informations de session
class SessionInfoWidget extends ConsumerWidget {
  const SessionInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (!authState.isAuthenticated || authState.user == null) {
      return const SizedBox.shrink();
    }

    final user = authState.user!;
    final sessionDuration = DateTime.now().difference(user.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de session',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(theme, 'Utilisateur', user.name ?? user.email),
          _buildInfoRow(theme, 'Email', user.email),
          _buildInfoRow(theme, 'Rôle', _formatUserRole(user.role)),
          _buildInfoRow(theme, 'Membre depuis', _formatDuration(sessionDuration)),
          _buildInfoRow(theme, 'Dernière connexion', 'Maintenant'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserRole(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.ADMIN:
        return 'Administrateur';
      case UserRole.SUPER_ADMIN:
        return 'Super Administrateur';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

/// Widget pour gérer la déconnexion
class LogoutButton extends ConsumerWidget {
  final VoidCallback? onLogout;

  const LogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return IconButton(
      onPressed: authState.isLoading ? null : () => _showLogoutDialog(context, ref),
      icon: Icon(
        Icons.logout,
        color: theme.colorScheme.onSurface,
      ),
      tooltip: 'Se déconnecter',
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              onLogout?.call();
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
