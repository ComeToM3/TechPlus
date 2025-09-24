import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';
import '../datasources/menu_local_datasource.dart';
import '../models/menu_item_model.dart';

/// Implémentation du repository pour le menu
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _remoteDataSource;
  final MenuLocalDataSource _localDataSource;

  MenuRepositoryImpl({
    required MenuRemoteDataSource remoteDataSource,
    MenuLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource ?? MenuLocalDataSource();

  @override
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      // Utiliser les données locales pour le moment
      final models = _localDataSource.getAllMenuItems();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all menu items: $e');
    }
  }

  @override
  Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    try {
      final models = _localDataSource.getMenuItemsByCategory(category);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get menu items by category: $e');
    }
  }

  @override
  Future<MenuItem?> getMenuItemById(String id) async {
    try {
      final model = _localDataSource.getMenuItemById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get menu item by id: $e');
    }
  }

  @override
  Future<List<MenuItem>> searchMenuItems(String query) async {
    try {
      final models = _localDataSource.searchMenuItems(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return _localDataSource.getCategories();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<List<MenuItem>> getAvailableMenuItems() async {
    try {
      final models = _localDataSource.getAvailableMenuItems();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get available menu items: $e');
    }
  }
}
