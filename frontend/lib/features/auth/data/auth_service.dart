import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

/// Service d'authentification pour les appels API
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Connexion avec email et mot de passe
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur de connexion: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Compte désactivé');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Inscription avec email et mot de passe
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur d\'inscription: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Un compte avec cet email existe déjà');
      } else {
        throw Exception('Erreur d\'inscription: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  /// Rafraîchissement du token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur de rafraîchissement: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de rafraîchissement: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de rafraîchissement: $e');
    }
  }

  /// Déconnexion
  Future<void> logout(String accessToken) async {
    try {
      await _apiClient.post(
        '/api/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } catch (e) {
      // Ignorer les erreurs de déconnexion
      print('Erreur lors de la déconnexion: $e');
    }
  }

  /// Vérifier le profil utilisateur
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    try {
      final response = await _apiClient.get(
        '/api/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur de récupération du profil: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de récupération du profil: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de récupération du profil: $e');
    }
  }
}

/// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});
