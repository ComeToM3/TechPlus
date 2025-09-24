import '../entities/report_entity.dart';

/// Interface pour le repository des rapports
abstract class ReportRepository {
  /// Génère un rapport avec les filtres spécifiés
  Future<Report> generateReport(ReportFilters filters);

  /// Récupère les rapports sauvegardés
  Future<List<Report>> getSavedReports();

  /// Sauvegarde un rapport
  Future<void> saveReport(Report report);

  /// Supprime un rapport sauvegardé
  Future<void> deleteReport(String reportId);

  /// Exporte un rapport dans le format spécifié
  Future<String> exportReport(Report report, ExportOptions options);

  /// Récupère les métriques pour une période donnée
  Future<ReportMetrics> getMetrics(ReportFilters filters);

  /// Récupère les données par période
  Future<List<ReportPeriodData>> getPeriodData(ReportFilters filters);

  /// Récupère les données par table
  Future<List<ReportTableData>> getTableData(ReportFilters filters);
}

