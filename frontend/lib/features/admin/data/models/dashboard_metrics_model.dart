/// Modèle de données pour les métriques du dashboard
class DashboardMetricsModel {
  final int todayReservations;
  final int confirmedReservations;
  final int pendingReservations;
  final int cancelledReservations;
  final int totalTables;
  final int occupiedTables;
  final double todayRevenue;
  final double totalRevenue;
  final double averageRevenue;
  final double occupancyRate;
  final int totalReservations;
  final int totalCustomers;
  final int newCustomers;
  final double averagePartySize;
  final double averageReservationDuration;
  final List<CustomerSegment> customerSegments;
  final List<PopularTimeSlot> popularTimeSlots;
  final List<ReservationTrend> reservationTrends;
  final List<RevenueTrend> revenueTrends;
  final List<TableOccupancy> tableOccupancy;

  const DashboardMetricsModel({
    required this.todayReservations,
    required this.confirmedReservations,
    required this.pendingReservations,
    required this.cancelledReservations,
    required this.totalTables,
    required this.occupiedTables,
    required this.todayRevenue,
    required this.totalRevenue,
    required this.averageRevenue,
    required this.occupancyRate,
    required this.totalReservations,
    required this.totalCustomers,
    required this.newCustomers,
    required this.averagePartySize,
    required this.averageReservationDuration,
    required this.customerSegments,
    required this.popularTimeSlots,
    required this.reservationTrends,
    required this.revenueTrends,
    required this.tableOccupancy,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    // Adapter pour la structure de l'API backend
    final overview = json['overview'] ?? {};
    final trends = json['trends'] ?? {};
    final performance = json['performance'] ?? {};
    
    return DashboardMetricsModel(
      todayReservations: overview['todayReservations'] ?? 0,
      confirmedReservations: overview['confirmedReservations'] ?? 0,
      pendingReservations: overview['pendingReservations'] ?? 0,
      cancelledReservations: overview['cancelledReservations'] ?? 0,
      totalTables: overview['totalTables'] ?? 0,
      occupiedTables: overview['occupiedTables'] ?? 0,
      todayRevenue: (overview['todayRevenue'] ?? 0).toDouble(),
      totalRevenue: (overview['totalRevenue'] ?? 0).toDouble(),
      averageRevenue: performance['averageRevenuePerReservation']?.toDouble() ?? 0.0,
      occupancyRate: (overview['occupancyRate'] ?? 0).toDouble(),
      totalReservations: overview['totalReservations'] ?? 0,
      totalCustomers: trends['weeklyReservations'] ?? 0, // Approximation
      newCustomers: 0, // Non disponible dans l'API actuelle
      averagePartySize: (overview['averagePartySize'] ?? 0).toDouble(),
      averageReservationDuration: 2.0, // Valeur par défaut
      customerSegments: [], // À implémenter selon les besoins
      popularTimeSlots: (json['popularTimeSlots'] as List<dynamic>?)
          ?.map((e) => PopularTimeSlot.fromJson(e))
          .toList() ?? [],
      reservationTrends: (trends['dailyTrends'] as List<dynamic>?)
          ?.map((e) => ReservationTrend.fromJson(e))
          .toList() ?? [],
      revenueTrends: (trends['dailyTrends'] as List<dynamic>?)
          ?.map((e) => RevenueTrend.fromJson(e))
          .toList() ?? [],
      tableOccupancy: [], // À implémenter selon les besoins
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayReservations': todayReservations,
      'confirmedReservations': confirmedReservations,
      'pendingReservations': pendingReservations,
      'cancelledReservations': cancelledReservations,
      'totalTables': totalTables,
      'occupiedTables': occupiedTables,
      'todayRevenue': todayRevenue,
      'totalRevenue': totalRevenue,
      'averageRevenue': averageRevenue,
      'occupancyRate': occupancyRate,
      'totalReservations': totalReservations,
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'averagePartySize': averagePartySize,
      'averageReservationDuration': averageReservationDuration,
      'customerSegments': customerSegments.map((e) => e.toJson()).toList(),
      'popularTimeSlots': popularTimeSlots.map((e) => e.toJson()).toList(),
      'reservationTrends': reservationTrends.map((e) => e.toJson()).toList(),
      'revenueTrends': revenueTrends.map((e) => e.toJson()).toList(),
      'tableOccupancy': tableOccupancy.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerSegment {
  final String segment;
  final int count;
  final double percentage;

  const CustomerSegment({
    required this.segment,
    required this.count,
    required this.percentage,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      segment: json['segment'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segment': segment,
      'count': count,
      'percentage': percentage,
    };
  }
}

class PopularTimeSlot {
  final String time;
  final int count;
  final double percentage;

  const PopularTimeSlot({
    required this.time,
    required this.count,
    required this.percentage,
  });

  factory PopularTimeSlot.fromJson(Map<String, dynamic> json) {
    return PopularTimeSlot(
      time: json['time'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'count': count,
      'percentage': percentage,
    };
  }
}

class ReservationTrend {
  final String date;
  final int count;
  final double revenue;

  const ReservationTrend({
    required this.date,
    required this.count,
    required this.revenue,
  });

  factory ReservationTrend.fromJson(Map<String, dynamic> json) {
    return ReservationTrend(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
      'revenue': revenue,
    };
  }
}

class RevenueTrend {
  final String date;
  final double amount;
  final double growth;

  const RevenueTrend({
    required this.date,
    required this.amount,
    required this.growth,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      growth: (json['growth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'growth': growth,
    };
  }
}

class TableOccupancy {
  final String tableId;
  final bool isOccupied;
  final String? reservationId;
  final DateTime? occupiedUntil;

  const TableOccupancy({
    required this.tableId,
    required this.isOccupied,
    this.reservationId,
    this.occupiedUntil,
  });

  factory TableOccupancy.fromJson(Map<String, dynamic> json) {
    return TableOccupancy(
      tableId: json['tableId'] ?? '',
      isOccupied: json['isOccupied'] ?? false,
      reservationId: json['reservationId'],
      occupiedUntil: json['occupiedUntil'] != null 
          ? DateTime.parse(json['occupiedUntil']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'isOccupied': isOccupied,
      'reservationId': reservationId,
      'occupiedUntil': occupiedUntil?.toIso8601String(),
    };
  }
}
