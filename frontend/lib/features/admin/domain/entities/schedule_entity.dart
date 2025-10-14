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
      // Le backend attend les paramètres directement, pas dans timeSlotSettings
      'slotDurationMinutes': timeSlotSettings.slotDurationMinutes,
      'bufferTimeMinutes': timeSlotSettings.bufferTimeMinutes,
      'maxAdvanceBookingDays': timeSlotSettings.maxAdvanceBookingDays,
      'minAdvanceBookingHours': timeSlotSettings.minAdvanceBookingHours,
      'allowSameDayBooking': timeSlotSettings.allowSameDayBooking,
      'allowWeekendBooking': timeSlotSettings.allowWeekendBooking,
      'defaultCapacityPerSlot': timeSlotSettings.defaultCapacityPerSlot,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    print('🔍 [ScheduleConfig.fromJson] Parsing JSON data');
    print('🔍 [ScheduleConfig.fromJson] JSON keys: ${json.keys.toList()}');
    print('🔍 [ScheduleConfig.fromJson] daySchedules in JSON: ${json['daySchedules']?.length ?? 0}');
    print('🔍 [ScheduleConfig.fromJson] daySchedules data: ${json['daySchedules']}');
    
    // Le backend retourne les paramètres directement, pas dans timeSlotSettings
    TimeSlotSettings timeSlotSettings = TimeSlotSettings(
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int? ?? 15,
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int? ?? 30,
      minAdvanceBookingHours: json['minAdvanceBookingHours'] as int? ?? 2,
      allowSameDayBooking: json['allowSameDayBooking'] as bool? ?? true,
      allowWeekendBooking: json['allowWeekendBooking'] as bool? ?? true,
      defaultCapacityPerSlot: json['defaultCapacityPerSlot'] as int? ?? 20,
    );

    final daySchedules = (json['daySchedules'] as List?)
        ?.map((d) => DaySchedule.fromJson(d as Map<String, dynamic>))
        .toList() ?? [];
    
    print('🔍 [ScheduleConfig.fromJson] Parsed daySchedules count: ${daySchedules.length}');
    for (final day in daySchedules) {
      print('🔍 [ScheduleConfig.fromJson] Day: ${day.dayOfWeek}, Open: ${day.isOpen}, Slots: ${day.timeSlots.length}');
    }

    return ScheduleConfig(
      id: json['id'] as String? ?? 'default',
      restaurantId: json['restaurantId'] as String? ?? 'restaurant_1',
      daySchedules: daySchedules,
      timeSlotSettings: timeSlotSettings,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Entité pour les créneaux d'un jour spécifique
class DaySchedule {
  final String dayOfWeek;
  final bool isOpen;
  final List<TimeSlot> timeSlots;
  final String? notes;
  final String? openingTime;
  final String? closingTime;

  const DaySchedule({
    required this.dayOfWeek,
    required this.isOpen,
    required this.timeSlots,
    this.notes,
    this.openingTime,
    this.closingTime,
  });

  /// Crée une copie avec des valeurs modifiées
  DaySchedule copyWith({
    String? dayOfWeek,
    bool? isOpen,
    List<TimeSlot>? timeSlots,
    String? notes,
    String? openingTime,
    String? closingTime,
  }) {
    return DaySchedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isOpen: isOpen ?? this.isOpen,
      timeSlots: timeSlots ?? this.timeSlots,
      notes: notes ?? this.notes,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'isOpen': isOpen,
      'timeSlots': timeSlots.map((t) => t.toJson()).toList(),
      'notes': notes,
      'openingTime': openingTime,
      'closingTime': closingTime,
    };
  }

  /// Crée depuis un Map
  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      dayOfWeek: json['dayOfWeek'] as String? ?? 'monday',
      isOpen: json['isOpen'] as bool? ?? false,
      timeSlots: (json['timeSlots'] as List?)
          ?.map((t) => TimeSlot.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      notes: json['notes'] as String?,
      openingTime: json['openingTime'] as String?,
      closingTime: json['closingTime'] as String?,
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
      time: json['time'] as String? ?? '12:00',
      isAvailable: json['isAvailable'] as bool? ?? true,
      capacity: json['capacity'] as int? ?? 25,
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
  final int defaultCapacityPerSlot;

  const TimeSlotSettings({
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
    required this.maxAdvanceBookingDays,
    required this.minAdvanceBookingHours,
    required this.allowSameDayBooking,
    required this.allowWeekendBooking,
    required this.defaultCapacityPerSlot,
  });

  /// Crée une copie avec des valeurs modifiées
  TimeSlotSettings copyWith({
    int? slotDurationMinutes,
    int? bufferTimeMinutes,
    int? maxAdvanceBookingDays,
    int? minAdvanceBookingHours,
    bool? allowSameDayBooking,
    bool? allowWeekendBooking,
    int? defaultCapacityPerSlot,
  }) {
    return TimeSlotSettings(
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      bufferTimeMinutes: bufferTimeMinutes ?? this.bufferTimeMinutes,
      maxAdvanceBookingDays: maxAdvanceBookingDays ?? this.maxAdvanceBookingDays,
      minAdvanceBookingHours: minAdvanceBookingHours ?? this.minAdvanceBookingHours,
      allowSameDayBooking: allowSameDayBooking ?? this.allowSameDayBooking,
      allowWeekendBooking: allowWeekendBooking ?? this.allowWeekendBooking,
      defaultCapacityPerSlot: defaultCapacityPerSlot ?? this.defaultCapacityPerSlot,
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
      'defaultCapacityPerSlot': defaultCapacityPerSlot,
    };
  }

  /// Crée depuis un Map
  factory TimeSlotSettings.fromJson(Map<String, dynamic> json) {
    return TimeSlotSettings(
      slotDurationMinutes: json['slotDurationMinutes'] as int? ?? 30,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int? ?? 15,
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int? ?? 30,
      minAdvanceBookingHours: json['minAdvanceBookingHours'] as int? ?? 2,
      allowSameDayBooking: json['allowSameDayBooking'] as bool? ?? true,
      allowWeekendBooking: json['allowWeekendBooking'] as bool? ?? true,
      defaultCapacityPerSlot: json['defaultCapacityPerSlot'] as int? ?? 20,
    );
  }

  /// Crée des paramètres par défaut
  factory TimeSlotSettings.defaultSettings() {
    return const TimeSlotSettings(
      slotDurationMinutes: 30,
      bufferTimeMinutes: 15,
      maxAdvanceBookingDays: 30,
      minAdvanceBookingHours: 2,
      allowSameDayBooking: true,
      allowWeekendBooking: true,
      defaultCapacityPerSlot: 20,
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
