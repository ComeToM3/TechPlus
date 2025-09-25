import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_state.dart';
import '../errors/app_errors.dart';
import '../../core/network/api_client.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import '../../features/menu/data/datasources/menu_remote_datasource.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import 'core_providers.dart';

/// État unifié pour le menu
class MenuState extends BaseListState<MenuItem> {
  final String? selectedCategory;
  final String? searchQuery;
  final List<String> categories;

  const MenuState({
    super.items = const [],
    super.isLoading = false,
    super.error,
    this.selectedCategory,
    this.searchQuery,
    this.categories = const [],
  });

  @override
  MenuState copyWith({
    List<MenuItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
    List<String>? categories,
  }) {
    return MenuState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
    );
  }
}

/// Notifier unifié pour la gestion du menu
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
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
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
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
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
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    }
  }

  /// Charger les catégories disponibles
  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      final error = AppErrorFactory.fromException(e);
      state = state.copyWith(error: error.message);
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

/// Provider pour la source de données distante du menu
final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MenuRemoteDataSourceImpl(apiClient: apiClient);
});

/// Provider pour le repository du menu
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final remoteDataSource = ref.watch(menuRemoteDataSourceProvider);
  return MenuRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider unifié pour l'état du menu
final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return MenuNotifier(repository: repository);
});

/// Provider pour les catégories du menu
final menuCategoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(menuProvider).categories;
});

/// Provider pour un élément du menu spécifique
final menuItemProvider = FutureProvider.family<MenuItem?, String>((ref, id) async {
  final repository = ref.watch(menuRepositoryProvider);
  return await repository.getMenuItemById(id);
});
