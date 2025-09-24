import 'package:dio/dio.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../../../core/network/api_client.dart';

/// Data source distant pour les métriques du dashboard
class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource(this._apiClient);

  /// Récupérer les métriques du dashboard
  Future<DashboardMetrics> getDashboardMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/api/admin/dashboard/metrics',
        queryParameters: queryParams,
      );

      return DashboardMetrics.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: $e');
    }
  }

  /// Récupérer les tendances des réservations
  Future<List<ReservationTrend>> getReservationTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiClient.get(
        '/api/admin/dashboard/reservation-trends',
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((e) => ReservationTrend.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch reservation trends: $e');
    }
  }

  /// Récupérer les tendances des revenus
  Future<List<RevenueTrend>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _apiClient.get(
        '/api/admin/dashboard/revenue-trends',
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((e) => RevenueTrend.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch revenue trends: $e');
    }
  }

  /// Récupérer l'occupation des tables
  Future<List<TableOccupancy>> getTableOccupancy() async {
    try {
      final response = await _apiClient.get('/api/admin/dashboard/table-occupancy');

      return (response.data as List<dynamic>)
          .map((e) => TableOccupancy.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch table occupancy: $e');
    }
  }

  /// Récupérer les créneaux horaires populaires
  Future<List<PopularTimeSlot>> getPopularTimeSlots({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/api/admin/dashboard/popular-time-slots',
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((e) => PopularTimeSlot.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch popular time slots: $e');
    }
  }

  /// Récupérer les segments de clients
  Future<List<CustomerSegment>> getCustomerSegments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        '/api/admin/dashboard/customer-segments',
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((e) => CustomerSegment.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch customer segments: $e');
    }
  }

  /// Gérer les erreurs Dio
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error');
      case DioExceptionType.unknown:
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
