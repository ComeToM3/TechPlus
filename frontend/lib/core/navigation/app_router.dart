import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/reservation/presentation/pages/reservation_list_page.dart';
import '../../features/admin/presentation/pages/reservation_list_page.dart' as admin;
import '../../features/reservation/presentation/pages/reservation_detail_page.dart';
import '../../features/reservation/presentation/pages/create_reservation_page.dart';
import '../../features/reservation/presentation/pages/reservation_selection_page.dart';
import '../../features/reservation/presentation/pages/reservation_info_page.dart';
import '../../features/reservation/presentation/pages/reservation_payment_page.dart';
import '../../features/reservation/presentation/pages/reservation_confirmation_page.dart';
import '../../features/reservation/presentation/pages/guest_management_page.dart';
import '../../features/reservation/presentation/pages/reservation_modification_page.dart';
import '../../features/reservation/presentation/pages/reservation_cancellation_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/token_login_page.dart';
import '../../features/public/presentation/pages/home_page.dart' as public;
import '../../features/public/presentation/pages/menu_page.dart';
import '../../features/public/presentation/pages/about_page.dart';
import '../../features/public/presentation/pages/contact_page.dart';
import '../../features/public/presentation/pages/public_reservation_page.dart';
import '../../features/public/presentation/pages/manage_reservation_page.dart';
import '../../features/demo/presentation/pages/animations_demo_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/simple_admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/reservation_management_page.dart';
import '../../features/admin/presentation/pages/reservation_list_page.dart';
import '../../features/admin/presentation/pages/reservation_details_page.dart';
import '../../features/admin/presentation/pages/restaurant_config_page.dart';
import '../../features/admin/presentation/pages/analytics_page.dart';
import '../../features/admin/presentation/pages/reports_page.dart';
import '../../main.dart';

/// Provider pour le routeur de l'application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/', // Démarrer sur la page d'accueil publique
    redirect: (BuildContext context, GoRouterState state) {
      final isAdmin = authState.user?.role == UserRole.ADMIN || authState.user?.role == UserRole.SUPER_ADMIN;
      final isAdminRoute = state.uri.toString().startsWith('/admin');
      final isAdminLogin = state.uri.toString() == '/admin/login';
      final isPublicHome = state.uri.toString() == '/';

      // Si admin connecté et sur la page publique, rediriger vers dashboard admin
      if (isAdmin && isPublicHome) {
        return '/admin/dashboard';
      }

      // Si route admin et pas admin connecté, rediriger vers login admin
      if (isAdminRoute && !isAdmin && !isAdminLogin) {
        return '/admin/login';
      }

      // Si admin connecté et essaie d'accéder au login admin, rediriger vers dashboard
      if (isAdmin && isAdminLogin) {
        return '/admin/dashboard';
      }

      return null; // Pas de redirection pour les autres routes publiques
    },
    routes: [
      // === ROUTES PUBLIQUES (Clients/Guests) ===
      GoRoute(
        path: '/',
        name: 'public-home',
        builder: (context, state) => const public.HomePage(),
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
        path: '/reservations/create',
        name: 'reservation-create',
        builder: (context, state) => const ReservationSelectionPage(),
        routes: [
          GoRoute(
            path: 'info',
            name: 'reservation-info',
            builder: (context, state) => const ReservationInfoPage(),
          ),
          GoRoute(
            path: 'payment',
            name: 'reservation-payment',
            builder: (context, state) => const ReservationPaymentPage(),
          ),
          GoRoute(
            path: 'confirmation',
            name: 'reservation-confirmation',
            builder: (context, state) => const ReservationConfirmationPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/demo/animations',
        name: 'animations-demo',
        builder: (context, state) => const AnimationsDemoPage(),
      ),
      GoRoute(
        path: '/manage-reservation',
        name: 'manage-reservation',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return GuestManagementPage(token: token);
        },
        routes: [
          GoRoute(
            path: 'modify',
            name: 'modify-reservation',
            builder: (context, state) => const ReservationModificationPage(),
          ),
          GoRoute(
            path: 'cancel',
            name: 'cancel-reservation',
            builder: (context, state) => const ReservationCancellationPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/reserve',
        name: 'reserve',
        builder: (context, state) => const PublicReservationPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/token-login',
        name: 'token-login',
        builder: (context, state) => const TokenLoginPage(),
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
            const AdminDashboardPage(), // Dashboard admin complet
        routes: [
        GoRoute(
          path: 'reservations',
          name: 'admin-reservations',
          builder: (context, state) => const ReservationManagementPage(),
          routes: [
            GoRoute(
              path: 'list',
              name: 'admin-reservations-list',
              builder: (context, state) => const admin.ReservationListPage(),
            ),
            GoRoute(
              path: 'create',
              name: 'admin-create-reservation',
              builder: (context, state) => const CreateReservationPage(),
            ),
            GoRoute(
              path: ':id',
              name: 'admin-reservation-details',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ReservationDetailsPage(reservationId: id);
              },
            ),
          ],
        ),
            GoRoute(
              path: 'config',
              name: 'admin-config',
              builder: (context, state) => const RestaurantConfigPage(),
            ),
            GoRoute(
              path: 'analytics',
              name: 'admin-analytics',
              builder: (context, state) => const AnalyticsPage(),
            ),
            GoRoute(
              path: 'reports',
              name: 'admin-reports',
              builder: (context, state) => const ReportsPage(),
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
