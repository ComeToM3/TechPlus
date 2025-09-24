import '../../../../core/network/api_client.dart';
import '../../domain/entities/report_entity.dart';

/// Data source pour les rapports (API)
class ReportRemoteDataSource {
  final ApiClient _apiClient;

  const ReportRemoteDataSource(this._apiClient);

  /// Génère un rapport via l'API
  Future<Report> generateReport(ReportFilters filters) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/generate',
        data: filters.toJson(),
      );

      if (response.statusCode == 200) {
        return Report.fromJson(response.data);
      } else {
        throw Exception('Failed to generate report: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }

  /// Récupère les rapports sauvegardés
  Future<List<Report>> getSavedReports() async {
    try {
      final response = await _apiClient.get('/api/admin/reports/saved');

      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data;
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get saved reports: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting saved reports: $e');
    }
  }

  /// Sauvegarde un rapport
  Future<void> saveReport(Report report) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/save',
        data: report.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save report: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error saving report: $e');
    }
  }

  /// Supprime un rapport sauvegardé
  Future<void> deleteReport(String reportId) async {
    try {
      final response = await _apiClient.delete('/api/admin/reports/$reportId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete report: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error deleting report: $e');
    }
  }

  /// Exporte un rapport
  Future<String> exportReport(Report report, ExportOptions options) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/export',
        data: {
          'report': report.toJson(),
          'options': options.toJson(),
        },
      );

      if (response.statusCode == 200) {
        return response.data['downloadUrl'] ?? '';
      } else {
        throw Exception('Failed to export report: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error exporting report: $e');
    }
  }

  /// Récupère les métriques
  Future<ReportMetrics> getMetrics(ReportFilters filters) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/metrics',
        data: filters.toJson(),
      );

      if (response.statusCode == 200) {
        return ReportMetrics.fromJson(response.data);
      } else {
        throw Exception('Failed to get metrics: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting metrics: $e');
    }
  }

  /// Récupère les données par période
  Future<List<ReportPeriodData>> getPeriodData(ReportFilters filters) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/period-data',
        data: filters.toJson(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataJson = response.data;
        return dataJson.map((json) => ReportPeriodData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get period data: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting period data: $e');
    }
  }

  /// Récupère les données par table
  Future<List<ReportTableData>> getTableData(ReportFilters filters) async {
    try {
      final response = await _apiClient.post(
        '/api/admin/reports/table-data',
        data: filters.toJson(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataJson = response.data;
        return dataJson.map((json) => ReportTableData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get table data: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting table data: $e');
    }
  }
}

