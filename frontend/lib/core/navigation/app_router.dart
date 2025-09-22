import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/reservation/presentation/pages/reservation_list_page.dart';
import '../../features/reservation/presentation/pages/reservation_detail_page.dart';
import '../../features/reservation/presentation/pages/create_reservation_page.dart';
import '../../features/public/presentation/pages/public_home_page.dart';
import '../../features/public/presentation/pages/menu_page.dart';
import '../../features/public/presentation/pages/about_page.dart';
import '../../features/public/presentation/pages/contact_page.dart';
import '../../features/public/presentation/pages/public_reservation_page.dart';
import '../../features/public/presentation/pages/manage_reservation_page.dart';
import '../../main.dart';

/// Provider pour le routeur de l'application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/', // Démarrer sur la page d'accueil publique
    redirect: (context, state) {
      final isAdmin = authState.user?.role == 'ADMIN';
      final isAdminRoute = state.uri.toString().startsWith('/admin');
      final isAdminLogin = state.uri.toString() == '/admin/login';

      // Si route admin et pas admin connecté, rediriger vers login admin
      if (isAdminRoute && !isAdmin && !isAdminLogin) {
        return '/admin/login';
      }

      // Si admin connecté et essaie d'accéder au login admin, rediriger vers dashboard
      if (isAdmin && isAdminLogin) {
        return '/admin/dashboard';
      }

      return null; // Pas de redirection pour les routes publiques
    },
    routes: [
      // === ROUTES PUBLIQUES (Clients/Guests) ===
      GoRoute(
        path: '/',
        name: 'public-home',
        builder: (context, state) => const PublicHomePage(),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) => const MenuPage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/reserve',
        name: 'reserve',
        builder: (context, state) => const PublicReservationPage(),
      ),
      GoRoute(
        path: '/manage-reservation',
        name: 'manage-reservation',
        builder: (context, state) => const ManageReservationPage(),
      ),

      // === ROUTES ADMIN (Authentification requise) ===
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) =>
            const LoginPage(), // Utilise le login existant
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) =>
            const HomePage(), // Utilise la HomePage existante comme dashboard admin
        routes: [
          GoRoute(
            path: 'reservations',
            name: 'admin-reservations',
            builder: (context, state) => const ReservationListPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'admin-create-reservation',
                builder: (context, state) => const CreateReservationPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'admin-reservation-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ReservationDetailPage(reservationId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La page "${state.uri}" n\'existe pas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});
