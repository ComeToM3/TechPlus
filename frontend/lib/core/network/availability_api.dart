import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// API pour la gestion des créneaux de disponibilité
class AvailabilityApi {
  final Dio _dio;
  final String _baseUrl;

  AvailabilityApi(this._dio, this._baseUrl);

  /// Obtenir les créneaux disponibles pour une date et une taille de groupe
  Future<List<TimeSlot>> getAvailableSlots({
    required DateTime date,
    required int partySize,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/availability/slots',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> slotsData = response.data['slots'];
        return slotsData.map((slot) => TimeSlot.fromJson(slot)).toList();
      } else {
        throw Exception('Failed to fetch available slots');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching slots: $e');
    }
  }

  /// Vérifier la disponibilité d'un créneau spécifique
  Future<bool> checkSlotAvailability({
    required DateTime date,
    required String time,
    required int partySize,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/availability/check',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        return response.data['available'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtenir les créneaux recommandés pour une date
  Future<List<String>> getRecommendedSlots({
    required DateTime date,
    required int partySize,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/availability/recommended',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          'partySize': partySize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommended = response.data['recommended'];
        return recommended.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les heures d'ouverture du restaurant
  Future<RestaurantHours> getRestaurantHours() async {
    try {
      final response = await _dio.get('$_baseUrl/api/restaurant/hours');

      if (response.statusCode == 200) {
        return RestaurantHours.fromJson(response.data);
      } else {
        // Retourner des heures par défaut en cas d'erreur
        return RestaurantHours.defaultHours();
      }
    } catch (e) {
      return RestaurantHours.defaultHours();
    }
  }
}

/// Modèle pour un créneau horaire
class TimeSlot {
  final String time;
  final bool isAvailable;
  final bool isRecommended;
  final int capacity;
  final String? note;

  const TimeSlot({
    required this.time,
    required this.isAvailable,
    required this.isRecommended,
    required this.capacity,
    this.note,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      isRecommended: json['isRecommended'] ?? false,
      capacity: json['capacity'] ?? 0,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'isAvailable': isAvailable,
      'isRecommended': isRecommended,
      'capacity': capacity,
      'note': note,
    };
  }
}

/// Modèle pour les heures d'ouverture du restaurant
class RestaurantHours {
  final Map<String, DayHours> weeklyHours;
  final List<String> holidays;

  const RestaurantHours({
    required this.weeklyHours,
    required this.holidays,
  });

  factory RestaurantHours.fromJson(Map<String, dynamic> json) {
    final weeklyHours = <String, DayHours>{};
    final hoursData = json['weeklyHours'] as Map<String, dynamic>;
    
    for (final entry in hoursData.entries) {
      weeklyHours[entry.key] = DayHours.fromJson(entry.value);
    }

    return RestaurantHours(
      weeklyHours: weeklyHours,
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }

  factory RestaurantHours.defaultHours() {
    return const RestaurantHours(
      weeklyHours: {
        'monday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'tuesday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'wednesday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'thursday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'friday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'saturday': DayHours(open: '12:00', close: '14:00', isOpen: true),
        'sunday': DayHours(open: '12:00', close: '14:00', isOpen: true),
      },
      holidays: [],
    );
  }

  bool isOpenOn(DateTime date) {
    final dayName = _getDayName(date.weekday);
    final dayHours = weeklyHours[dayName];
    
    if (dayHours == null || !dayHours.isOpen) return false;
    
    // Vérifier si c'est un jour férié
    final dateStr = date.toIso8601String().split('T')[0];
    return !holidays.contains(dateStr);
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }
}

/// Modèle pour les heures d'une journée
class DayHours {
  final String open;
  final String close;
  final bool isOpen;

  const DayHours({
    required this.open,
    required this.close,
    required this.isOpen,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      open: json['open'] ?? '12:00',
      close: json['close'] ?? '14:00',
      isOpen: json['isOpen'] ?? true,
    );
  }
}
