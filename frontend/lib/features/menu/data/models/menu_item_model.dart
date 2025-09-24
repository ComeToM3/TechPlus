import '../../domain/entities/menu_item.dart';

/// Modèle de données pour un élément du menu
class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.category,
    super.imageUrl,
    super.isAvailable,
    super.allergens,
  });

  /// Créer depuis un Map (désérialisation JSON)
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convertir en Map (sérialisation JSON)
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'allergens': allergens,
    };
  }

  /// Créer depuis l'entité MenuItem
  factory MenuItemModel.fromEntity(MenuItem item) {
    return MenuItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      category: item.category,
      imageUrl: item.imageUrl,
      isAvailable: item.isAvailable,
      allergens: item.allergens,
    );
  }

  /// Convertir en entité MenuItem
  MenuItem toEntity() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      allergens: allergens,
    );
  }
}
