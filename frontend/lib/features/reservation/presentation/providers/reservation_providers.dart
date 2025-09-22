import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour l'état des réservations
final reservationStateProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
      return ReservationNotifier();
    });

/// État des réservations
class ReservationState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? error;
  final Reservation? selectedReservation;

  const ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
    this.selectedReservation,
  });

  ReservationState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error,
    Reservation? selectedReservation,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedReservation: selectedReservation ?? this.selectedReservation,
    );
  }
}

/// Modèle de réservation
class Reservation {
  final String id;
  final DateTime date;
  final String time;
  final int duration; // en minutes
  final int partySize;
  final String status;
  final String? notes;
  final String? specialRequests;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? managementToken;
  final bool requiresPayment;
  final double? depositAmount;
  final String paymentStatus;
  final String restaurantId;
  final String? tableId;

  const Reservation({
    required this.id,
    required this.date,
    required this.time,
    required this.duration,
    required this.partySize,
    required this.status,
    this.notes,
    this.specialRequests,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.managementToken,
    this.requiresPayment = false,
    this.depositAmount,
    this.paymentStatus = 'NONE',
    required this.restaurantId,
    this.tableId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      duration: json['duration'] as int,
      partySize: json['partySize'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      specialRequests: json['specialRequests'] as String?,
      clientName: json['clientName'] as String?,
      clientEmail: json['clientEmail'] as String?,
      clientPhone: json['clientPhone'] as String?,
      managementToken: json['managementToken'] as String?,
      requiresPayment: json['requiresPayment'] as bool? ?? false,
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String? ?? 'NONE',
      restaurantId: json['restaurantId'] as String,
      tableId: json['tableId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'partySize': partySize,
      'status': status,
      'notes': notes,
      'specialRequests': specialRequests,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'managementToken': managementToken,
      'requiresPayment': requiresPayment,
      'depositAmount': depositAmount,
      'paymentStatus': paymentStatus,
      'restaurantId': restaurantId,
      'tableId': tableId,
    };
  }
}

/// Notifier pour les réservations
class ReservationNotifier extends StateNotifier<ReservationState> {
  ReservationNotifier() : super(const ReservationState());

  /// Charger les réservations
  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      // Simulation de données
      final reservations = [
        Reservation(
          id: '1',
          date: DateTime.now().add(const Duration(days: 1)),
          time: '19:00',
          duration: 90,
          partySize: 4,
          status: 'PENDING',
          clientName: 'Jean Dupont',
          clientEmail: 'jean@example.com',
          restaurantId: 'restaurant_1',
        ),
        Reservation(
          id: '2',
          date: DateTime.now().add(const Duration(days: 2)),
          time: '20:30',
          duration: 120,
          partySize: 6,
          status: 'CONFIRMED',
          clientName: 'Marie Martin',
          clientEmail: 'marie@example.com',
          requiresPayment: true,
          depositAmount: 10.0,
          paymentStatus: 'COMPLETED',
          restaurantId: 'restaurant_1',
        ),
      ];

      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Créer une réservation
  Future<void> createReservation(Reservation reservation) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 2)); // Simulation

      final newReservation = reservation.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      state = state.copyWith(
        reservations: [...state.reservations, newReservation],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Mettre à jour une réservation
  Future<void> updateReservation(
    String id,
    Reservation updatedReservation,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      final reservations = state.reservations.map((r) {
        return r.id == id ? updatedReservation : r;
      }).toList();

      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Annuler une réservation
  Future<void> cancelReservation(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter l'appel API
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      final reservations = state.reservations.map((r) {
        return r.id == id ? r.copyWith(status: 'CANCELLED') : r;
      }).toList();

      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sélectionner une réservation
  void selectReservation(Reservation reservation) {
    state = state.copyWith(selectedReservation: reservation);
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Extension pour copier une réservation
extension ReservationCopyWith on Reservation {
  Reservation copyWith({
    String? id,
    DateTime? date,
    String? time,
    int? duration,
    int? partySize,
    String? status,
    String? notes,
    String? specialRequests,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? managementToken,
    bool? requiresPayment,
    double? depositAmount,
    String? paymentStatus,
    String? restaurantId,
    String? tableId,
  }) {
    return Reservation(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      partySize: partySize ?? this.partySize,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      managementToken: managementToken ?? this.managementToken,
      requiresPayment: requiresPayment ?? this.requiresPayment,
      depositAmount: depositAmount ?? this.depositAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
    );
  }
}
