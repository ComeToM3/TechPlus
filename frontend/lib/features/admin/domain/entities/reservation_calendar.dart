/// Entité pour les données du calendrier de réservations
class ReservationCalendar {
  final String id;
  final DateTime date;
  final String time;
  final int partySize;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final String status;
  final String? tableNumber;
  final String? notes;
  final String? specialRequests;
  final double? estimatedAmount;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReservationCalendar({
    required this.id,
    required this.date,
    required this.time,
    required this.partySize,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    required this.status,
    this.tableNumber,
    this.notes,
    this.specialRequests,
    this.estimatedAmount,
    this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  ReservationCalendar copyWith({
    String? id,
    DateTime? date,
    String? time,
    int? partySize,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? status,
    String? tableNumber,
    String? notes,
    String? specialRequests,
    double? estimatedAmount,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationCalendar(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      partySize: partySize ?? this.partySize,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time': time,
      'partySize': partySize,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'status': status,
      'tableNumber': tableNumber,
      'notes': notes,
      'specialRequests': specialRequests,
      'estimatedAmount': estimatedAmount,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory ReservationCalendar.fromJson(Map<String, dynamic> json) {
    return ReservationCalendar(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      partySize: json['partySize'] as int,
      clientName: json['clientName'] as String,
      clientEmail: json['clientEmail'] as String,
      clientPhone: json['clientPhone'] as String?,
      status: json['status'] as String,
      tableNumber: json['tableNumber'] as String?,
      notes: json['notes'] as String?,
      specialRequests: json['specialRequests'] as String?,
      estimatedAmount: (json['estimatedAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationCalendar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReservationCalendar(id: $id, date: $date, time: $time, partySize: $partySize, clientName: $clientName, status: $status)';
  }
}

/// Énumération des statuts de réservation
enum ReservationStatus {
  pending('PENDING', 'En attente'),
  confirmed('CONFIRMED', 'Confirmée'),
  cancelled('CANCELLED', 'Annulée'),
  completed('COMPLETED', 'Terminée'),
  noShow('NO_SHOW', 'No-show');

  const ReservationStatus(this.value, this.label);

  final String value;
  final String label;

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReservationStatus.pending,
    );
  }
}

/// Énumération des statuts de paiement
enum PaymentStatus {
  none('NONE', 'Aucun'),
  pending('PENDING', 'En attente'),
  completed('COMPLETED', 'Payé'),
  failed('FAILED', 'Échoué'),
  refunded('REFUNDED', 'Remboursé'),
  partiallyRefunded('PARTIALLY_REFUNDED', 'Partiellement remboursé');

  const PaymentStatus(this.value, this.label);

  final String value;
  final String label;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.none,
    );
  }
}

/// Type de vue du calendrier
enum CalendarViewType {
  monthly,
  weekly,
  daily,
}

/// Filtres pour le calendrier
class CalendarFilters {
  final List<ReservationStatus> statusFilter;
  final List<String> tableFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const CalendarFilters({
    this.statusFilter = const [],
    this.tableFilter = const [],
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  CalendarFilters copyWith({
    List<ReservationStatus>? statusFilter,
    List<String>? tableFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return CalendarFilters(
      statusFilter: statusFilter ?? this.statusFilter,
      tableFilter: tableFilter ?? this.tableFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
