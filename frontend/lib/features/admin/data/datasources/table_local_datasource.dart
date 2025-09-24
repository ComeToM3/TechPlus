import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';

/// Data source local pour la gestion des tables
class TableLocalDataSource {
  static const String _tablesKey = 'cached_tables';
  static const String _layoutKey = 'cached_restaurant_layout';
  static const String _statsKey = 'cached_table_stats';

  /// Récupérer les tables en cache
  Future<List<TableEntity>?> getCachedTables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tablesJson = prefs.getString(_tablesKey);
      if (tablesJson != null) {
        final List<dynamic> tablesList = json.decode(tablesJson);
        return tablesList
            .map((json) => TableEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les tables
  Future<void> cacheTables(List<TableEntity> tables) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tablesJson = json.encode(
        tables.map((table) => table.toJson()).toList(),
      );
      await prefs.setString(_tablesKey, tablesJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Récupérer le plan du restaurant en cache
  Future<RestaurantLayout?> getCachedRestaurantLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = prefs.getString(_layoutKey);
      if (layoutJson != null) {
        return RestaurantLayout.fromJson(
          json.decode(layoutJson) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache le plan du restaurant
  Future<void> cacheRestaurantLayout(RestaurantLayout layout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final layoutJson = json.encode(layout.toJson());
      await prefs.setString(_layoutKey, layoutJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Récupérer les statistiques en cache
  Future<List<TableStats>?> getCachedTableStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      if (statsJson != null) {
        final List<dynamic> statsList = json.decode(statsJson);
        return statsList
            .map((json) => TableStats.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mettre en cache les statistiques
  Future<void> cacheTableStats(List<TableStats> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(
        stats.map((stat) => stat.toJson()).toList(),
      );
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache des tables
  Future<void> clearTablesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tablesKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Nettoyer le cache du plan
  Future<void> clearLayoutCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_layoutKey);
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

  /// Nettoyer tout le cache
  Future<void> clearAllCache() async {
    await Future.wait([
      clearTablesCache(),
      clearLayoutCache(),
      clearStatsCache(),
    ]);
  }
}

/// Extension pour TableStats pour la sérialisation
extension TableStatsExtension on TableStats {
  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'totalReservations': totalReservations,
      'averageOccupancy': averageOccupancy,
      'revenue': revenue,
      'totalGuests': totalGuests,
      'lastReservation': lastReservation.toIso8601String(),
    };
  }
}

