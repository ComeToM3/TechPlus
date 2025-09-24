import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Menu de navigation latéral
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // En-tête du drawer
          _buildDrawerHeader(theme, isAuthenticated, user),
          
          // Menu principal
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Section publique
                _buildSectionHeader(theme, 'Navigation'),
                _buildDrawerItem(
                  context,
                  theme,
                  Icons.home,
                  'Accueil',
                  '/',
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  Icons.restaurant_menu,
                  'Menu',
                  '/menu',
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  Icons.info,
                  'À propos',
                  '/about',
                ),
                _buildDrawerItem(
                  context,
                  theme,
                  Icons.contact_phone,
                  'Contact',
                  '/contact',
                ),
                
                const Divider(),
                
                // Section réservation
                _buildSectionHeader(theme, 'Réservation'),
                _buildDrawerItem(
                  context,
                  theme,
                  Icons.table_restaurant,
                  'Réserver une table',
                  '/reserve',
                ),
                if (isAuthenticated) ...[
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.history,
                    'Mes réservations',
                    '/my-reservations',
                  ),
                ],
                
                const Divider(),
                
                // Section authentification
                if (!isAuthenticated) ...[
                  _buildSectionHeader(theme, 'Compte'),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.login,
                    'Se connecter',
                    '/login',
                  ),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.person_add,
                    'Créer un compte',
                    '/register',
                  ),
                ] else ...[
                  _buildSectionHeader(theme, 'Mon compte'),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.person,
                    'Mon profil',
                    '/profile',
                  ),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.settings,
                    'Paramètres',
                    '/settings',
                  ),
                ],
                
                const Divider(),
                
                // Section administration
                if (isAuthenticated && (user?.role == UserRole.ADMIN || user?.role == UserRole.SUPER_ADMIN)) ...[
                  _buildSectionHeader(theme, 'Administration'),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.dashboard,
                    'Tableau de bord',
                    '/admin/dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.calendar_today,
                    'Gestion des réservations',
                    '/admin/reservations',
                  ),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.table_chart,
                    'Gestion des tables',
                    '/admin/tables',
                  ),
                  _buildDrawerItem(
                    context,
                    theme,
                    Icons.restaurant_menu,
                    'Gestion du menu',
                    '/admin/menu',
                  ),
                ],
              ],
            ),
          ),
          
          // Pied de page
          _buildDrawerFooter(theme, isAuthenticated),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, bool isAuthenticated, User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TechPlus',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      Text(
                        'Restaurant',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Informations utilisateur
            if (isAuthenticated && user != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                      child: Text(
                        user.name?.isNotEmpty == true 
                            ? user.name![0].toUpperCase()
                            : user.email[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Utilisateur',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Bienvenue chez TechPlus',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDrawerFooter(ThemeData theme, bool isAuthenticated) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          if (isAuthenticated) ...[
            Builder(
              builder: (context) => ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () {
                  // TODO: Implémenter la déconnexion
                  context.pop();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterButton(
                theme,
                Icons.help_outline,
                'Aide',
                () {
                  // TODO: Naviguer vers la page d'aide
                },
              ),
              _buildFooterButton(
                theme,
                Icons.info_outline,
                'À propos',
                () {
                  // TODO: Naviguer vers la page à propos
                },
              ),
              _buildFooterButton(
                theme,
                Icons.settings,
                'Paramètres',
                () {
                  // TODO: Naviguer vers les paramètres
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      tooltip: tooltip,
    );
  }
}

/// Barre de navigation inférieure
class BottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                theme,
                Icons.home,
                'Accueil',
                0,
                currentIndex == 0,
              ),
              _buildNavItem(
                theme,
                Icons.restaurant_menu,
                'Menu',
                1,
                currentIndex == 1,
              ),
              _buildNavItem(
                theme,
                Icons.table_restaurant,
                'Réserver',
                2,
                currentIndex == 2,
              ),
              if (isAuthenticated) ...[
                _buildNavItem(
                  theme,
                  Icons.history,
                  'Mes réservations',
                  3,
                  currentIndex == 3,
                ),
                _buildNavItem(
                  theme,
                  Icons.person,
                  'Profil',
                  4,
                  currentIndex == 4,
                ),
              ] else ...[
                _buildNavItem(
                  theme,
                  Icons.login,
                  'Connexion',
                  3,
                  currentIndex == 3,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    ThemeData theme,
    IconData icon,
    String label,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
