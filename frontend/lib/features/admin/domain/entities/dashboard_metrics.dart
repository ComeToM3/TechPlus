/// Entités pour les métriques du dashboard admin
class DashboardMetrics {
  final int totalReservations;
  final int todayReservations;
  final int pendingReservations;
  final int confirmedReservations;
  final int cancelledReservations;
  final double totalRevenue;
  final double todayRevenue;
  final double averageRevenue;
  final int totalTables;
  final int occupiedTables;
  final double occupancyRate;
  final int totalCustomers;
  final int newCustomers;
  final double averagePartySize;
  final double averageReservationDuration;
  final List<ReservationTrend> reservationTrends;
  final List<RevenueTrend> revenueTrends;
  final List<TableOccupancy> tableOccupancy;
  final List<PopularTimeSlot> popularTimeSlots;
  final List<CustomerSegment> customerSegments;

  const DashboardMetrics({
    required this.totalReservations,
    required this.todayReservations,
    required this.pendingReservations,
    required this.confirmedReservations,
    required this.cancelledReservations,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.averageRevenue,
    required this.totalTables,
    required this.occupiedTables,
    required this.occupancyRate,
    required this.totalCustomers,
    required this.newCustomers,
    required this.averagePartySize,
    required this.averageReservationDuration,
    required this.reservationTrends,
    required this.revenueTrends,
    required this.tableOccupancy,
    required this.popularTimeSlots,
    required this.customerSegments,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalReservations: json['totalReservations'] ?? 0,
      todayReservations: json['todayReservations'] ?? 0,
      pendingReservations: json['pendingReservations'] ?? 0,
      confirmedReservations: json['confirmedReservations'] ?? 0,
      cancelledReservations: json['cancelledReservations'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0.0).toDouble(),
      averageRevenue: (json['averageRevenue'] ?? 0.0).toDouble(),
      totalTables: json['totalTables'] ?? 0,
      occupiedTables: json['occupiedTables'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0.0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      newCustomers: json['newCustomers'] ?? 0,
      averagePartySize: (json['averagePartySize'] ?? 0.0).toDouble(),
      averageReservationDuration: (json['averageReservationDuration'] ?? 0.0).toDouble(),
      reservationTrends: (json['reservationTrends'] as List<dynamic>?)
          ?.map((e) => ReservationTrend.fromJson(e))
          .toList() ?? [],
      revenueTrends: (json['revenueTrends'] as List<dynamic>?)
          ?.map((e) => RevenueTrend.fromJson(e))
          .toList() ?? [],
      tableOccupancy: (json['tableOccupancy'] as List<dynamic>?)
          ?.map((e) => TableOccupancy.fromJson(e))
          .toList() ?? [],
      popularTimeSlots: (json['popularTimeSlots'] as List<dynamic>?)
          ?.map((e) => PopularTimeSlot.fromJson(e))
          .toList() ?? [],
      customerSegments: (json['customerSegments'] as List<dynamic>?)
          ?.map((e) => CustomerSegment.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReservations': totalReservations,
      'todayReservations': todayReservations,
      'pendingReservations': pendingReservations,
      'confirmedReservations': confirmedReservations,
      'cancelledReservations': cancelledReservations,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'averageRevenue': averageRevenue,
      'totalTables': totalTables,
      'occupiedTables': occupiedTables,
      'occupancyRate': occupancyRate,
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'averagePartySize': averagePartySize,
      'averageReservationDuration': averageReservationDuration,
      'reservationTrends': reservationTrends.map((e) => e.toJson()).toList(),
      'revenueTrends': revenueTrends.map((e) => e.toJson()).toList(),
      'tableOccupancy': tableOccupancy.map((e) => e.toJson()).toList(),
      'popularTimeSlots': popularTimeSlots.map((e) => e.toJson()).toList(),
      'customerSegments': customerSegments.map((e) => e.toJson()).toList(),
    };
  }
}

/// Tendance des réservations
class ReservationTrend {
  final DateTime date;
  final int count;
  final double revenue;

  const ReservationTrend({
    required this.date,
    required this.count,
    required this.revenue,
  });

  factory ReservationTrend.fromJson(Map<String, dynamic> json) {
    return ReservationTrend(
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'revenue': revenue,
    };
  }
}

/// Tendance des revenus
class RevenueTrend {
  final DateTime date;
  final double amount;
  final int reservationCount;

  const RevenueTrend({
    required this.date,
    required this.amount,
    required this.reservationCount,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      reservationCount: json['reservationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'reservationCount': reservationCount,
    };
  }
}

/// Occupation des tables
class TableOccupancy {
  final String tableId;
  final int tableNumber;
  final int capacity;
  final bool isOccupied;
  final String? reservationId;
  final String? customerName;
  final DateTime? reservationTime;
  final int? partySize;

  const TableOccupancy({
    required this.tableId,
    required this.tableNumber,
    required this.capacity,
    required this.isOccupied,
    this.reservationId,
    this.customerName,
    this.reservationTime,
    this.partySize,
  });

  factory TableOccupancy.fromJson(Map<String, dynamic> json) {
    return TableOccupancy(
      tableId: json['tableId'] ?? '',
      tableNumber: json['tableNumber'] ?? 0,
      capacity: json['capacity'] ?? 0,
      isOccupied: json['isOccupied'] ?? false,
      reservationId: json['reservationId'],
      customerName: json['customerName'],
      reservationTime: json['reservationTime'] != null 
          ? DateTime.parse(json['reservationTime']) 
          : null,
      partySize: json['partySize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'isOccupied': isOccupied,
      'reservationId': reservationId,
      'customerName': customerName,
      'reservationTime': reservationTime?.toIso8601String(),
      'partySize': partySize,
    };
  }
}

/// Créneaux horaires populaires
class PopularTimeSlot {
  final String timeSlot;
  final int reservationCount;
  final double averagePartySize;
  final double revenue;

  const PopularTimeSlot({
    required this.timeSlot,
    required this.reservationCount,
    required this.averagePartySize,
    required this.revenue,
  });

  factory PopularTimeSlot.fromJson(Map<String, dynamic> json) {
    return PopularTimeSlot(
      timeSlot: json['timeSlot'] ?? '',
      reservationCount: json['reservationCount'] ?? 0,
      averagePartySize: (json['averagePartySize'] ?? 0.0).toDouble(),
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot,
      'reservationCount': reservationCount,
      'averagePartySize': averagePartySize,
      'revenue': revenue,
    };
  }
}

/// Segments de clients
class CustomerSegment {
  final String segment;
  final int count;
  final double percentage;
  final double averageRevenue;

  const CustomerSegment({
    required this.segment,
    required this.count,
    required this.percentage,
    required this.averageRevenue,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      segment: json['segment'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      averageRevenue: (json['averageRevenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segment': segment,
      'count': count,
      'percentage': percentage,
      'averageRevenue': averageRevenue,
    };
  }
}
