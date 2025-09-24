/// Entité représentant un article de menu
class MenuItemEntity {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? image;
  final bool isAvailable;
  final List<String> allergens;
  final String restaurantId;
  final int? preparationTime; // en minutes
  final String? ingredients;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final int? calories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItemEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.image,
    required this.isAvailable,
    required this.allergens,
    required this.restaurantId,
    this.preparationTime,
    this.ingredients,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
    this.calories,
    required this.createdAt,
    required this.updatedAt,
  });

  MenuItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? image,
    bool? isAvailable,
    List<String>? allergens,
    String? restaurantId,
    int? preparationTime,
    String? ingredients,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isSpicy,
    int? calories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      allergens: allergens ?? this.allergens,
      restaurantId: restaurantId ?? this.restaurantId,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isSpicy: isSpicy ?? this.isSpicy,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'isAvailable': isAvailable,
      'allergens': allergens,
      'restaurantId': restaurantId,
      'preparationTime': preparationTime,
      'ingredients': ingredients,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isSpicy': isSpicy,
      'calories': calories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MenuItemEntity.fromJson(Map<String, dynamic> json) {
    return MenuItemEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      image: json['image'] as String?,
      isAvailable: json['isAvailable'] as bool,
      allergens: List<String>.from(json['allergens'] as List),
      restaurantId: json['restaurantId'] as String,
      preparationTime: json['preparationTime'] as int?,
      ingredients: json['ingredients'] as String?,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      isSpicy: json['isSpicy'] as bool? ?? false,
      calories: json['calories'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Entité représentant une catégorie de menu
class MenuCategoryEntity {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final String restaurantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuCategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.sortOrder,
    required this.isActive,
    required this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  MenuCategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    int? sortOrder,
    bool? isActive,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'restaurantId': restaurantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MenuCategoryEntity.fromJson(Map<String, dynamic> json) {
    return MenuCategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool,
      restaurantId: json['restaurantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Modèle pour la création d'un article de menu
class CreateMenuItemRequest {
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? image;
  final bool isAvailable;
  final List<String> allergens;
  final int? preparationTime;
  final String? ingredients;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final int? calories;

  const CreateMenuItemRequest({
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.image,
    this.isAvailable = true,
    this.allergens = const [],
    this.preparationTime,
    this.ingredients,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
    this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'isAvailable': isAvailable,
      'allergens': allergens,
      'preparationTime': preparationTime,
      'ingredients': ingredients,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isSpicy': isSpicy,
      'calories': calories,
    };
  }
}

/// Modèle pour la mise à jour d'un article de menu
class UpdateMenuItemRequest {
  final String? name;
  final String? description;
  final double? price;
  final String? category;
  final String? image;
  final bool? isAvailable;
  final List<String>? allergens;
  final int? preparationTime;
  final String? ingredients;
  final bool? isVegetarian;
  final bool? isVegan;
  final bool? isGlutenFree;
  final bool? isSpicy;
  final int? calories;

  const UpdateMenuItemRequest({
    this.name,
    this.description,
    this.price,
    this.category,
    this.image,
    this.isAvailable,
    this.allergens,
    this.preparationTime,
    this.ingredients,
    this.isVegetarian,
    this.isVegan,
    this.isGlutenFree,
    this.isSpicy,
    this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (category != null) 'category': category,
      if (image != null) 'image': image,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (allergens != null) 'allergens': allergens,
      if (preparationTime != null) 'preparationTime': preparationTime,
      if (ingredients != null) 'ingredients': ingredients,
      if (isVegetarian != null) 'isVegetarian': isVegetarian,
      if (isVegan != null) 'isVegan': isVegan,
      if (isGlutenFree != null) 'isGlutenFree': isGlutenFree,
      if (isSpicy != null) 'isSpicy': isSpicy,
      if (calories != null) 'calories': calories,
    };
  }
}

/// Modèle pour la création d'une catégorie
class CreateCategoryRequest {
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;

  const CreateCategoryRequest({
    required this.name,
    this.description,
    this.image,
    required this.sortOrder,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}

/// Modèle pour la mise à jour d'une catégorie
class UpdateCategoryRequest {
  final String? name;
  final String? description;
  final String? image;
  final int? sortOrder;
  final bool? isActive;

  const UpdateCategoryRequest({
    this.name,
    this.description,
    this.image,
    this.sortOrder,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isActive != null) 'isActive': isActive,
    };
  }
}

/// Modèle pour l'upload d'image
class ImageUploadRequest {
  final String fileName;
  final String fileType;
  final String base64Data;

  const ImageUploadRequest({
    required this.fileName,
    required this.fileType,
    required this.base64Data,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'base64Data': base64Data,
    };
  }
}

/// Modèle pour la réponse d'upload d'image
class ImageUploadResponse {
  final String url;
  final String fileName;
  final String fileType;
  final int fileSize;

  const ImageUploadResponse({
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
    );
  }
}

/// Allergènes prédéfinis
enum AllergenType {
  gluten,
  dairy,
  eggs,
  nuts,
  peanuts,
  soy,
  fish,
  shellfish,
  sesame,
  sulfites,
  celery,
  mustard,
  lupin,
  mollusks,
}

/// Extension pour les allergènes
extension AllergenTypeExtension on AllergenType {
  String get displayName {
    switch (this) {
      case AllergenType.gluten:
        return 'Gluten';
      case AllergenType.dairy:
        return 'Produits laitiers';
      case AllergenType.eggs:
        return 'Œufs';
      case AllergenType.nuts:
        return 'Fruits à coque';
      case AllergenType.peanuts:
        return 'Arachides';
      case AllergenType.soy:
        return 'Soja';
      case AllergenType.fish:
        return 'Poisson';
      case AllergenType.shellfish:
        return 'Crustacés';
      case AllergenType.sesame:
        return 'Sésame';
      case AllergenType.sulfites:
        return 'Sulfites';
      case AllergenType.celery:
        return 'Céleri';
      case AllergenType.mustard:
        return 'Moutarde';
      case AllergenType.lupin:
        return 'Lupin';
      case AllergenType.mollusks:
        return 'Mollusques';
    }
  }

  String get englishDisplayName {
    switch (this) {
      case AllergenType.gluten:
        return 'Gluten';
      case AllergenType.dairy:
        return 'Dairy';
      case AllergenType.eggs:
        return 'Eggs';
      case AllergenType.nuts:
        return 'Nuts';
      case AllergenType.peanuts:
        return 'Peanuts';
      case AllergenType.soy:
        return 'Soy';
      case AllergenType.fish:
        return 'Fish';
      case AllergenType.shellfish:
        return 'Shellfish';
      case AllergenType.sesame:
        return 'Sesame';
      case AllergenType.sulfites:
        return 'Sulfites';
      case AllergenType.celery:
        return 'Celery';
      case AllergenType.mustard:
        return 'Mustard';
      case AllergenType.lupin:
        return 'Lupin';
      case AllergenType.mollusks:
        return 'Mollusks';
    }
  }

  String get icon {
    switch (this) {
      case AllergenType.gluten:
        return '🌾';
      case AllergenType.dairy:
        return '🥛';
      case AllergenType.eggs:
        return '🥚';
      case AllergenType.nuts:
        return '🥜';
      case AllergenType.peanuts:
        return '🥜';
      case AllergenType.soy:
        return '🫘';
      case AllergenType.fish:
        return '🐟';
      case AllergenType.shellfish:
        return '🦐';
      case AllergenType.sesame:
        return '🌰';
      case AllergenType.sulfites:
        return '🍷';
      case AllergenType.celery:
        return '🥬';
      case AllergenType.mustard:
        return '🌶️';
      case AllergenType.lupin:
        return '🫘';
      case AllergenType.mollusks:
        return '🐚';
    }
  }
}

