import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/services/public_restaurant_service.dart';
import '../../data/services/public_availability_service.dart';
import '../../../../core/network/api_service.dart';

/// Provider pour l'ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(Dio(), 'http://localhost:3000');
});

/// Provider pour le service de restaurant public
final publicRestaurantServiceProvider = Provider<PublicRestaurantService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PublicRestaurantService(apiService);
});

/// Provider pour le service de disponibilité public
final publicAvailabilityServiceProvider = Provider<PublicAvailabilityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PublicAvailabilityService(apiService);
});

/// État pour les informations du restaurant
class RestaurantInfoState {
  final Map<String, dynamic>? restaurantInfo;
  final Map<String, dynamic>? openingHours;
  final List<Map<String, dynamic>>? tables;
  final bool isLoading;
  final String? error;

  const RestaurantInfoState({
    this.restaurantInfo,
    this.openingHours,
    this.tables,
    this.isLoading = false,
    this.error,
  });

  RestaurantInfoState copyWith({
    Map<String, dynamic>? restaurantInfo,
    Map<String, dynamic>? openingHours,
    List<Map<String, dynamic>>? tables,
    bool? isLoading,
    String? error,
  }) {
    return RestaurantInfoState(
      restaurantInfo: restaurantInfo ?? this.restaurantInfo,
      openingHours: openingHours ?? this.openingHours,
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider pour les informations du restaurant
final restaurantInfoProvider = StateNotifierProvider<RestaurantInfoNotifier, RestaurantInfoState>((ref) {
  final restaurantService = ref.watch(publicRestaurantServiceProvider);
  return RestaurantInfoNotifier(restaurantService);
});

/// Notifier pour les informations du restaurant
class RestaurantInfoNotifier extends StateNotifier<RestaurantInfoState> {
  final PublicRestaurantService _restaurantService;

  RestaurantInfoNotifier(this._restaurantService) : super(const RestaurantInfoState());

  /// Charge les informations du restaurant
  Future<void> loadRestaurantInfo() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final restaurantInfo = await _restaurantService.getRestaurantConfig();
      final openingHours = await _restaurantService.getOpeningHours();
      final tables = await _restaurantService.getAllTables();
      
      state = state.copyWith(
        restaurantInfo: restaurantInfo,
        openingHours: openingHours,
        tables: tables,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Recharge les informations
  Future<void> refresh() async {
    await loadRestaurantInfo();
  }
}

/// État pour les créneaux horaires disponibles
class AvailableTimeSlotsState {
  final List<String> timeSlots;
  final bool isLoading;
  final String? error;

  const AvailableTimeSlotsState({
    this.timeSlots = const [],
    this.isLoading = false,
    this.error,
  });

  AvailableTimeSlotsState copyWith({
    List<String>? timeSlots,
    bool? isLoading,
    String? error,
  }) {
    return AvailableTimeSlotsState(
      timeSlots: timeSlots ?? this.timeSlots,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider pour les créneaux horaires disponibles
final availableTimeSlotsProvider = StateNotifierProvider.family<AvailableTimeSlotsNotifier, AvailableTimeSlotsState, ({DateTime date, int partySize})>((ref, params) {
  final availabilityService = ref.watch(publicAvailabilityServiceProvider);
  return AvailableTimeSlotsNotifier(availabilityService, params.date, params.partySize);
});

/// Notifier pour les créneaux horaires disponibles
class AvailableTimeSlotsNotifier extends StateNotifier<AvailableTimeSlotsState> {
  final PublicAvailabilityService _availabilityService;
  final DateTime _date;
  final int _partySize;

  AvailableTimeSlotsNotifier(this._availabilityService, this._date, this._partySize) : super(const AvailableTimeSlotsState());

  /// Charge les créneaux disponibles
  Future<void> loadTimeSlots() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final timeSlots = await _availabilityService.getAvailableTimeSlots(
        date: _date,
        partySize: _partySize,
      );
      
      state = state.copyWith(
        timeSlots: timeSlots,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// État pour les tables disponibles
class AvailableTablesState {
  final List<Map<String, dynamic>> tables;
  final bool isLoading;
  final String? error;

  const AvailableTablesState({
    this.tables = const [],
    this.isLoading = false,
    this.error,
  });

  AvailableTablesState copyWith({
    List<Map<String, dynamic>>? tables,
    bool? isLoading,
    String? error,
  }) {
    return AvailableTablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider pour les tables disponibles
final availableTablesProvider = StateNotifierProvider.family<AvailableTablesNotifier, AvailableTablesState, ({DateTime date, String time, int partySize})>((ref, params) {
  final availabilityService = ref.watch(publicAvailabilityServiceProvider);
  return AvailableTablesNotifier(availabilityService, params.date, params.time, params.partySize);
});

/// Notifier pour les tables disponibles
class AvailableTablesNotifier extends StateNotifier<AvailableTablesState> {
  final PublicAvailabilityService _availabilityService;
  final DateTime _date;
  final String _time;
  final int _partySize;

  AvailableTablesNotifier(this._availabilityService, this._date, this._time, this._partySize) : super(const AvailableTablesState());

  /// Charge les tables disponibles
  Future<void> loadTables() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final tables = await _availabilityService.getAvailableTables(
        date: _date,
        time: _time,
        partySize: _partySize,
      );
      
      state = state.copyWith(
        tables: tables,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
