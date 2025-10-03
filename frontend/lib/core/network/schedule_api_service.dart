import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// Service API pour la gestion des horaires
class ScheduleApiService {
  final Dio _dio;
  final String _baseUrl;

  ScheduleApiService(this._dio, this._baseUrl);

  /// Méthode GET générique
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final response = await _dio.get(
      '$_baseUrl$endpoint',
      options: Options(
        headers: _getHeaders(token),
      ),
    );
    return response.data;
  }

  /// Méthode POST générique
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final response = await _dio.post(
      '$_baseUrl$endpoint',
      data: data,
      options: Options(
        headers: _getHeaders(token),
      ),
    );
    return response.data;
  }

  /// Méthode PUT générique
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final response = await _dio.put(
      '$_baseUrl$endpoint',
      data: data,
      options: Options(
        headers: _getHeaders(token),
      ),
    );
    return response.data;
  }

  /// Méthode DELETE générique
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final response = await _dio.delete(
      '$_baseUrl$endpoint',
      options: Options(
        headers: _getHeaders(token),
      ),
    );
    return response.data;
  }

  /// Headers avec token d'authentification
  Map<String, String> _getHeaders(String? token) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
