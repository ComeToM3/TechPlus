import 'table_entity.dart';

/// Entité pour le plan du restaurant
class RestaurantLayout {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final List<TableEntity> tables;
  final List<TablePosition> tablePositions;
  final LayoutDimensions dimensions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestaurantLayout({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.tables,
    required this.tablePositions,
    required this.dimensions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  RestaurantLayout copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    List<TableEntity>? tables,
    List<TablePosition>? tablePositions,
    LayoutDimensions? dimensions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantLayout(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      tables: tables ?? this.tables,
      tablePositions: tablePositions ?? this.tablePositions,
      dimensions: dimensions ?? this.dimensions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'tables': tables.map((table) => table.toJson()).toList(),
      'tablePositions': tablePositions.map((pos) => pos.toJson()).toList(),
      'dimensions': dimensions.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory RestaurantLayout.fromJson(Map<String, dynamic> json) {
    return RestaurantLayout(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tables: (json['tables'] as List)
          .map((table) => TableEntity.fromJson(table as Map<String, dynamic>))
          .toList(),
      tablePositions: (json['tablePositions'] as List)
          .map((pos) => TablePosition.fromJson(pos as Map<String, dynamic>))
          .toList(),
      dimensions: LayoutDimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Crée depuis une liste de tables
  factory RestaurantLayout.fromTables(List<TableEntity> tables, {
    String? restaurantId,
    String? name,
  }) {
    return RestaurantLayout(
      id: 'layout_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId ?? 'restaurant_1',
      name: name ?? 'Plan du restaurant',
      description: 'Plan du restaurant généré automatiquement',
      tables: tables,
      tablePositions: tables.map((table) => TablePosition(
        tableId: table.id,
        x: 0.0,
        y: 0.0,
        width: 60.0,
        height: 40.0,
      )).toList(),
      dimensions: const LayoutDimensions(
        width: 800.0,
        height: 600.0,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Position d'une table dans le plan
class TablePosition {
  final String tableId;
  final double x;
  final double y;
  final double width;
  final double height;

  const TablePosition({
    required this.tableId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  factory TablePosition.fromJson(Map<String, dynamic> json) {
    return TablePosition(
      tableId: json['tableId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }
}

/// Dimensions du plan du restaurant
class LayoutDimensions {
  final double width;
  final double height;

  const LayoutDimensions({
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  factory LayoutDimensions.fromJson(Map<String, dynamic> json) {
    return LayoutDimensions(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }
}
