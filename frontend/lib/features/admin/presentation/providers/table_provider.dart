import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/table_provider.dart' as data;
import '../../domain/entities/table_entity.dart';
import '../../../../shared/providers/auth_provider.dart';

/// Provider pour les tables
final tablesProvider = Provider<List<TableEntity>>((ref) {
  final tablesData = ref.watch(data.tablesProvider);
  if (tablesData == null) return [];
  
  return tablesData.map((tableData) => TableEntity.fromJson(tableData)).toList();
});

/// Provider pour une table spécifique
final tableProvider = FutureProvider.family<TableEntity?, String>((ref, id) async {
  final authState = ref.watch(authProvider);
  if (authState.accessToken == null) return null;
  
  try {
    final tableRepository = ref.read(data.tableRepositoryProvider);
    final tableData = await tableRepository.getTableById(
      token: authState.accessToken!,
      tableId: id,
    );
    return TableEntity.fromJson(tableData);
  } catch (e) {
    return null;
  }
});

/// Provider pour les tables par statut
final tablesByStatusProvider = Provider.family<List<TableEntity>, TableStatus>((ref, status) {
  final tables = ref.watch(tablesProvider);
  return tables.where((table) => table.status == status).toList();
});

/// Provider pour les tables disponibles
final availableTablesProvider = Provider<List<TableEntity>>((ref) {
  return ref.watch(tablesByStatusProvider(TableStatus.available));
});

/// Provider pour les statistiques des tables
final tableStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(data.tableStatsProvider);
});

/// Provider pour le plan du restaurant
final restaurantLayoutProvider = Provider<List<TableEntity>>((ref) {
  return ref.watch(tablesProvider);
});

/// Provider pour l'état de chargement des tables
final tablesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(data.tableLoadingProvider);
});

/// Provider pour l'état d'erreur des tables
final tablesErrorProvider = Provider<String?>((ref) {
  return ref.watch(data.tableErrorProvider);
});