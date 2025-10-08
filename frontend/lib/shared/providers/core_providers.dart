import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/standard_api_client.dart';

/// Provider central pour le client API standardisé
/// Utilisé dans toute l'application pour éviter les duplications
final apiClientProvider = Provider<StandardApiClient>((ref) {
  return StandardApiClient.create();
});

/// Provider central pour SharedPreferences
/// Utilisé dans toute l'application pour éviter les duplications
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    // En cas d'erreur, retourner une instance vide
    print('⚠️ SharedPreferences initialization failed: $e');
    rethrow;
  }
});

