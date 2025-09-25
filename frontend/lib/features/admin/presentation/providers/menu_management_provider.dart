import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/index.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../data/datasources/menu_remote_datasource.dart';
import '../../data/datasources/menu_local_datasource.dart';
import '../../data/repositories/menu_repository_impl.dart';

// Provider moved to shared/providers/core_providers.dart

/// Provider pour le data source distant
final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MenuRemoteDataSource(apiClient);
});

/// Provider pour le data source local
final menuLocalDataSourceProvider = Provider<MenuLocalDataSource>((ref) {
  return const MenuLocalDataSource();
});

/// Provider pour le repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final remoteDataSource = ref.watch(menuRemoteDataSourceProvider);
  final localDataSource = ref.watch(menuLocalDataSourceProvider);
  return MenuRepositoryImpl(remoteDataSource, localDataSource);
});

/// Provider pour la liste des articles de menu
final menuItemsProvider = FutureProvider<List<MenuItemEntity>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getAllMenuItems();
});

/// Provider pour un article spécifique
final menuItemProvider = FutureProvider.family<MenuItemEntity?, String>((ref, id) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuItemById(id);
});

/// Provider pour les articles par catégorie
final menuItemsByCategoryProvider = FutureProvider.family<List<MenuItemEntity>, String>((ref, category) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuItemsByCategory(category);
});

/// Provider pour les articles disponibles
final availableMenuItemsProvider = FutureProvider<List<MenuItemEntity>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getAvailableMenuItems();
});

/// Provider pour les catégories
final categoriesProvider = FutureProvider<List<MenuCategoryEntity>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getAllCategories();
});

/// Provider pour une catégorie spécifique
final categoryProvider = FutureProvider.family<MenuCategoryEntity?, String>((ref, id) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getCategoryById(id);
});

/// Provider pour les statistiques du menu
final menuStatsProvider = FutureProvider<MenuStats>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuStats();
});

/// Provider pour les articles populaires
final popularMenuItemsProvider = FutureProvider<List<PopularMenuItem>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getPopularMenuItems();
});

/// Provider pour les catégories populaires
final popularCategoriesProvider = FutureProvider<List<PopularCategory>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getPopularCategories();
});

/// Provider pour la recherche d'articles
final searchMenuItemsProvider = FutureProvider.family<List<MenuItemEntity>, String>((ref, query) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.searchMenuItems(query);
});

/// Provider pour les articles par allergènes
final menuItemsByAllergensProvider = FutureProvider.family<List<MenuItemEntity>, List<String>>((ref, allergens) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuItemsByAllergens(allergens);
});

/// Provider pour l'état de chargement des articles
final menuItemsLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'état d'erreur des articles
final menuItemsErrorProvider = StateProvider<String?>((ref) => null);

/// Provider pour les actions sur les articles
final menuItemActionsProvider = StateNotifierProvider<MenuItemActionsNotifier, MenuItemActionsState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return MenuItemActionsNotifier(repository);
});

/// Provider pour les actions sur les catégories
final categoryActionsProvider = StateNotifierProvider<CategoryActionsNotifier, CategoryActionsState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return CategoryActionsNotifier(repository);
});

/// État des actions sur les articles
class MenuItemActionsState {
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isUploading;
  final String? error;
  final String? successMessage;

  const MenuItemActionsState({
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isUploading = false,
    this.error,
    this.successMessage,
  });

  MenuItemActionsState copyWith({
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isUploading,
    String? error,
    String? successMessage,
  }) {
    return MenuItemActionsState(
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// État des actions sur les catégories
class CategoryActionsState {
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isReordering;
  final String? error;
  final String? successMessage;

  const CategoryActionsState({
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isReordering = false,
    this.error,
    this.successMessage,
  });

  CategoryActionsState copyWith({
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isReordering,
    String? error,
    String? successMessage,
  }) {
    return CategoryActionsState(
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isReordering: isReordering ?? this.isReordering,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Notifier pour les actions sur les articles
class MenuItemActionsNotifier extends StateNotifier<MenuItemActionsState> {
  final MenuRepository _repository;

  MenuItemActionsNotifier(this._repository) : super(const MenuItemActionsState());

  /// Créer un nouvel article
  Future<MenuItemEntity?> createMenuItem(CreateMenuItemRequest request) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      final newItem = await _repository.createMenuItem(request);
      state = state.copyWith(
        isCreating: false,
        successMessage: 'Article créé avec succès',
      );
      return newItem;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erreur lors de la création de l\'article: $e',
      );
      return null;
    }
  }

  /// Mettre à jour un article
  Future<MenuItemEntity?> updateMenuItem(String id, UpdateMenuItemRequest request) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedItem = await _repository.updateMenuItem(id, request);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Article mis à jour avec succès',
      );
      return updatedItem;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour de l\'article: $e',
      );
      return null;
    }
  }

  /// Supprimer un article
  Future<bool> deleteMenuItem(String id) async {
    state = state.copyWith(isDeleting: true, error: null);
    
    try {
      await _repository.deleteMenuItem(id);
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Article supprimé avec succès',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erreur lors de la suppression de l\'article: $e',
      );
      return false;
    }
  }

  /// Changer la disponibilité d'un article
  Future<MenuItemEntity?> toggleMenuItemAvailability(String id) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedItem = await _repository.toggleMenuItemAvailability(id);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Disponibilité mise à jour',
      );
      return updatedItem;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour de la disponibilité: $e',
      );
      return null;
    }
  }

  /// Uploader une image
  Future<ImageUploadResponse?> uploadImage(ImageUploadRequest request) async {
    state = state.copyWith(isUploading: true, error: null);
    
    try {
      final response = await _repository.uploadImage(request);
      state = state.copyWith(
        isUploading: false,
        successMessage: 'Image uploadée avec succès',
      );
      return response;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Erreur lors de l\'upload de l\'image: $e',
      );
      return null;
    }
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Notifier pour les actions sur les catégories
class CategoryActionsNotifier extends StateNotifier<CategoryActionsState> {
  final MenuRepository _repository;

  CategoryActionsNotifier(this._repository) : super(const CategoryActionsState());

  /// Créer une nouvelle catégorie
  Future<MenuCategoryEntity?> createCategory(CreateCategoryRequest request) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      final newCategory = await _repository.createCategory(request);
      state = state.copyWith(
        isCreating: false,
        successMessage: 'Catégorie créée avec succès',
      );
      return newCategory;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erreur lors de la création de la catégorie: $e',
      );
      return null;
    }
  }

  /// Mettre à jour une catégorie
  Future<MenuCategoryEntity?> updateCategory(String id, UpdateCategoryRequest request) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final updatedCategory = await _repository.updateCategory(id, request);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Catégorie mise à jour avec succès',
      );
      return updatedCategory;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur lors de la mise à jour de la catégorie: $e',
      );
      return null;
    }
  }

  /// Supprimer une catégorie
  Future<bool> deleteCategory(String id) async {
    state = state.copyWith(isDeleting: true, error: null);
    
    try {
      await _repository.deleteCategory(id);
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Catégorie supprimée avec succès',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erreur lors de la suppression de la catégorie: $e',
      );
      return false;
    }
  }

  /// Réorganiser les catégories
  Future<bool> reorderCategories(List<String> categoryIds) async {
    state = state.copyWith(isReordering: true, error: null);
    
    try {
      await _repository.reorderCategories(categoryIds);
      state = state.copyWith(
        isReordering: false,
        successMessage: 'Ordre des catégories mis à jour',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isReordering: false,
        error: 'Erreur lors de la réorganisation: $e',
      );
      return false;
    }
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

