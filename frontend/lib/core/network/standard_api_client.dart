import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import 'auth_token_manager.dart';

/// Client API standardisé selon les standards industriels
/// Gère automatiquement l'authentification, les erreurs, et la configuration
class StandardApiClient {
  final Dio _dio;
  final String _baseUrl;

  StandardApiClient._(this._dio, this._baseUrl);

  /// Factory pour créer une instance configurée
  factory StandardApiClient.create() {
    final dio = Dio();
    
    // Configuration de base
    dio.options.baseUrl = ApiConfig.baseUrl;
    dio.options.connectTimeout = ApiConfig.connectTimeout;
    dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    dio.options.sendTimeout = ApiConfig.sendTimeout;
    
    // Intercepteurs
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
    
    // Intercepteur d'authentification automatique
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _addAuthenticationStatic(options);
        handler.next(options);
      },
      onError: (error, handler) {
        _handleErrorStatic(error);
        handler.next(error);
      },
    ));
    
    return StandardApiClient._(dio, ApiConfig.baseUrl);
  }

  /// Méthode statique pour ajouter l'authentification
  static void _addAuthenticationStatic(RequestOptions options) {
    final token = AuthTokenManager().accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Token de développement pour les tests
      options.headers['Authorization'] = 'Bearer dev-token';
    }
  }

  /// Méthode statique pour gérer les erreurs
  static void _handleErrorStatic(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        print('🔐 Authentication required');
        break;
      case 403:
        print('🚫 Access forbidden');
        break;
      case 404:
        print('❌ Resource not found');
        break;
      case 500:
        print('💥 Server error');
        break;
      default:
        print('⚠️ API Error: ${error.message}');
    }
  }


  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Accès au Dio interne (pour compatibilité)
  Dio get dio => _dio;
  
  /// URL de base
  String get baseUrl => _baseUrl;
}

/// Provider centralisé pour le client API standard
final standardApiClientProvider = Provider<StandardApiClient>((ref) {
  return StandardApiClient.create();
});
