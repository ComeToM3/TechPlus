import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/api_config.dart';


/// Provider pour Dio
final dioProvider = Provider<Dio>((ref) {
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
    logPrint: (obj) => print(obj),
  ));
  
  // Intercepteur pour ajouter le token d'authentification
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // TODO: Ajouter le token d'authentification depuis le storage
      // final token = await getStoredToken();
      // if (token != null) {
      //   options.headers['Authorization'] = 'Bearer $token';
      // }
      handler.next(options);
    },
    onError: (error, handler) {
      // Gestion globale des erreurs
      if (error.response?.statusCode == 401) {
        // TODO: Rediriger vers la page de connexion
        // ref.read(authProvider.notifier).logout();
      }
      handler.next(error);
    },
  ));
  
  return dio;
});

/// Provider pour le service API
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio, ApiConfig.baseUrl);
});

/// Provider pour l'URL de base de l'API
final apiBaseUrlProvider = Provider<String>((ref) {
  return ApiConfig.baseUrl;
});
