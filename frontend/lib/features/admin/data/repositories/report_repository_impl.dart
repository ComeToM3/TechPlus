import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../datasources/report_local_datasource.dart';

/// Implémentation du repository des rapports
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;
  final ReportLocalDataSource _localDataSource;

  const ReportRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Report> generateReport(ReportFilters filters) async {
    try {
      // Essayer d'abord l'API
      final report = await _remoteDataSource.generateReport(filters);
      
      // Sauvegarder les filtres localement
      await _localDataSource.saveReportFilters(filters);
      
      return report;
    } catch (e) {
      // En cas d'erreur, retourner un rapport vide avec les filtres
      return Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateReportTitle(filters),
        type: filters.reportType,
        generatedAt: DateTime.now(),
        filters: filters,
        metrics: const ReportMetrics(
          totalReservations: 0,
          confirmedReservations: 0,
          cancelledReservations: 0,
          noShowReservations: 0,
          totalRevenue: 0.0,
          averagePartySize: 0.0,
          occupancyRate: 0.0,
          cancellationRate: 0.0,
          noShowRate: 0.0,
          totalGuests: 0,
          averageReservationValue: 0.0,
        ),
        periodData: [],
        tableData: [],
        notes: 'Rapport généré en mode hors ligne',
      );
    }
  }

  @override
  Future<List<Report>> getSavedReports() async {
    try {
      // Essayer d'abord l'API
      final remoteReports = await _remoteDataSource.getSavedReports();
      
      // Sauvegarder localement
      for (final report in remoteReports) {
        await _localDataSource.saveReport(report);
      }
      
      return remoteReports;
    } catch (e) {
      // En cas d'erreur, retourner les rapports locaux
      return await _localDataSource.getSavedReports();
    }
  }

  @override
  Future<void> saveReport(Report report) async {
    try {
      // Sauvegarder via l'API
      await _remoteDataSource.saveReport(report);
    } catch (e) {
      // En cas d'erreur, sauvegarder localement
      await _localDataSource.saveReport(report);
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      // Supprimer via l'API
      await _remoteDataSource.deleteReport(reportId);
    } catch (e) {
      // En cas d'erreur, supprimer localement
      await _localDataSource.deleteReport(reportId);
    }
  }

  @override
  Future<String> exportReport(Report report, ExportOptions options) async {
    try {
      // Sauvegarder les options d'export
      await _localDataSource.saveExportOptions(options);
      
      // Exporter via l'API
      return await _remoteDataSource.exportReport(report, options);
    } catch (e) {
      throw Exception('Error exporting report: $e');
    }
  }

  @override
  Future<ReportMetrics> getMetrics(ReportFilters filters) async {
    try {
      return await _remoteDataSource.getMetrics(filters);
    } catch (e) {
      // Retourner des métriques vides en cas d'erreur
      return const ReportMetrics(
        totalReservations: 0,
        confirmedReservations: 0,
        cancelledReservations: 0,
        noShowReservations: 0,
        totalRevenue: 0.0,
        averagePartySize: 0.0,
        occupancyRate: 0.0,
        cancellationRate: 0.0,
        noShowRate: 0.0,
        totalGuests: 0,
        averageReservationValue: 0.0,
      );
    }
  }

  @override
  Future<List<ReportPeriodData>> getPeriodData(ReportFilters filters) async {
    try {
      return await _remoteDataSource.getPeriodData(filters);
    } catch (e) {
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  @override
  Future<List<ReportTableData>> getTableData(ReportFilters filters) async {
    try {
      return await _remoteDataSource.getTableData(filters);
    } catch (e) {
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  /// Génère un titre de rapport basé sur les filtres
  String _generateReportTitle(ReportFilters filters) {
    final now = DateTime.now();
    final startDate = filters.startDate ?? now;
    final endDate = filters.endDate ?? now;
    
    switch (filters.reportType) {
      case ReportType.daily:
        return 'Rapport quotidien - ${_formatDate(startDate)}';
      case ReportType.weekly:
        return 'Rapport hebdomadaire - ${_formatDate(startDate)} à ${_formatDate(endDate)}';
      case ReportType.monthly:
        return 'Rapport mensuel - ${_formatDate(startDate)}';
      case ReportType.custom:
        return 'Rapport personnalisé - ${_formatDate(startDate)} à ${_formatDate(endDate)}';
    }
  }

  /// Formate une date pour l'affichage
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

