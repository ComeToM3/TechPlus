/// Modèle de réservation unifié
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Statuts de réservation
enum ReservationStatus {
  PENDING,
  CONFIRMED,
  CANCELLED,
  COMPLETED,
  NO_SHOW,
}

/// Statuts de paiement
enum PaymentStatus {
  NONE,
  PENDING,
  COMPLETED,
  FAILED,
  REFUNDED,
  PARTIALLY_REFUNDED,
}
