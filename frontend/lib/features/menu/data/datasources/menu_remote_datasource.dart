import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../models/menu_item_model.dart';

/// Source de données distante pour le menu
abstract class MenuRemoteDataSource {
  Future<List<MenuItemModel>> getAllMenuItems();
  Future<List<MenuItemModel>> getMenuItemsByCategory(String category);
  Future<MenuItemModel?> getMenuItemById(String id);
  Future<List<MenuItemModel>> searchMenuItems(String query);
  Future<List<String>> getCategories();
}

/// Implémentation de la source de données distante pour le menu
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final ApiClient _apiClient;

  MenuRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final response = await _apiClient.get('/api/menu/items');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((json) => MenuItemModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load menu items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/api/menu/items?category=$category');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((json) => MenuItemModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load menu items by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu items by category: $e');
    }
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final response = await _apiClient.get('/api/menu/items/$id');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = response.data;
        return MenuItemModel.fromJson(json);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load menu item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menu item: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final response = await _apiClient.get('/api/menu/items/search?q=${Uri.encodeComponent(query)}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((json) => MenuItemModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search menu items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching menu items: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/api/menu/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => json.toString()).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
