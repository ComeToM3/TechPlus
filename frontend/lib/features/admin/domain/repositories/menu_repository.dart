import '../entities/menu_entity.dart';

/// Repository abstrait pour la gestion du menu
abstract class MenuRepository {
  /// Articles de menu
  /// Récupérer tous les articles
  Future<List<MenuItemEntity>> getAllMenuItems();

  /// Récupérer un article par ID
  Future<MenuItemEntity?> getMenuItemById(String id);

  /// Récupérer les articles par catégorie
  Future<List<MenuItemEntity>> getMenuItemsByCategory(String category);

  /// Récupérer les articles disponibles
  Future<List<MenuItemEntity>> getAvailableMenuItems();

  /// Créer un nouvel article
  Future<MenuItemEntity> createMenuItem(CreateMenuItemRequest request);

  /// Mettre à jour un article
  Future<MenuItemEntity> updateMenuItem(String id, UpdateMenuItemRequest request);

  /// Supprimer un article
  Future<void> deleteMenuItem(String id);

  /// Changer la disponibilité d'un article
  Future<MenuItemEntity> toggleMenuItemAvailability(String id);

  /// Rechercher des articles
  Future<List<MenuItemEntity>> searchMenuItems(String query);

  /// Récupérer les articles par allergènes
  Future<List<MenuItemEntity>> getMenuItemsByAllergens(List<String> allergens);

  /// Catégories
  /// Récupérer toutes les catégories
  Future<List<MenuCategoryEntity>> getAllCategories();

  /// Récupérer une catégorie par ID
  Future<MenuCategoryEntity?> getCategoryById(String id);

  /// Créer une nouvelle catégorie
  Future<MenuCategoryEntity> createCategory(CreateCategoryRequest request);

  /// Mettre à jour une catégorie
  Future<MenuCategoryEntity> updateCategory(String id, UpdateCategoryRequest request);

  /// Supprimer une catégorie
  Future<void> deleteCategory(String id);

  /// Réorganiser les catégories
  Future<void> reorderCategories(List<String> categoryIds);

  /// Upload d'images
  /// Uploader une image
  Future<ImageUploadResponse> uploadImage(ImageUploadRequest request);

  /// Supprimer une image
  Future<void> deleteImage(String imageUrl);

  /// Optimiser une image
  Future<String> optimizeImage(String imageUrl, {int? width, int? height, int? quality});

  /// Statistiques
  /// Récupérer les statistiques du menu
  Future<MenuStats> getMenuStats();

  /// Récupérer les articles les plus populaires
  Future<List<PopularMenuItem>> getPopularMenuItems({int limit = 10});

  /// Récupérer les catégories les plus populaires
  Future<List<PopularCategory>> getPopularCategories({int limit = 5});
}

/// Modèle pour les statistiques du menu
class MenuStats {
  final int totalItems;
  final int availableItems;
  final int unavailableItems;
  final int totalCategories;
  final double averagePrice;
  final double totalRevenue;
  final int totalOrders;

  const MenuStats({
    required this.totalItems,
    required this.availableItems,
    required this.unavailableItems,
    required this.totalCategories,
    required this.averagePrice,
    required this.totalRevenue,
    required this.totalOrders,
  });

  factory MenuStats.fromJson(Map<String, dynamic> json) {
    return MenuStats(
      totalItems: json['totalItems'] as int,
      availableItems: json['availableItems'] as int,
      unavailableItems: json['unavailableItems'] as int,
      totalCategories: json['totalCategories'] as int,
      averagePrice: (json['averagePrice'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'availableItems': availableItems,
      'unavailableItems': unavailableItems,
      'totalCategories': totalCategories,
      'averagePrice': averagePrice,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
    };
  }
}

/// Modèle pour les articles populaires
class PopularMenuItem {
  final String itemId;
  final String name;
  final int orderCount;
  final double revenue;
  final double popularityScore;

  const PopularMenuItem({
    required this.itemId,
    required this.name,
    required this.orderCount,
    required this.revenue,
    required this.popularityScore,
  });

  factory PopularMenuItem.fromJson(Map<String, dynamic> json) {
    return PopularMenuItem(
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      orderCount: json['orderCount'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      popularityScore: (json['popularityScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'orderCount': orderCount,
      'revenue': revenue,
      'popularityScore': popularityScore,
    };
  }
}

/// Modèle pour les catégories populaires
class PopularCategory {
  final String categoryId;
  final String name;
  final int itemCount;
  final int orderCount;
  final double revenue;

  const PopularCategory({
    required this.categoryId,
    required this.name,
    required this.itemCount,
    required this.orderCount,
    required this.revenue,
  });

  factory PopularCategory.fromJson(Map<String, dynamic> json) {
    return PopularCategory(
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      itemCount: json['itemCount'] as int,
      orderCount: json['orderCount'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'itemCount': itemCount,
      'orderCount': orderCount,
      'revenue': revenue,
    };
  }
}

