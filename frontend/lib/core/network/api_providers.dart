import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'availability_api.dart';
import 'clients_api.dart';
import 'dashboard_api.dart';
import 'tables_api.dart';
import 'schedule_api.dart';
import '../../shared/providers/core_providers.dart';

/// Provider pour l'API de disponibilité
final availabilityApiProvider = Provider<AvailabilityApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AvailabilityApi(dio, ApiConfig.baseUrl);
});

/// Provider pour l'API des clients
final clientsApiProvider = Provider<ClientsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientsApi(dio, ApiConfig.baseUrl);
});

/// Provider pour l'API du dashboard
final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardApi(dio, ApiConfig.baseUrl);
});

/// Provider pour l'API des tables
final tablesApiProvider = Provider<TablesApi>((ref) {
  final dio = ref.watch(dioProvider);
  return TablesApi(dio, ApiConfig.baseUrl);
});

/// Provider pour l'API des créneaux horaires
final scheduleApiProvider = Provider<ScheduleApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleApi(dio, ApiConfig.baseUrl);
});
