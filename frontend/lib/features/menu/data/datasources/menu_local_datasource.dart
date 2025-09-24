import '../models/menu_item_model.dart';

/// Source de données locale pour le menu (données de test)
class MenuLocalDataSource {
  /// Données de test pour le menu
  static final List<MenuItemModel> _mockMenuItems = [
    MenuItemModel(
      id: '1',
      name: 'Salade César',
      description: 'Salade fraîche avec croûtons, parmesan et sauce césar maison',
      price: 12.50,
      category: 'Entrées',
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
      isAvailable: true,
      allergens: ['gluten', 'lait'],
    ),
    MenuItemModel(
      id: '2',
      name: 'Burger Classique',
      description: 'Burger avec steak haché, salade, tomate, oignon et sauce spéciale',
      price: 16.90,
      category: 'Plats Principaux',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      isAvailable: true,
      allergens: ['gluten', 'lait', 'œufs'],
    ),
    MenuItemModel(
      id: '3',
      name: 'Pizza Margherita',
      description: 'Pizza traditionnelle avec tomate, mozzarella et basilic frais',
      price: 14.50,
      category: 'Plats Principaux',
      imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
      isAvailable: true,
      allergens: ['gluten', 'lait'],
    ),
    MenuItemModel(
      id: '4',
      name: 'Saumon Grillé',
      description: 'Filet de saumon grillé avec légumes de saison et riz pilaf',
      price: 22.90,
      category: 'Plats Principaux',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400',
      isAvailable: true,
      allergens: ['poisson'],
    ),
    MenuItemModel(
      id: '5',
      name: 'Tiramisu',
      description: 'Dessert italien traditionnel au café et mascarpone',
      price: 8.50,
      category: 'Desserts',
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
      isAvailable: true,
      allergens: ['lait', 'œufs', 'gluten'],
    ),
    MenuItemModel(
      id: '6',
      name: 'Tarte Tatin',
      description: 'Tarte aux pommes caramélisées avec crème chantilly',
      price: 9.90,
      category: 'Desserts',
      imageUrl: 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400',
      isAvailable: true,
      allergens: ['gluten', 'lait', 'œufs'],
    ),
    MenuItemModel(
      id: '7',
      name: 'Soupe à l\'Oignon',
      description: 'Soupe traditionnelle française avec fromage gratiné',
      price: 10.50,
      category: 'Entrées',
      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
      isAvailable: true,
      allergens: ['gluten', 'lait'],
    ),
    MenuItemModel(
      id: '8',
      name: 'Pâtes Carbonara',
      description: 'Pâtes avec sauce carbonara, lardons et parmesan',
      price: 15.90,
      category: 'Plats Principaux',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
      isAvailable: false, // Temporairement indisponible
      allergens: ['gluten', 'lait', 'œufs'],
    ),
    MenuItemModel(
      id: '9',
      name: 'Café Expresso',
      description: 'Café italien traditionnel',
      price: 2.50,
      category: 'Boissons',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      isAvailable: true,
      allergens: [],
    ),
    MenuItemModel(
      id: '10',
      name: 'Jus d\'Orange Frais',
      description: 'Jus d\'orange pressé du jour',
      price: 4.50,
      category: 'Boissons',
      imageUrl: 'https://images.unsplash.com/photo-1613478228249-871aaab0e5db?w=400',
      isAvailable: true,
      allergens: [],
    ),
  ];

  /// Récupérer tous les éléments du menu
  List<MenuItemModel> getAllMenuItems() {
    return List.from(_mockMenuItems);
  }

  /// Récupérer les éléments par catégorie
  List<MenuItemModel> getMenuItemsByCategory(String category) {
    return _mockMenuItems.where((item) => item.category == category).toList();
  }

  /// Récupérer un élément par ID
  MenuItemModel? getMenuItemById(String id) {
    try {
      return _mockMenuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Rechercher des éléments
  List<MenuItemModel> searchMenuItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _mockMenuItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          (item.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Récupérer toutes les catégories
  List<String> getCategories() {
    final categories = _mockMenuItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Récupérer les éléments disponibles
  List<MenuItemModel> getAvailableMenuItems() {
    return _mockMenuItems.where((item) => item.isAvailable).toList();
  }
}
