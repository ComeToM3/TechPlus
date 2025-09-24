/// Entité représentant une table de restaurant
class TableEntity {
  final String id;
  final int number;
  final int capacity;
  final String? position;
  final bool isActive;
  final String restaurantId;
  final TableStatus status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TableEntity({
    required this.id,
    required this.number,
    required this.capacity,
    this.position,
    required this.isActive,
    required this.restaurantId,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  TableEntity copyWith({
    String? id,
    int? number,
    int? capacity,
    String? position,
    bool? isActive,
    String? restaurantId,
    TableStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      restaurantId: restaurantId ?? this.restaurantId,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'capacity': capacity,
      'position': position,
      'isActive': isActive,
      'restaurantId': restaurantId,
      'status': status.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['id'] as String,
      number: json['number'] as int,
      capacity: json['capacity'] as int,
      position: json['position'] as String?,
      isActive: json['isActive'] as bool,
      restaurantId: json['restaurantId'] as String,
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Statut d'une table
enum TableStatus {
  available,
  occupied,
  reserved,
  maintenance,
  outOfOrder,
}

/// Extension pour les statuts de table
extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Disponible';
      case TableStatus.occupied:
        return 'Occupée';
      case TableStatus.reserved:
        return 'Réservée';
      case TableStatus.maintenance:
        return 'Maintenance';
      case TableStatus.outOfOrder:
        return 'Hors service';
    }
  }

  String get englishDisplayName {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.maintenance:
        return 'Maintenance';
      case TableStatus.outOfOrder:
        return 'Out of Order';
    }
  }

  String get color {
    switch (this) {
      case TableStatus.available:
        return 'green';
      case TableStatus.occupied:
        return 'red';
      case TableStatus.reserved:
        return 'orange';
      case TableStatus.maintenance:
        return 'blue';
      case TableStatus.outOfOrder:
        return 'grey';
    }
  }

  String get icon {
    switch (this) {
      case TableStatus.available:
        return 'check_circle';
      case TableStatus.occupied:
        return 'person';
      case TableStatus.reserved:
        return 'schedule';
      case TableStatus.maintenance:
        return 'build';
      case TableStatus.outOfOrder:
        return 'error';
    }
  }
}

/// Modèle pour la création d'une table
class CreateTableRequest {
  final int number;
  final int capacity;
  final String? position;
  final String? description;

  const CreateTableRequest({
    required this.number,
    required this.capacity,
    this.position,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'capacity': capacity,
      'position': position,
      'description': description,
    };
  }
}

/// Modèle pour la mise à jour d'une table
class UpdateTableRequest {
  final int? number;
  final int? capacity;
  final String? position;
  final bool? isActive;
  final TableStatus? status;
  final String? description;

  const UpdateTableRequest({
    this.number,
    this.capacity,
    this.position,
    this.isActive,
    this.status,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (number != null) 'number': number,
      if (capacity != null) 'capacity': capacity,
      if (position != null) 'position': position,
      if (isActive != null) 'isActive': isActive,
      if (status != null) 'status': status!.name,
      if (description != null) 'description': description,
    };
  }
}

/// Modèle pour les statistiques d'une table
class TableStats {
  final String tableId;
  final int totalReservations;
  final double averageOccupancy;
  final double revenue;
  final int totalGuests;
  final DateTime lastReservation;

  const TableStats({
    required this.tableId,
    required this.totalReservations,
    required this.averageOccupancy,
    required this.revenue,
    required this.totalGuests,
    required this.lastReservation,
  });

  factory TableStats.fromJson(Map<String, dynamic> json) {
    return TableStats(
      tableId: json['tableId'] as String,
      totalReservations: json['totalReservations'] as int,
      averageOccupancy: (json['averageOccupancy'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      totalGuests: json['totalGuests'] as int,
      lastReservation: DateTime.parse(json['lastReservation'] as String),
    );
  }
}

