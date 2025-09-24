import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';
import '../datasources/menu_local_datasource.dart';

/// Implémentation du repository pour la gestion du menu
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _remoteDataSource;
  final MenuLocalDataSource _localDataSource;

  const MenuRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<List<MenuItemEntity>> getAllMenuItems() async {
    try {
      // Essayer d'abord le cache local
      final cachedItems = await _localDataSource.getCachedMenuItems();
      if (cachedItems != null && cachedItems.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateMenuItemsCacheInBackground();
        return cachedItems;
      }

      // Récupérer depuis l'API
      final items = await _remoteDataSource.getAllMenuItems();
      await _localDataSource.cacheMenuItems(items);
      return items;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedItems = await _localDataSource.getCachedMenuItems();
      if (cachedItems != null) {
        return cachedItems;
      }
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity?> getMenuItemById(String id) async {
    try {
      return await _remoteDataSource.getMenuItemById(id);
    } catch (e) {
      // Essayer de trouver dans le cache local
      final cachedItems = await _localDataSource.getCachedMenuItems();
      if (cachedItems != null) {
        try {
          return cachedItems.firstWhere((item) => item.id == id);
        } catch (e) {
          return null;
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<MenuItemEntity>> getMenuItemsByCategory(String category) async {
    try {
      return await _remoteDataSource.getMenuItemsByCategory(category);
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedItems = await _localDataSource.getCachedMenuItemsByCategory(category);
      if (cachedItems != null) {
        return cachedItems;
      }
      rethrow;
    }
  }

  @override
  Future<List<MenuItemEntity>> getAvailableMenuItems() async {
    try {
      return await _remoteDataSource.getAvailableMenuItems();
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedItems = await _localDataSource.getCachedAvailableMenuItems();
      if (cachedItems != null) {
        return cachedItems;
      }
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity> createMenuItem(CreateMenuItemRequest request) async {
    try {
      final newItem = await _remoteDataSource.createMenuItem(request);
      // Mettre à jour le cache local
      await _updateMenuItemsCacheAfterModification();
      return newItem;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity> updateMenuItem(String id, UpdateMenuItemRequest request) async {
    try {
      final updatedItem = await _remoteDataSource.updateMenuItem(id, request);
      // Mettre à jour le cache local
      await _updateMenuItemsCacheAfterModification();
      return updatedItem;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    try {
      await _remoteDataSource.deleteMenuItem(id);
      // Mettre à jour le cache local
      await _updateMenuItemsCacheAfterModification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity> toggleMenuItemAvailability(String id) async {
    try {
      final updatedItem = await _remoteDataSource.toggleMenuItemAvailability(id);
      // Mettre à jour le cache local
      await _updateMenuItemsCacheAfterModification();
      return updatedItem;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MenuItemEntity>> searchMenuItems(String query) async {
    try {
      return await _remoteDataSource.searchMenuItems(query);
    } catch (e) {
      // Essayer de rechercher dans le cache local
      final cachedItems = await _localDataSource.getCachedMenuItems();
      if (cachedItems != null) {
        return cachedItems.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
                 (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 item.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<MenuItemEntity>> getMenuItemsByAllergens(List<String> allergens) async {
    try {
      return await _remoteDataSource.getMenuItemsByAllergens(allergens);
    } catch (e) {
      // Essayer de filtrer dans le cache local
      final cachedItems = await _localDataSource.getCachedMenuItems();
      if (cachedItems != null) {
        return cachedItems.where((item) {
          return item.allergens.any((allergen) => allergens.contains(allergen));
        }).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<MenuCategoryEntity>> getAllCategories() async {
    try {
      // Essayer d'abord le cache local
      final cachedCategories = await _localDataSource.getCachedCategories();
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateCategoriesCacheInBackground();
        return cachedCategories;
      }

      // Récupérer depuis l'API
      final categories = await _remoteDataSource.getAllCategories();
      await _localDataSource.cacheCategories(categories);
      return categories;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedCategories = await _localDataSource.getCachedCategories();
      if (cachedCategories != null) {
        return cachedCategories;
      }
      rethrow;
    }
  }

  @override
  Future<MenuCategoryEntity?> getCategoryById(String id) async {
    try {
      return await _remoteDataSource.getCategoryById(id);
    } catch (e) {
      // Essayer de trouver dans le cache local
      final cachedCategories = await _localDataSource.getCachedCategories();
      if (cachedCategories != null) {
        try {
          return cachedCategories.firstWhere((category) => category.id == id);
        } catch (e) {
          return null;
        }
      }
      rethrow;
    }
  }

  @override
  Future<MenuCategoryEntity> createCategory(CreateCategoryRequest request) async {
    try {
      final newCategory = await _remoteDataSource.createCategory(request);
      // Mettre à jour le cache local
      await _updateCategoriesCacheAfterModification();
      return newCategory;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MenuCategoryEntity> updateCategory(String id, UpdateCategoryRequest request) async {
    try {
      final updatedCategory = await _remoteDataSource.updateCategory(id, request);
      // Mettre à jour le cache local
      await _updateCategoriesCacheAfterModification();
      return updatedCategory;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      // Mettre à jour le cache local
      await _updateCategoriesCacheAfterModification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      await _remoteDataSource.reorderCategories(categoryIds);
      // Mettre à jour le cache local
      await _updateCategoriesCacheAfterModification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ImageUploadResponse> uploadImage(ImageUploadRequest request) async {
    try {
      return await _remoteDataSource.uploadImage(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _remoteDataSource.deleteImage(imageUrl);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> optimizeImage(String imageUrl, {int? width, int? height, int? quality}) async {
    try {
      return await _remoteDataSource.optimizeImage(
        imageUrl,
        width: width,
        height: height,
        quality: quality,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MenuStats> getMenuStats() async {
    try {
      // Essayer d'abord le cache local
      final cachedStats = await _localDataSource.getCachedMenuStats();
      if (cachedStats != null) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updateStatsCacheInBackground();
        return cachedStats;
      }

      // Récupérer depuis l'API
      final stats = await _remoteDataSource.getMenuStats();
      await _localDataSource.cacheMenuStats(stats);
      return stats;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedStats = await _localDataSource.getCachedMenuStats();
      if (cachedStats != null) {
        return cachedStats;
      }
      rethrow;
    }
  }

  @override
  Future<List<PopularMenuItem>> getPopularMenuItems({int limit = 10}) async {
    try {
      // Essayer d'abord le cache local
      final cachedItems = await _localDataSource.getCachedPopularMenuItems();
      if (cachedItems != null && cachedItems.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updatePopularItemsCacheInBackground();
        return cachedItems.take(limit).toList();
      }

      // Récupérer depuis l'API
      final items = await _remoteDataSource.getPopularMenuItems(limit: limit);
      await _localDataSource.cachePopularMenuItems(items);
      return items;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedItems = await _localDataSource.getCachedPopularMenuItems();
      if (cachedItems != null) {
        return cachedItems.take(limit).toList();
      }
      rethrow;
    }
  }

  @override
  Future<List<PopularCategory>> getPopularCategories({int limit = 5}) async {
    try {
      // Essayer d'abord le cache local
      final cachedCategories = await _localDataSource.getCachedPopularCategories();
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        // Retourner le cache et mettre à jour en arrière-plan
        _updatePopularCategoriesCacheInBackground();
        return cachedCategories.take(limit).toList();
      }

      // Récupérer depuis l'API
      final categories = await _remoteDataSource.getPopularCategories(limit: limit);
      await _localDataSource.cachePopularCategories(categories);
      return categories;
    } catch (e) {
      // En cas d'erreur, essayer le cache local
      final cachedCategories = await _localDataSource.getCachedPopularCategories();
      if (cachedCategories != null) {
        return cachedCategories.take(limit).toList();
      }
      rethrow;
    }
  }

  /// Mettre à jour le cache des articles en arrière-plan
  void _updateMenuItemsCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final items = await _remoteDataSource.getAllMenuItems();
        await _localDataSource.cacheMenuItems(items);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache après modification des articles
  Future<void> _updateMenuItemsCacheAfterModification() async {
    try {
      final items = await _remoteDataSource.getAllMenuItems();
      await _localDataSource.cacheMenuItems(items);
    } catch (e) {
      // Ignore cache update errors
    }
  }

  /// Mettre à jour le cache des catégories en arrière-plan
  void _updateCategoriesCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final categories = await _remoteDataSource.getAllCategories();
        await _localDataSource.cacheCategories(categories);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache après modification des catégories
  Future<void> _updateCategoriesCacheAfterModification() async {
    try {
      final categories = await _remoteDataSource.getAllCategories();
      await _localDataSource.cacheCategories(categories);
    } catch (e) {
      // Ignore cache update errors
    }
  }

  /// Mettre à jour le cache des statistiques en arrière-plan
  void _updateStatsCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final stats = await _remoteDataSource.getMenuStats();
        await _localDataSource.cacheMenuStats(stats);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache des articles populaires en arrière-plan
  void _updatePopularItemsCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final items = await _remoteDataSource.getPopularMenuItems();
        await _localDataSource.cachePopularMenuItems(items);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }

  /// Mettre à jour le cache des catégories populaires en arrière-plan
  void _updatePopularCategoriesCacheInBackground() {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final categories = await _remoteDataSource.getPopularCategories();
        await _localDataSource.cachePopularCategories(categories);
      } catch (e) {
        // Ignore background update errors
      }
    });
  }
}

