import 'package:equatable/equatable.dart';

/// Enum pour les types de rapports
enum ReportType {
  daily,
  weekly,
  monthly,
  custom,
}

/// Enum pour les formats d'export
enum ExportFormat {
  pdf,
  excel,
  csv,
}

/// Entité pour les filtres de rapport
class ReportFilters extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportType reportType;
  final List<String>? statuses;
  final List<String>? tables;
  final bool includeCancelled;
  final bool includeNoShow;

  const ReportFilters({
    this.startDate,
    this.endDate,
    this.reportType = ReportType.daily,
    this.statuses,
    this.tables,
    this.includeCancelled = true,
    this.includeNoShow = true,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        reportType,
        statuses,
        tables,
        includeCancelled,
        includeNoShow,
      ];

  ReportFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    ReportType? reportType,
    List<String>? statuses,
    List<String>? tables,
    bool? includeCancelled,
    bool? includeNoShow,
  }) {
    return ReportFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reportType: reportType ?? this.reportType,
      statuses: statuses ?? this.statuses,
      tables: tables ?? this.tables,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      includeNoShow: includeNoShow ?? this.includeNoShow,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reportType': reportType.name,
      'statuses': statuses,
      'tables': tables,
      'includeCancelled': includeCancelled,
      'includeNoShow': includeNoShow,
    };
  }

  factory ReportFilters.fromJson(Map<String, dynamic> json) {
    return ReportFilters(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      reportType: ReportType.values.firstWhere(
        (e) => e.name == json['reportType'],
        orElse: () => ReportType.daily,
      ),
      statuses: json['statuses'] != null ? List<String>.from(json['statuses']) : null,
      tables: json['tables'] != null ? List<String>.from(json['tables']) : null,
      includeCancelled: json['includeCancelled'] ?? true,
      includeNoShow: json['includeNoShow'] ?? true,
    );
  }
}

/// Entité pour les métriques de rapport
class ReportMetrics extends Equatable {
  final int totalReservations;
  final int confirmedReservations;
  final int cancelledReservations;
  final int noShowReservations;
  final double totalRevenue;
  final double averagePartySize;
  final double occupancyRate;
  final double cancellationRate;
  final double noShowRate;
  final int totalGuests;
  final double averageReservationValue;

  const ReportMetrics({
    required this.totalReservations,
    required this.confirmedReservations,
    required this.cancelledReservations,
    required this.noShowReservations,
    required this.totalRevenue,
    required this.averagePartySize,
    required this.occupancyRate,
    required this.cancellationRate,
    required this.noShowRate,
    required this.totalGuests,
    required this.averageReservationValue,
  });

  @override
  List<Object> get props => [
        totalReservations,
        confirmedReservations,
        cancelledReservations,
        noShowReservations,
        totalRevenue,
        averagePartySize,
        occupancyRate,
        cancellationRate,
        noShowRate,
        totalGuests,
        averageReservationValue,
      ];

  Map<String, dynamic> toJson() {
    return {
      'totalReservations': totalReservations,
      'confirmedReservations': confirmedReservations,
      'cancelledReservations': cancelledReservations,
      'noShowReservations': noShowReservations,
      'totalRevenue': totalRevenue,
      'averagePartySize': averagePartySize,
      'occupancyRate': occupancyRate,
      'cancellationRate': cancellationRate,
      'noShowRate': noShowRate,
      'totalGuests': totalGuests,
      'averageReservationValue': averageReservationValue,
    };
  }

