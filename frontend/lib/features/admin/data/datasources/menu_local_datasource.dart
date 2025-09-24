import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';

/// Data source local pour la gestion du menu
class MenuLocalDataSource {
  static const String _menuItemsKey = 'cached_menu_items';
  static const String _categoriesKey = 'cached_categories';
  static const String _statsKey = 'cached_menu_stats';
  static const String _popularItemsKey = 'cached_popular_items';
  static const String _popularCategoriesKey = 'cached_popular_categories';

  /// Articles de menu
  /// Récupérer les articles en cache
  Future<List<MenuItemEntity>?> getCachedMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_menuItemsKey);
      if (itemsJson != null) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        return itemsList
            .map((json) => MenuItemEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les articles
  Future<void> cacheMenuItems(List<MenuItemEntity> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = json.encode(
        items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_menuItemsKey, itemsJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Récupérer les articles par catégorie en cache
  Future<List<MenuItemEntity>?> getCachedMenuItemsByCategory(String category) async {
    try {
      final items = await getCachedMenuItems();
      if (items != null) {
        return items.where((item) => item.category == category).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les articles disponibles en cache
  Future<List<MenuItemEntity>?> getCachedAvailableMenuItems() async {
    try {
      final items = await getCachedMenuItems();
      if (items != null) {
        return items.where((item) => item.isAvailable).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Catégories
  /// Récupérer les catégories en cache
  Future<List<MenuCategoryEntity>?> getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_categoriesKey);
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        return categoriesList
            .map((json) => MenuCategoryEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les catégories
  Future<void> cacheCategories(List<MenuCategoryEntity> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(
        categories.map((category) => category.toJson()).toList(),
      );
      await prefs.setString(_categoriesKey, categoriesJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Statistiques
  /// Récupérer les statistiques en cache
  Future<MenuStats?> getCachedMenuStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      if (statsJson != null) {
        return MenuStats.fromJson(json.decode(statsJson) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les statistiques
  Future<void> cacheMenuStats(MenuStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Articles populaires
  /// Récupérer les articles populaires en cache
  Future<List<PopularMenuItem>?> getCachedPopularMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_popularItemsKey);
      if (itemsJson != null) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        return itemsList
            .map((json) => PopularMenuItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les articles populaires
  Future<void> cachePopularMenuItems(List<PopularMenuItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = json.encode(
        items.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_popularItemsKey, itemsJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Catégories populaires
  /// Récupérer les catégories populaires en cache
  Future<List<PopularCategory>?> getCachedPopularCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_popularCategoriesKey);
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        return categoriesList
            .map((json) => PopularCategory.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les catégories populaires
  Future<void> cachePopularCategories(List<PopularCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(
        categories.map((category) => category.toJson()).toList(),
      );
      await prefs.setString(_popularCategoriesKey, categoriesJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache
  /// Nettoyer le cache des articles
  Future<void> clearMenuItemsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_menuItemsKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache des catégories
  Future<void> clearCategoriesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_categoriesKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache des statistiques
  Future<void> clearStatsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache des articles populaires
  Future<void> clearPopularItemsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_popularItemsKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache des catégories populaires
  Future<void> clearPopularCategoriesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_popularCategoriesKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer tout le cache
  Future<void> clearAllCache() async {
    await Future.wait([
      clearMenuItemsCache(),
      clearCategoriesCache(),
      clearStatsCache(),
      clearPopularItemsCache(),
      clearPopularCategoriesCache(),
    ]);
  }
}

