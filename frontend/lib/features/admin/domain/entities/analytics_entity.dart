/// Enum pour les plages de temps
enum TimeRange {
  today,
  yesterday,
  last7Days,
  last30Days,
  last90Days,
  lastYear,
  custom,
}

/// Entité pour les métriques d'analytics
class AnalyticsMetrics {
  final String id;
  final DateTime date;
  final String metric;
  final double value;
  final String? category;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const AnalyticsMetrics({
    required this.id,
    required this.date,
    required this.metric,
    required this.value,
    this.category,
    this.metadata,
    required this.createdAt,
  });

  /// Crée une copie avec des valeurs modifiées
  AnalyticsMetrics copyWith({
    String? id,
    DateTime? date,
    String? metric,
    double? value,
    String? category,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return AnalyticsMetrics(
      id: id ?? this.id,
      date: date ?? this.date,
      metric: metric ?? this.metric,
      value: value ?? this.value,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'metric': metric,
      'value': value,
      'category': category,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory AnalyticsMetrics.fromJson(Map<String, dynamic> json) {
    return AnalyticsMetrics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      metric: json['metric'] as String,
      value: (json['value'] as num).toDouble(),
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Entité pour les KPIs principaux
class MainKPIs {
  final double totalReservations;
  final double totalRevenue;
  final double averagePartySize;
  final double averageOrderValue;
  final double occupancyRate;
  final double cancellationRate;
  final double noShowRate;
  final double customerSatisfaction;
  final double averageReservationValue;
  final int totalCustomers;
  final int activeTables;

  const MainKPIs({
    required this.totalReservations,
    required this.totalRevenue,
    required this.averagePartySize,
    required this.averageOrderValue,
    required this.occupancyRate,
    required this.cancellationRate,
    required this.noShowRate,
    required this.customerSatisfaction,
    required this.averageReservationValue,
    required this.totalCustomers,
    required this.activeTables,
  });

  /// Crée une copie avec des valeurs modifiées
  MainKPIs copyWith({
    double? totalReservations,
    double? totalRevenue,
    double? averagePartySize,
    double? averageOrderValue,
    double? occupancyRate,
    double? cancellationRate,
    double? noShowRate,
    double? customerSatisfaction,
    double? averageReservationValue,
    int? totalCustomers,
    int? activeTables,
  }) {
    return MainKPIs(
      totalReservations: totalReservations ?? this.totalReservations,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averagePartySize: averagePartySize ?? this.averagePartySize,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      occupancyRate: occupancyRate ?? this.occupancyRate,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      noShowRate: noShowRate ?? this.noShowRate,
      customerSatisfaction: customerSatisfaction ?? this.customerSatisfaction,
      averageReservationValue: averageReservationValue ?? this.averageReservationValue,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      activeTables: activeTables ?? this.activeTables,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'totalReservations': totalReservations,
      'totalRevenue': totalRevenue,
      'averagePartySize': averagePartySize,
      'averageOrderValue': averageOrderValue,
      'occupancyRate': occupancyRate,
      'cancellationRate': cancellationRate,
      'noShowRate': noShowRate,
      'customerSatisfaction': customerSatisfaction,
      'averageReservationValue': averageReservationValue,
      'totalCustomers': totalCustomers,
      'activeTables': activeTables,
    };
  }

  /// Crée depuis un Map
  factory MainKPIs.fromJson(Map<String, dynamic> json) {
    return MainKPIs(
      totalReservations: (json['totalReservations'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averagePartySize: (json['averagePartySize'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      occupancyRate: (json['occupancyRate'] as num).toDouble(),
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      noShowRate: (json['noShowRate'] as num).toDouble(),
      customerSatisfaction: (json['customerSatisfaction'] as num).toDouble(),
      averageReservationValue: (json['averageReservationValue'] as num).toDouble(),
      totalCustomers: json['totalCustomers'] as int,
      activeTables: json['activeTables'] as int,
    );
  }
}

/// Entité pour les données de graphiques
class ChartData {
  final String label;
  final double value;
  final String? color;
  final Map<String, dynamic>? metadata;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
    this.metadata,
  });

  /// Crée une copie avec des valeurs modifiées
  ChartData copyWith({
    String? label,
    double? value,
    String? color,
    Map<String, dynamic>? metadata,
  }) {
    return ChartData(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color,
      'metadata': metadata,
    };
  }

  /// Crée depuis un Map
  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: json['color'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Entité pour les comparaisons
class ComparisonData {
  final String period;
  final double value;
  final double currentValue;
  final double previousValue;
  final double changePercentage;
  final String trend; // 'up', 'down', 'stable'
  final String description;

  const ComparisonData({
    required this.period,
    required this.value,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.trend,
    required this.description,
  });

  /// Crée une copie avec des valeurs modifiées
  ComparisonData copyWith({
    String? period,
    double? value,
    double? currentValue,
    double? previousValue,
    double? changePercentage,
    String? trend,
    String? description,
  }) {
    return ComparisonData(
      period: period ?? this.period,
      value: value ?? this.value,
      currentValue: currentValue ?? this.currentValue,
      previousValue: previousValue ?? this.previousValue,
      changePercentage: changePercentage ?? this.changePercentage,
      trend: trend ?? this.trend,
      description: description ?? this.description,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'value': value,
      'currentValue': currentValue,
      'previousValue': previousValue,
      'changePercentage': changePercentage,
      'trend': trend,
      'description': description,
    };
  }

  /// Crée depuis un Map
  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    return ComparisonData(
      period: json['period'] as String,
      value: (json['value'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      trend: json['trend'] as String,
      description: json['description'] as String,
    );
  }
}

/// Entité pour les prédictions
class PredictionData {
  final String metric;
  final String period;
  final double predictedValue;
  final List<PredictionPoint> predictions;
  final double confidence;
  final String methodology;
  final DateTime generatedAt;

  const PredictionData({
    required this.metric,
    required this.period,
    required this.predictedValue,
    required this.predictions,
    required this.confidence,
    required this.methodology,
    required this.generatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  PredictionData copyWith({
    String? metric,
    String? period,
    double? predictedValue,
    List<PredictionPoint>? predictions,
    double? confidence,
    String? methodology,
    DateTime? generatedAt,
  }) {
    return PredictionData(
      metric: metric ?? this.metric,
      period: period ?? this.period,
      predictedValue: predictedValue ?? this.predictedValue,
      predictions: predictions ?? this.predictions,
      confidence: confidence ?? this.confidence,
      methodology: methodology ?? this.methodology,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'period': period,
      'predictedValue': predictedValue,
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'confidence': confidence,
      'methodology': methodology,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      metric: json['metric'] as String,
      period: json['period'] as String,
      predictedValue: (json['predictedValue'] as num).toDouble(),
      predictions: (json['predictions'] as List)
          .map((p) => PredictionPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      methodology: json['methodology'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

/// Entité pour un point de prédiction
class PredictionPoint {
  final DateTime date;
  final double value;
  final double? minValue;
  final double? maxValue;
  final String? description;

  const PredictionPoint({
    required this.date,
    required this.value,
    this.minValue,
    this.maxValue,
    this.description,
  });

  /// Crée une copie avec des valeurs modifiées
  PredictionPoint copyWith({
    DateTime? date,
    double? value,
    double? minValue,
    double? maxValue,
    String? description,
  }) {
    return PredictionPoint(
      date: date ?? this.date,
      value: value ?? this.value,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      description: description ?? this.description,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'minValue': minValue,
      'maxValue': maxValue,
      'description': description,
    };
  }

  /// Crée depuis un Map
  factory PredictionPoint.fromJson(Map<String, dynamic> json) {
    return PredictionPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      minValue: json['minValue'] != null ? (json['minValue'] as num).toDouble() : null,
      maxValue: json['maxValue'] != null ? (json['maxValue'] as num).toDouble() : null,
      description: json['description'] as String?,
    );
  }
}

/// Entité pour les filtres d'analytics
class AnalyticsFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeRange? timeRange;
  final String? metric;
  final String? category;
  final String? period; // 'daily', 'weekly', 'monthly', 'yearly'
  final String? groupBy;
  final List<String>? tableIds;
  final String? customerSegment;

  const AnalyticsFilters({
    this.startDate,
    this.endDate,
    this.timeRange,
    this.metric,
    this.category,
    this.period,
    this.groupBy,
    this.tableIds,
    this.customerSegment,
  });

  /// Crée une copie avec des valeurs modifiées
  AnalyticsFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    TimeRange? timeRange,
    String? metric,
    String? category,
    String? period,
    String? groupBy,
    List<String>? tableIds,
    String? customerSegment,
  }) {
    return AnalyticsFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timeRange: timeRange ?? this.timeRange,
      metric: metric ?? this.metric,
      category: category ?? this.category,
      period: period ?? this.period,
      groupBy: groupBy ?? this.groupBy,
      tableIds: tableIds ?? this.tableIds,
      customerSegment: customerSegment ?? this.customerSegment,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'timeRange': timeRange?.name,
      'metric': metric,
      'category': category,
      'period': period,
      'groupBy': groupBy,
      'tableIds': tableIds,
      'customerSegment': customerSegment,
    };
  }

  /// Crée depuis un Map
  factory AnalyticsFilters.fromJson(Map<String, dynamic> json) {
    return AnalyticsFilters(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      timeRange: json['timeRange'] != null ? TimeRange.values.firstWhere((e) => e.name == json['timeRange']) : null,
      metric: json['metric'] as String?,
      category: json['category'] as String?,
      period: json['period'] as String?,
      groupBy: json['groupBy'] as String?,
      tableIds: json['tableIds'] != null ? List<String>.from(json['tableIds'] as List) : null,
      customerSegment: json['customerSegment'] as String?,
    );
  }
}
