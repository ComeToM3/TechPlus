import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/index.dart';
import '../../data/datasources/menu_remote_datasource.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';

/// État pour la liste des éléments du menu
class MenuState {
  final List<MenuItem> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? searchQuery;

  const MenuState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery,
  });

  MenuState copyWith({
    List<MenuItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return MenuState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier pour la gestion de l'état du menu
class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository _repository;

  MenuNotifier({required MenuRepository repository})
      : _repository = repository,
        super(const MenuState());

  /// Charger tous les éléments du menu
  Future<void> loadMenuItems() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final items = await _repository.getAllMenuItems();
      state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charger les éléments du menu par catégorie
  Future<void> loadMenuItemsByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null, selectedCategory: category);
    
    try {
      final items = await _repository.getMenuItemsByCategory(category);
      state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rechercher des éléments du menu
  Future<void> searchMenuItems(String query) async {
    if (query.isEmpty) {
      await loadMenuItems();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, searchQuery: query);
    
    try {
      final items = await _repository.searchMenuItems(query);
      state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charger les catégories disponibles
  Future<List<String>> loadCategories() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Réinitialiser l'état
  void reset() {
    state = const MenuState();
  }

  /// Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider pour le notifier du menu
final menuNotifierProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return MenuNotifier(repository: repository);
});

/// Provider pour les catégories du menu
final menuCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final notifier = ref.read(menuNotifierProvider.notifier);
  return await notifier.loadCategories();
});

/// Provider pour un élément du menu spécifique
final menuItemProvider = FutureProvider.family<MenuItem?, String>((ref, id) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuItemById(id);
});
