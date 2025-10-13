import 'package:go_router/go_router.dart';
import '../pages/reservation_home_page.dart';
import '../pages/public_reservation_page.dart';
import '../pages/simple_reservation_confirmation_page.dart';

/// Routes pour les réservations publiques
final List<RouteBase> reservationRoutes = [
  GoRoute(
    path: '/reservations',
    name: 'reservation-home',
    builder: (context, state) => const ReservationHomePage(),
  ),
  GoRoute(
    path: '/reservation',
    name: 'public-reservation',
    builder: (context, state) => const PublicReservationPage(),
  ),
  GoRoute(
    path: '/reservation/confirmation/:id',
    name: 'reservation-confirmation',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      
      // Utiliser la page de confirmation qui récupère les données depuis l'API
      return SimpleReservationConfirmationPage(
        reservationId: id,
        clientName: '', // Sera récupéré depuis l'API
        clientEmail: '', // Sera récupéré depuis l'API
        clientPhone: '', // Sera récupéré depuis l'API
        date: DateTime.now(), // Sera récupéré depuis l'API
        time: '', // Sera récupéré depuis l'API
        partySize: 2, // Sera récupéré depuis l'API
        status: 'PENDING', // Sera récupéré depuis l'API
      );
    },
  ),
  GoRoute(
    path: '/reservation/manage/:token',
    name: 'reservation-manage',
    builder: (context, state) {
      final token = state.pathParameters['token']!;
      return ReservationConfirmationPage(reservationId: token);
    },
  ),
];
