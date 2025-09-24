import '../entities/table_entity.dart';

/// Repository abstrait pour la gestion des tables
abstract class TableRepository {
  /// Récupérer toutes les tables
  Future<List<TableEntity>> getAllTables();

  /// Récupérer une table par ID
  Future<TableEntity?> getTableById(String id);

  /// Récupérer les tables par statut
  Future<List<TableEntity>> getTablesByStatus(TableStatus status);

  /// Récupérer les tables disponibles
  Future<List<TableEntity>> getAvailableTables();

  /// Créer une nouvelle table
  Future<TableEntity> createTable(CreateTableRequest request);

  /// Mettre à jour une table
  Future<TableEntity> updateTable(String id, UpdateTableRequest request);

  /// Supprimer une table
  Future<void> deleteTable(String id);

  /// Changer le statut d'une table
  Future<TableEntity> updateTableStatus(String id, TableStatus status);

  /// Récupérer les statistiques d'une table
  Future<TableStats?> getTableStats(String id);

  /// Récupérer les statistiques de toutes les tables
  Future<List<TableStats>> getAllTableStats();

  /// Vérifier la disponibilité d'une table
  Future<bool> isTableAvailable(String id, DateTime date, String time);

  /// Récupérer les tables disponibles pour une date/heure
  Future<List<TableEntity>> getAvailableTablesForDateTime(DateTime date, String time, int partySize);

  /// Récupérer le plan du restaurant
  Future<RestaurantLayout> getRestaurantLayout();

  /// Mettre à jour le plan du restaurant
  Future<RestaurantLayout> updateRestaurantLayout(RestaurantLayout layout);
}

/// Modèle pour le plan du restaurant
class RestaurantLayout {
  final String id;
  final String name;
  final String description;
  final List<TablePosition> tablePositions;
  final LayoutDimensions dimensions;
  final DateTime updatedAt;

  const RestaurantLayout({
    required this.id,
    required this.name,
    required this.description,
    required this.tablePositions,
    required this.dimensions,
    required this.updatedAt,
  });

  factory RestaurantLayout.fromJson(Map<String, dynamic> json) {
    return RestaurantLayout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tablePositions: (json['tablePositions'] as List)
          .map((e) => TablePosition.fromJson(e as Map<String, dynamic>))
          .toList(),
      dimensions: LayoutDimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tablePositions': tablePositions.map((e) => e.toJson()).toList(),
      'dimensions': dimensions.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Position d'une table dans le plan
class TablePosition {
  final String tableId;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  const TablePosition({
    required this.tableId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  factory TablePosition.fromJson(Map<String, dynamic> json) {
    return TablePosition(
      tableId: json['tableId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
    };
  }
}

/// Dimensions du plan du restaurant
class LayoutDimensions {
  final double width;
  final double height;
  final String unit;

  const LayoutDimensions({
    required this.width,
    required this.height,
    this.unit = 'meters',
  });

  factory LayoutDimensions.fromJson(Map<String, dynamic> json) {
    return LayoutDimensions(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'meters',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'unit': unit,
    };
  }
}