  factory ReportMetrics.fromJson(Map<String, dynamic> json) {
    return ReportMetrics(
      totalReservations: json['totalReservations'] ?? 0,
      confirmedReservations: json['confirmedReservations'] ?? 0,
      cancelledReservations: json['cancelledReservations'] ?? 0,
      noShowReservations: json['noShowReservations'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averagePartySize: (json['averagePartySize'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      cancellationRate: (json['cancellationRate'] ?? 0).toDouble(),
      noShowRate: (json['noShowRate'] ?? 0).toDouble(),
      totalGuests: json['totalGuests'] ?? 0,
      averageReservationValue: (json['averageReservationValue'] ?? 0).toDouble(),
    );
  }
}

/// Entité pour les données de rapport par période
class ReportPeriodData extends Equatable {
  final DateTime date;
  final int reservations;
  final double revenue;
  final double occupancyRate;
  final int guests;

  const ReportPeriodData({
    required this.date,
    required this.reservations,
    required this.revenue,
    required this.occupancyRate,
    required this.guests,
  });

  @override
  List<Object> get props => [date, reservations, revenue, occupancyRate, guests];

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reservations': reservations,
      'revenue': revenue,
      'occupancyRate': occupancyRate,
      'guests': guests,
    };
  }

  factory ReportPeriodData.fromJson(Map<String, dynamic> json) {
    return ReportPeriodData(
      date: DateTime.parse(json['date']),
      reservations: json['reservations'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      guests: json['guests'] ?? 0,
    );
  }
}

/// Entité pour les données de rapport par table
class ReportTableData extends Equatable {
  final String tableNumber;
  final int reservations;
  final double revenue;
  final double occupancyRate;
  final int totalGuests;

  const ReportTableData({
    required this.tableNumber,
    required this.reservations,
    required this.revenue,
    required this.occupancyRate,
    required this.totalGuests,
  });

  @override
  List<Object> get props => [tableNumber, reservations, revenue, occupancyRate, totalGuests];

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'reservations': reservations,
      'revenue': revenue,
      'occupancyRate': occupancyRate,
      'totalGuests': totalGuests,
    };
  }

  factory ReportTableData.fromJson(Map<String, dynamic> json) {
    return ReportTableData(
      tableNumber: json['tableNumber'] ?? '',
      reservations: json['reservations'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      totalGuests: json['totalGuests'] ?? 0,
    );
  }
}

/// Entité principale pour un rapport
class Report extends Equatable {
  final String id;
  final String title;
  final ReportType type;
  final DateTime generatedAt;
  final ReportFilters filters;
  final ReportMetrics metrics;
  final List<ReportPeriodData> periodData;
  final List<ReportTableData> tableData;
  final String? notes;

  const Report({
    required this.id,
    required this.title,
    required this.type,
    required this.generatedAt,
    required this.filters,
    required this.metrics,
    required this.periodData,
    required this.tableData,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        generatedAt,
        filters,
        metrics,
        periodData,
        tableData,
        notes,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'generatedAt': generatedAt.toIso8601String(),
      'filters': filters.toJson(),
      'metrics': metrics.toJson(),
      'periodData': periodData.map((e) => e.toJson()).toList(),
      'tableData': tableData.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.daily,
      ),
      generatedAt: DateTime.parse(json['generatedAt']),
      filters: ReportFilters.fromJson(json['filters'] ?? {}),
      metrics: ReportMetrics.fromJson(json['metrics'] ?? {}),
      periodData: (json['periodData'] as List<dynamic>?)
              ?.map((e) => ReportPeriodData.fromJson(e))
              .toList() ??
          [],
      tableData: (json['tableData'] as List<dynamic>?)
              ?.map((e) => ReportTableData.fromJson(e))
              .toList() ??
          [],
      notes: json['notes'],
    );
  }
}

/// Entité pour les options d'export
class ExportOptions extends Equatable {
  final ExportFormat format;
  final bool includeCharts;
  final bool includeDetails;
  final bool includeMetrics;
  final String? customTitle;

  const ExportOptions({
    required this.format,
    this.includeCharts = true,
    this.includeDetails = true,
    this.includeMetrics = true,
    this.customTitle,
  });

  @override
  List<Object?> get props => [format, includeCharts, includeDetails, includeMetrics, customTitle];

  Map<String, dynamic> toJson() {
    return {
      'format': format.name,
      'includeCharts': includeCharts,
      'includeDetails': includeDetails,
      'includeMetrics': includeMetrics,
      'customTitle': customTitle,
    };
  }

  factory ExportOptions.fromJson(Map<String, dynamic> json) {
    return ExportOptions(
      format: ExportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ExportFormat.pdf,
      ),
      includeCharts: json['includeCharts'] ?? true,
      includeDetails: json['includeDetails'] ?? true,
      includeMetrics: json['includeMetrics'] ?? true,
      customTitle: json['customTitle'],
    );
  }
}

