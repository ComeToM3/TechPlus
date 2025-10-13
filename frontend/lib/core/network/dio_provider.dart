import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_config.dart';

/// Provider pour l'instance Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Configuration de base
  dio.options.baseUrl = ApiConfig.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  
  // Intercepteurs
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  return dio;
});
