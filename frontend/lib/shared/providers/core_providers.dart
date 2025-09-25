import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Provider central pour le client API
/// Utilisé dans toute l'application pour éviter les duplications
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  final apiClient = ApiClient(dio);
  apiClient.initialize();
  return apiClient;
});

/// Provider central pour SharedPreferences
/// Utilisé dans toute l'application pour éviter les duplications
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider pour l'instance Dio (si nécessaire pour des cas spécifiques)
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});
