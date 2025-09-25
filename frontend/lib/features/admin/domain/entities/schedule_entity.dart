/// Entité pour la configuration des créneaux horaires
class ScheduleConfig {
  final String id;
  final String restaurantId;
  final List<DaySchedule> daySchedules;
  final TimeSlotSettings timeSlotSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleConfig({
    required this.id,
    required this.restaurantId,
    required this.daySchedules,
    required this.timeSlotSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  ScheduleConfig copyWith({
    String? id,
    String? restaurantId,
    List<DaySchedule>? daySchedules,
    TimeSlotSettings? timeSlotSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleConfig(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      daySchedules: daySchedules ?? this.daySchedules,
      timeSlotSettings: timeSlotSettings ?? this.timeSlotSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'daySchedules': daySchedules.map((d) => d.toJson()).toList(),
      'timeSlotSettings': timeSlotSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    return ScheduleConfig(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      daySchedules: (json['daySchedules'] as List)
          .map((d) => DaySchedule.fromJson(d as Map<String, dynamic>))
          .toList(),
      timeSlotSettings: TimeSlotSettings.fromJson(json['timeSlotSettings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Entité pour les créneaux d'un jour spécifique
class DaySchedule {
  final String dayOfWeek;
  final bool isOpen;
  final List<TimeSlot> timeSlots;
  final String? notes;

  const DaySchedule({
    required this.dayOfWeek,
    required this.isOpen,
    required this.timeSlots,
    this.notes,
  });

  /// Crée une copie avec des valeurs modifiées
  DaySchedule copyWith({
    String? dayOfWeek,
    bool? isOpen,
    List<TimeSlot>? timeSlots,
    String? notes,
  }) {
    return DaySchedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isOpen: isOpen ?? this.isOpen,
      timeSlots: timeSlots ?? this.timeSlots,
      notes: notes ?? this.notes,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'isOpen': isOpen,
      'timeSlots': timeSlots.map((t) => t.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Crée depuis un Map
  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      dayOfWeek: json['dayOfWeek'] as String,
      isOpen: json['isOpen'] as bool,
      timeSlots: (json['timeSlots'] as List)
          .map((t) => TimeSlot.fromJson(t as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

/// Entité pour un créneau horaire
class TimeSlot {
  final String time;
  final bool isAvailable;
  final int capacity;
  final bool isRecommended;
  final String? notes;

  const TimeSlot({
    required this.time,
    required this.isAvailable,
    required this.capacity,
    this.isRecommended = false,
    this.notes,
  });

  /// Crée une copie avec des valeurs modifiées
  TimeSlot copyWith({
    String? time,
    bool? isAvailable,
    int? capacity,
    bool? isRecommended,
    String? notes,
  }) {
    return TimeSlot(
      time: time ?? this.time,
      isAvailable: isAvailable ?? this.isAvailable,
      capacity: capacity ?? this.capacity,
      isRecommended: isRecommended ?? this.isRecommended,
      notes: notes ?? this.notes,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'isAvailable': isAvailable,
      'capacity': capacity,
      'isRecommended': isRecommended,
      'notes': notes,
    };
  }

  /// Crée depuis un Map
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'] as String,
      isAvailable: json['isAvailable'] as bool,
      capacity: json['capacity'] as int,
      isRecommended: json['isRecommended'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Entité pour les paramètres des créneaux
class TimeSlotSettings {
  final int slotDurationMinutes;
  final int bufferTimeMinutes;
  final int maxAdvanceBookingDays;
  final int minAdvanceBookingHours;
  final bool allowSameDayBooking;
  final bool allowWeekendBooking;

  const TimeSlotSettings({
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
    required this.maxAdvanceBookingDays,
    required this.minAdvanceBookingHours,
    required this.allowSameDayBooking,
    required this.allowWeekendBooking,
  });

  /// Crée une copie avec des valeurs modifiées
  TimeSlotSettings copyWith({
    int? slotDurationMinutes,
    int? bufferTimeMinutes,
    int? maxAdvanceBookingDays,
    int? minAdvanceBookingHours,
    bool? allowSameDayBooking,
    bool? allowWeekendBooking,
  }) {
    return TimeSlotSettings(
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      bufferTimeMinutes: bufferTimeMinutes ?? this.bufferTimeMinutes,
      maxAdvanceBookingDays: maxAdvanceBookingDays ?? this.maxAdvanceBookingDays,
      minAdvanceBookingHours: minAdvanceBookingHours ?? this.minAdvanceBookingHours,
      allowSameDayBooking: allowSameDayBooking ?? this.allowSameDayBooking,
      allowWeekendBooking: allowWeekendBooking ?? this.allowWeekendBooking,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'slotDurationMinutes': slotDurationMinutes,
      'bufferTimeMinutes': bufferTimeMinutes,
      'maxAdvanceBookingDays': maxAdvanceBookingDays,
      'minAdvanceBookingHours': minAdvanceBookingHours,
      'allowSameDayBooking': allowSameDayBooking,
      'allowWeekendBooking': allowWeekendBooking,
    };
  }

  /// Crée depuis un Map
  factory TimeSlotSettings.fromJson(Map<String, dynamic> json) {
    return TimeSlotSettings(
      slotDurationMinutes: json['slotDurationMinutes'] as int,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int,
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int,
      minAdvanceBookingHours: json['minAdvanceBookingHours'] as int,
      allowSameDayBooking: json['allowSameDayBooking'] as bool,
      allowWeekendBooking: json['allowWeekendBooking'] as bool,
    );
  }
}

/// Énumération pour les jours de la semaine
enum DayOfWeek {
  monday('Monday', 'Lundi'),
  tuesday('Tuesday', 'Mardi'),
  wednesday('Wednesday', 'Mercredi'),
  thursday('Thursday', 'Jeudi'),
  friday('Friday', 'Vendredi'),
  saturday('Saturday', 'Samedi'),
  sunday('Sunday', 'Dimanche');

  const DayOfWeek(this.english, this.french);
  
  final String english;
  final String french;
  
  String getLocalizedName(String locale) {
    switch (locale) {
      case 'fr':
        return french;
      case 'en':
      default:
        return english;
    }
  }
}
