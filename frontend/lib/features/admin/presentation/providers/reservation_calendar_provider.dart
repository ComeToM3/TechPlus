import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../domain/repositories/reservation_calendar_repository.dart';
import '../../data/repositories/reservation_calendar_repository_impl.dart';
import '../../data/datasources/reservation_calendar_remote_datasource.dart';
import '../../data/datasources/reservation_calendar_local_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

/// Provider pour SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider pour ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  return ApiClient(dio);
});

/// Provider pour la data source distante
final reservationCalendarRemoteDataSourceProvider = Provider<ReservationCalendarRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReservationCalendarRemoteDataSource(apiClient);
});

/// Provider pour la data source locale
final reservationCalendarLocalDataSourceProvider = Provider<ReservationCalendarLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReservationCalendarLocalDataSource(prefs);
});

/// Provider pour le repository
final reservationCalendarRepositoryProvider = Provider<ReservationCalendarRepository>((ref) {
  final remoteDataSource = ref.watch(reservationCalendarRemoteDataSourceProvider);
  final localDataSource = ref.watch(reservationCalendarLocalDataSourceProvider);
  return ReservationCalendarRepositoryImpl(remoteDataSource, localDataSource);
});

/// État du calendrier des réservations
class ReservationCalendarState {
  final List<ReservationCalendar> reservations;
  final CalendarViewType viewType;
  final DateTime selectedDate;
  final CalendarFilters filters;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  const ReservationCalendarState({
    this.reservations = const [],
    this.viewType = CalendarViewType.monthly,
    required this.selectedDate,
    this.filters = const CalendarFilters(),
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  ReservationCalendarState copyWith({
    List<ReservationCalendar>? reservations,
    CalendarViewType? viewType,
    DateTime? selectedDate,
    CalendarFilters? filters,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return ReservationCalendarState(
      reservations: reservations ?? this.reservations,
      viewType: viewType ?? this.viewType,
      selectedDate: selectedDate ?? this.selectedDate,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

/// Notifier pour le calendrier des réservations
class ReservationCalendarNotifier extends StateNotifier<ReservationCalendarState> {
  final ReservationCalendarRepository _repository;

  ReservationCalendarNotifier(this._repository) : super(
    ReservationCalendarState(selectedDate: DateTime.now()),
  ) {
    _loadReservations();
  }

  /// Charge les réservations pour la période actuelle
  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final startDate = _getStartDateForView();
      final endDate = _getEndDateForView();

      final reservations = await _repository.getReservationsForPeriod(
        startDate: startDate,
        endDate: endDate,
        filters: state.filters,
      );

      state = state.copyWith(
        reservations: reservations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change le type de vue du calendrier
  Future<void> changeViewType(CalendarViewType viewType) async {
    state = state.copyWith(viewType: viewType);
    await _loadReservations();
  }

  /// Change la date sélectionnée
  Future<void> changeSelectedDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await _loadReservations();
  }

  /// Applique des filtres
  Future<void> applyFilters(CalendarFilters filters) async {
    state = state.copyWith(filters: filters);
    await _loadReservations();
  }

  /// Actualise les réservations
  Future<void> refresh() async {
    await _loadReservations();
  }

  /// Crée une nouvelle réservation
  Future<ReservationCalendar?> createReservation(ReservationCalendar reservation) async {
    try {
      final createdReservation = await _repository.createReservation(reservation);
      
      // Actualise la liste
      await _loadReservations();
      
      return createdReservation;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Met à jour une réservation
  Future<ReservationCalendar?> updateReservation(ReservationCalendar reservation) async {
    try {
      final updatedReservation = await _repository.updateReservation(reservation);
      
      // Actualise la liste
      await _loadReservations();
      
      return updatedReservation;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Supprime une réservation
  Future<bool> deleteReservation(String id) async {
    try {
      await _repository.deleteReservation(id);
      
      // Actualise la liste
      await _loadReservations();
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Met à jour le statut d'une réservation
  Future<ReservationCalendar?> updateReservationStatus({
    required String id,
    required ReservationStatus status,
    String? notes,
  }) async {
    try {
      final updatedReservation = await _repository.updateReservationStatus(
        id: id,
        status: status,
        notes: notes,
      );
      
      // Actualise la liste
      await _loadReservations();
      
      return updatedReservation;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Met à jour la table d'une réservation
  Future<ReservationCalendar?> updateReservationTable({
    required String id,
    required String tableNumber,
  }) async {
    try {
      final updatedReservation = await _repository.updateReservationTable(
        id: id,
        tableNumber: tableNumber,
      );
      
      // Actualise la liste
      await _loadReservations();
      
      return updatedReservation;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Récupère les tables disponibles
  Future<List<String>> getAvailableTables({
    required DateTime date,
    required String time,
    required int partySize,
    String? excludeReservationId,
  }) async {
    try {
      return await _repository.getAvailableTables(
        date: date,
        time: time,
        partySize: partySize,
        excludeReservationId: excludeReservationId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Charge les statistiques
  Future<void> loadStatistics() async {
    try {
      final startDate = _getStartDateForView();
      final endDate = _getEndDateForView();

      final statistics = await _repository.getStatisticsForPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Récupère les réservations pour une date spécifique
  List<ReservationCalendar> getReservationsForDate(DateTime date) {
    return state.reservations.where((reservation) {
      return reservation.date.year == date.year &&
             reservation.date.month == date.month &&
             reservation.date.day == date.day;
    }).toList();
  }

  /// Récupère les réservations pour une heure spécifique
  List<ReservationCalendar> getReservationsForTime(DateTime date, String time) {
    return state.reservations.where((reservation) {
      return reservation.date.year == date.year &&
             reservation.date.month == date.month &&
             reservation.date.day == date.day &&
             reservation.time == time;
    }).toList();
  }

  /// Calcule la date de début selon la vue
  DateTime _getStartDateForView() {
    switch (state.viewType) {
      case CalendarViewType.monthly:
        return DateTime(state.selectedDate.year, state.selectedDate.month, 1);
      case CalendarViewType.weekly:
        final startOfWeek = state.selectedDate.subtract(
          Duration(days: state.selectedDate.weekday - 1),
        );
        return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      case CalendarViewType.daily:
        return DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);
    }
  }

  /// Calcule la date de fin selon la vue
  DateTime _getEndDateForView() {
    switch (state.viewType) {
      case CalendarViewType.monthly:
        return DateTime(state.selectedDate.year, state.selectedDate.month + 1, 0);
      case CalendarViewType.weekly:
        final startOfWeek = state.selectedDate.subtract(
          Duration(days: state.selectedDate.weekday - 1),
        );
        return startOfWeek.add(const Duration(days: 6));
      case CalendarViewType.daily:
        return DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day, 23, 59);
    }
  }
}

/// Provider pour le notifier du calendrier
final reservationCalendarProvider = StateNotifierProvider<ReservationCalendarNotifier, ReservationCalendarState>((ref) {
  final repository = ref.watch(reservationCalendarRepositoryProvider);
  return ReservationCalendarNotifier(repository);
});
