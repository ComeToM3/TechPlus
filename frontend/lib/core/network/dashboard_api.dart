import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// API pour les métriques du dashboard
class DashboardApi {
  final Dio _dio;
  final String _baseUrl;

  DashboardApi(this._dio, this._baseUrl);

  /// Obtenir les métriques générales du dashboard
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      final response = await _dio.get('$_baseUrl/api/dashboard/metrics');

      if (response.statusCode == 200) {
        return DashboardMetrics.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch dashboard metrics');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching metrics: $e');
    }
  }

  /// Obtenir les métriques en temps réel
  Future<RealtimeMetrics> getRealtimeMetrics() async {
    try {
      final response = await _dio.get('$_baseUrl/api/dashboard/realtime');

      if (response.statusCode == 200) {
        return RealtimeMetrics.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch realtime metrics');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching realtime metrics: $e');
    }
  }

  /// Obtenir les tendances de réservations
  Future<List<ReservationTrend>> getReservationTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/dashboard/trends/reservations',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          if (period != null) 'period': period,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> trendsData = response.data['trends'];
        return trendsData.map((trend) => ReservationTrend.fromJson(trend)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les tendances de revenus
  Future<List<RevenueTrend>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/dashboard/trends/revenue',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          if (period != null) 'period': period,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> trendsData = response.data['trends'];
        return trendsData.map((trend) => RevenueTrend.fromJson(trend)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les tables les plus populaires
  Future<List<TopTableData>> getTopTables() async {
    try {
      final response = await _dio.get('$_baseUrl/api/dashboard/top-tables');

      if (response.statusCode == 200) {
        final List<dynamic> tablesData = response.data['tables'];
        return tablesData.map((table) => TopTableData.fromJson(table)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir l'occupation des tables
  Future<List<TableOccupancy>> getTableOccupancy() async {
    try {
      final response = await _dio.get('$_baseUrl/api/dashboard/table-occupancy');

      if (response.statusCode == 200) {
        final List<dynamic> occupancyData = response.data['occupancy'];
        return occupancyData.map((occupancy) => TableOccupancy.fromJson(occupancy)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les statistiques par période
  Future<PeriodStats> getPeriodStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/dashboard/period-stats',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return PeriodStats.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch period stats');
      }
    } catch (e) {
      throw Exception('Error fetching period stats: $e');
    }
  }
}

/// Modèle pour les métriques du dashboard
class DashboardMetrics {
  final int totalReservations;
  final int confirmedReservations;
  final int pendingReservations;
  final int cancelledReservations;
  final double totalRevenue;
  final double averageRevenue;
  final int totalClients;
  final int newClients;
  final double occupancyRate;
  final int totalTables;
  final int availableTables;

  const DashboardMetrics({
    required this.totalReservations,
    required this.confirmedReservations,
    required this.pendingReservations,
    required this.cancelledReservations,
    required this.totalRevenue,
    required this.averageRevenue,
    required this.totalClients,
    required this.newClients,
    required this.occupancyRate,
    required this.totalTables,
    required this.availableTables,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalReservations: json['totalReservations'] ?? 0,
      confirmedReservations: json['confirmedReservations'] ?? 0,
      pendingReservations: json['pendingReservations'] ?? 0,
      cancelledReservations: json['cancelledReservations'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageRevenue: (json['averageRevenue'] ?? 0).toDouble(),
      totalClients: json['totalClients'] ?? 0,
      newClients: json['newClients'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      totalTables: json['totalTables'] ?? 0,
      availableTables: json['availableTables'] ?? 0,
    );
  }
}

/// Modèle pour les métriques en temps réel
class RealtimeMetrics {
  final int currentOccupancy;
  final int reservationsToday;
  final double revenueToday;
  final int activeReservations;
  final int waitingList;

  const RealtimeMetrics({
    required this.currentOccupancy,
    required this.reservationsToday,
    required this.revenueToday,
    required this.activeReservations,
    required this.waitingList,
  });

  factory RealtimeMetrics.fromJson(Map<String, dynamic> json) {
    return RealtimeMetrics(
      currentOccupancy: json['currentOccupancy'] ?? 0,
      reservationsToday: json['reservationsToday'] ?? 0,
      revenueToday: (json['revenueToday'] ?? 0).toDouble(),
      activeReservations: json['activeReservations'] ?? 0,
      waitingList: json['waitingList'] ?? 0,
    );
  }
}

/// Modèle pour les tendances de réservations
class ReservationTrend {
  final DateTime date;
  final int reservations;
  final double revenue;
  final int newClients;

  const ReservationTrend({
    required this.date,
    required this.reservations,
    required this.revenue,
    required this.newClients,
  });

  factory ReservationTrend.fromJson(Map<String, dynamic> json) {
    return ReservationTrend(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      reservations: json['reservations'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      newClients: json['newClients'] ?? 0,
    );
  }
}

/// Modèle pour les tendances de revenus
class RevenueTrend {
  final DateTime date;
  final double revenue;
  final double averageOrderValue;
  final int transactions;

  const RevenueTrend({
    required this.date,
    required this.revenue,
    required this.averageOrderValue,
    required this.transactions,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      revenue: (json['revenue'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      transactions: json['transactions'] ?? 0,
    );
  }
}

/// Modèle pour les données des tables populaires
class TopTableData {
  final String name;
  final int capacity;
  final int reservations;
  final double revenue;
  final double occupancyRate;

  const TopTableData({
    required this.name,
    required this.capacity,
    required this.reservations,
    required this.revenue,
    required this.occupancyRate,
  });

  factory TopTableData.fromJson(Map<String, dynamic> json) {
    return TopTableData(
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      reservations: json['reservations'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
    );
  }
}

/// Modèle pour l'occupation des tables
class TableOccupancy {
  final String tableId;
  final String tableName;
  final int capacity;
  final bool isOccupied;
  final String? currentReservationId;
  final DateTime? occupiedUntil;

  const TableOccupancy({
    required this.tableId,
    required this.tableName,
    required this.capacity,
    required this.isOccupied,
    this.currentReservationId,
    this.occupiedUntil,
  });

  factory TableOccupancy.fromJson(Map<String, dynamic> json) {
    return TableOccupancy(
      tableId: json['tableId'] ?? '',
      tableName: json['tableName'] ?? '',
      capacity: json['capacity'] ?? 0,
      isOccupied: json['isOccupied'] ?? false,
      currentReservationId: json['currentReservationId'],
      occupiedUntil: json['occupiedUntil'] != null 
          ? DateTime.parse(json['occupiedUntil'])
          : null,
    );
  }
}

/// Modèle pour les statistiques par période
class PeriodStats {
  final DateTime startDate;
  final DateTime endDate;
  final int totalReservations;
  final double totalRevenue;
  final int totalClients;
  final double averagePartySize;
  final double occupancyRate;

  const PeriodStats({
    required this.startDate,
    required this.endDate,
    required this.totalReservations,
    required this.totalRevenue,
    required this.totalClients,
    required this.averagePartySize,
    required this.occupancyRate,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      totalReservations: json['totalReservations'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalClients: json['totalClients'] ?? 0,
      averagePartySize: (json['averagePartySize'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
    );
  }
}
