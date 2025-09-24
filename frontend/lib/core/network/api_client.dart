import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_token_manager.dart';

/// Intercepteur d'authentification pour ajouter automatiquement le token
class AuthInterceptor extends Interceptor {
  final AuthTokenManager _tokenManager = AuthTokenManager();

  AuthInterceptor() {
    // Écouter les changements de token
    _tokenManager.addListener(_onTokenChanged);
    // Initialiser avec le token actuel
    _onTokenChanged(_tokenManager.accessToken);
  }

  void _onTokenChanged(String? token) {
    // Le token est maintenant géré par le AuthTokenManager
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajouter le token d'authentification si disponible
    final token = _tokenManager.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔐 Auth token added to request: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token available for request');
    }
    handler.next(options);
  }
}

/// Client API pour les appels HTTP
class ApiClient {
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  ApiClient(this._dio) : _authInterceptor = AuthInterceptor() {
    // Configuration de base
    _dio.options.baseUrl = 'http://localhost:3000';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Intercepteurs
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    // Intercepteur d'authentification
    _dio.interceptors.add(_authInterceptor);
  }

  /// Mettre à jour le token d'authentification
  void updateAuthToken(String? token) {
    AuthTokenManager().updateToken(token);
  }

  /// Initialiser le client API
  Future<void> initialize() async {
    // L'initialisation est maintenant faite dans le constructeur
  }

  /// Effectuer une requête GET
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

  /// Effectuer une requête POST
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

  /// Effectuer une requête PUT
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

  /// Effectuer une requête PATCH
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

  /// Effectuer une requête DELETE
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
}

/// Provider pour le client API
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio();
  final apiClient = ApiClient(dio);
  // Initialiser de manière asynchrone
  apiClient.initialize();
  return apiClient;
});
