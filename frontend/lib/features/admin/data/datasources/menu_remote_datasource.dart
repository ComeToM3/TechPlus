import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';

/// Data source distant pour la gestion du menu
class MenuRemoteDataSource {
  final ApiClient _apiClient;

  const MenuRemoteDataSource(this._apiClient);

  /// Articles de menu
  /// Récupérer tous les articles
  Future<List<MenuItemEntity>> getAllMenuItems() async {
    try {
      final response = await _apiClient.get('/api/admin/menu/items');
      return (response.data as List)
          .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  /// Récupérer un article par ID
  Future<MenuItemEntity?> getMenuItemById(String id) async {
    try {
      final response = await _apiClient.get('/api/admin/menu/items/$id');
      return MenuItemEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch menu item: $e');
    }
  }

  /// Récupérer les articles par catégorie
  Future<List<MenuItemEntity>> getMenuItemsByCategory(String category) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/menu/items',
        queryParameters: {'category': category},
      );
      return (response.data as List)
          .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu items by category: $e');
    }
  }

  /// Récupérer les articles disponibles
  Future<List<MenuItemEntity>> getAvailableMenuItems() async {
    try {
      final response = await _apiClient.get('/api/admin/menu/items/available');
      return (response.data as List)
          .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available menu items: $e');
    }
  }

  /// Créer un nouvel article
  Future<MenuItemEntity> createMenuItem(CreateMenuItemRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/menu/items',
        data: request.toJson(),
      );
      return MenuItemEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  /// Mettre à jour un article
  Future<MenuItemEntity> updateMenuItem(String id, UpdateMenuItemRequest request) async {
    try {
      final response = await _apiClient.put(
        '/api/admin/menu/items/$id',
        data: request.toJson(),
      );
      return MenuItemEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  /// Supprimer un article
  Future<void> deleteMenuItem(String id) async {
    try {
      await _apiClient.delete('/api/admin/menu/items/$id');
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  /// Changer la disponibilité d'un article
  Future<MenuItemEntity> toggleMenuItemAvailability(String id) async {
    try {
      final response = await _apiClient.patch(
        '/api/admin/menu/items/$id/availability',
      );
      return MenuItemEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to toggle menu item availability: $e');
    }
  }

  /// Rechercher des articles
  Future<List<MenuItemEntity>> searchMenuItems(String query) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/menu/items/search',
        queryParameters: {'q': query},
      );
      return (response.data as List)
          .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  /// Récupérer les articles par allergènes
  Future<List<MenuItemEntity>> getMenuItemsByAllergens(List<String> allergens) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/menu/items/by-allergens',
        queryParameters: {'allergens': allergens.join(',')},
      );
      return (response.data as List)
          .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu items by allergens: $e');
    }
  }

  /// Catégories
  /// Récupérer toutes les catégories
  Future<List<MenuCategoryEntity>> getAllCategories() async {
    try {
      final response = await _apiClient.get('/api/admin/menu/categories');
      return (response.data as List)
          .map((json) => MenuCategoryEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Récupérer une catégorie par ID
  Future<MenuCategoryEntity?> getCategoryById(String id) async {
    try {
      final response = await _apiClient.get('/api/admin/menu/categories/$id');
      return MenuCategoryEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch category: $e');
    }
  }

  /// Créer une nouvelle catégorie
  Future<MenuCategoryEntity> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/menu/categories',
        data: request.toJson(),
      );
      return MenuCategoryEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Mettre à jour une catégorie
  Future<MenuCategoryEntity> updateCategory(String id, UpdateCategoryRequest request) async {
    try {
      final response = await _apiClient.put(
        '/api/admin/menu/categories/$id',
        data: request.toJson(),
      );
      return MenuCategoryEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Supprimer une catégorie
  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.delete('/api/admin/menu/categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Réorganiser les catégories
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      await _apiClient.patch(
        '/api/admin/menu/categories/reorder',
        data: {'categoryIds': categoryIds},
      );
    } catch (e) {
      throw Exception('Failed to reorder categories: $e');
    }
  }

  /// Upload d'images
  /// Uploader une image
  Future<ImageUploadResponse> uploadImage(ImageUploadRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/menu/upload-image',
        data: request.toJson(),
      );
      return ImageUploadResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      await _apiClient.delete(
        '/api/admin/menu/delete-image',
        queryParameters: {'imageUrl': imageUrl},
      );
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Optimiser une image
  Future<String> optimizeImage(String imageUrl, {int? width, int? height, int? quality}) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/menu/optimize-image',
        data: {
          'imageUrl': imageUrl,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
          if (quality != null) 'quality': quality,
        },
      );
      return response.data['optimizedUrl'] as String;
    } catch (e) {
      throw Exception('Failed to optimize image: $e');
    }
  }

  /// Statistiques
  /// Récupérer les statistiques du menu
  Future<MenuStats> getMenuStats() async {
    try {
      final response = await _apiClient.get('/api/admin/menu/stats');
      return MenuStats.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch menu stats: $e');
    }
  }

  /// Récupérer les articles les plus populaires
  Future<List<PopularMenuItem>> getPopularMenuItems({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/menu/popular-items',
        queryParameters: {'limit': limit},
      );
      return (response.data as List)
          .map((json) => PopularMenuItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular menu items: $e');
    }
  }

  /// Récupérer les catégories les plus populaires
  Future<List<PopularCategory>> getPopularCategories({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/menu/popular-categories',
        queryParameters: {'limit': limit},
      );
      return (response.data as List)
          .map((json) => PopularCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular categories: $e');
    }
  }
}

