import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/report_entity.dart';

/// Data source local pour les rapports (cache)
class ReportLocalDataSource {
  final SharedPreferences _prefs;

  const ReportLocalDataSource(this._prefs);

  static const String _savedReportsKey = 'saved_reports';
  static const String _reportFiltersKey = 'report_filters';
  static const String _exportOptionsKey = 'export_options';

  /// Récupère les rapports sauvegardés localement
  Future<List<Report>> getSavedReports() async {
    try {
      final String? reportsJson = _prefs.getString(_savedReportsKey);
      if (reportsJson == null) return [];

      final List<dynamic> reportsList = jsonDecode(reportsJson);
      return reportsList.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarde un rapport localement
  Future<void> saveReport(Report report) async {
    try {
      final List<Report> existingReports = await getSavedReports();
      existingReports.add(report);
      
      final String reportsJson = jsonEncode(
        existingReports.map((r) => r.toJson()).toList(),
      );
      
      await _prefs.setString(_savedReportsKey, reportsJson);
    } catch (e) {
      throw Exception('Error saving report locally: $e');
    }
  }

  /// Supprime un rapport localement
  Future<void> deleteReport(String reportId) async {
    try {
      final List<Report> existingReports = await getSavedReports();
      existingReports.removeWhere((report) => report.id == reportId);
      
      final String reportsJson = jsonEncode(
        existingReports.map((r) => r.toJson()).toList(),
      );
      
      await _prefs.setString(_savedReportsKey, reportsJson);
    } catch (e) {
      throw Exception('Error deleting report locally: $e');
    }
  }

  /// Sauvegarde les filtres de rapport
  Future<void> saveReportFilters(ReportFilters filters) async {
    try {
      final String filtersJson = jsonEncode(filters.toJson());
      await _prefs.setString(_reportFiltersKey, filtersJson);
    } catch (e) {
      throw Exception('Error saving report filters: $e');
    }
  }

  /// Récupère les filtres de rapport sauvegardés
  Future<ReportFilters?> getReportFilters() async {
    try {
      final String? filtersJson = _prefs.getString(_reportFiltersKey);
      if (filtersJson == null) return null;

      final Map<String, dynamic> filtersMap = jsonDecode(filtersJson);
      return ReportFilters.fromJson(filtersMap);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde les options d'export
  Future<void> saveExportOptions(ExportOptions options) async {
    try {
      final String optionsJson = jsonEncode(options.toJson());
      await _prefs.setString(_exportOptionsKey, optionsJson);
    } catch (e) {
      throw Exception('Error saving export options: $e');
    }
  }

  /// Récupère les options d'export sauvegardées
  Future<ExportOptions?> getExportOptions() async {
    try {
      final String? optionsJson = _prefs.getString(_exportOptionsKey);
      if (optionsJson == null) return null;

      final Map<String, dynamic> optionsMap = jsonDecode(optionsJson);
      return ExportOptions.fromJson(optionsMap);
    } catch (e) {
      return null;
    }
  }

  /// Efface le cache des rapports
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_savedReportsKey);
      await _prefs.remove(_reportFiltersKey);
      await _prefs.remove(_exportOptionsKey);
    } catch (e) {
      throw Exception('Error clearing report cache: $e');
    }
  }
}

