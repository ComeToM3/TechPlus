import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../security/security_service.dart';

/// Client HTTP pour l'API TechPlus
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final SecurityService _securityService = SecurityService();

  /// Initialise le client HTTP avec sécurité
  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Configurer la sécurité
    await _configureSecurity();
    
    // Intercepteurs
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  /// Configure la sécurité pour le client API
  Future<void> _configureSecurity() async {
    try {
      // Vérifier HTTPS
      if (!_securityService.httpsEnforcement.validateHttpsUrl(AppConstants.baseUrl)) {
        throw Exception('Base URL must use HTTPS: ${AppConstants.baseUrl}');
      }

      // Configurer le certificate pinning
      // final adapter = _dio.httpClientAdapter;
      // if (adapter is DefaultHttpClientAdapter) {
      //   adapter.onHttpClientCreate = (client) {
      //     _securityService.certificatePinning.configureHttpClient(client);
      //     _securityService.httpsEnforcement.configureHttpClient(client);
      //     return client;
      //   };
      // }

      if (kDebugMode) {
        print('✅ API client security configured');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring API client security: $e');
      }
      rethrow;
    }
  }

  /// Intercepteur pour l'authentification
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ajouter le token d'authentification
        final token = await _securityService.tokenManager.getValidAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // TODO: Gérer les erreurs d'authentification (401, 403)
        handler.next(error);
      },
    );
  }

  /// Intercepteur pour les logs
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
      responseHeader: false,
    );
  }

  /// Intercepteur pour la gestion d'erreurs
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // TODO: Gérer les erreurs globales
        handler.next(error);
      },
    );
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

  /// Instance Dio pour les cas avancés
  Dio get dio => _dio;
}
