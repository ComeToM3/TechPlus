import '../entities/menu_item.dart';

/// Repository pour la gestion du menu
abstract class MenuRepository {
  /// Récupérer tous les éléments du menu
  Future<List<MenuItem>> getAllMenuItems();

  /// Récupérer les éléments du menu par catégorie
  Future<List<MenuItem>> getMenuItemsByCategory(String category);

  /// Récupérer un élément du menu par ID
  Future<MenuItem?> getMenuItemById(String id);

  /// Rechercher des éléments du menu
  Future<List<MenuItem>> searchMenuItems(String query);

  /// Récupérer toutes les catégories disponibles
  Future<List<String>> getCategories();

  /// Récupérer les éléments disponibles uniquement
  Future<List<MenuItem>> getAvailableMenuItems();
}
