import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/datasources/report_local_datasource.dart';

/// Provider pour le repository des rapports
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);
  
  return sharedPreferencesAsync.when(
    data: (sharedPreferences) => ReportRepositoryImpl(
      ReportRemoteDataSource(apiClient),
      ReportLocalDataSource(sharedPreferences),
    ),
    loading: () => throw Exception('SharedPreferences not available'),
    error: (error, stack) => throw Exception('Failed to initialize SharedPreferences: $error'),
  );
});

/// Provider pour générer un rapport
final generateReportProvider = FutureProvider.family<Report, ReportFilters>((ref, filters) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.generateReport(filters);
});

/// Provider pour les rapports sauvegardés
final savedReportsProvider = FutureProvider<List<Report>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getSavedReports();
});

/// Provider pour sauvegarder un rapport
final saveReportProvider = FutureProvider.family<void, Report>((ref, report) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.saveReport(report);
});

/// Provider pour supprimer un rapport
final deleteReportProvider = FutureProvider.family<void, String>((ref, reportId) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.deleteReport(reportId);
});

/// Provider pour exporter un rapport
final exportReportProvider = FutureProvider.family<String, ({Report report, ExportOptions options})>((ref, params) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.exportReport(params.report, params.options);
});

/// Provider pour les métriques de rapport
final reportMetricsProvider = FutureProvider.family<ReportMetrics, ReportFilters>((ref, filters) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getMetrics(filters);
});

/// Provider pour les données par période
final reportPeriodDataProvider = FutureProvider.family<List<ReportPeriodData>, ReportFilters>((ref, filters) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getPeriodData(filters);
});

/// Provider pour les données par table
final reportTableDataProvider = FutureProvider.family<List<ReportTableData>, ReportFilters>((ref, filters) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getTableData(filters);
});

/// Provider pour les filtres de rapport actuels
final reportFiltersProvider = StateProvider<ReportFilters>((ref) {
  return ReportFilters(
    reportType: ReportType.daily,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );
});

/// Provider pour les options d'export actuelles
final exportOptionsProvider = StateProvider<ExportOptions>((ref) {
  return const ExportOptions(
    format: ExportFormat.pdf,
    includeCharts: true,
    includeDetails: true,
    includeMetrics: true,
  );
});

/// Provider pour l'état de génération de rapport
final reportGenerationStateProvider = StateProvider<ReportGenerationState>((ref) {
  return const ReportGenerationState.idle();
});

/// État de génération de rapport
sealed class ReportGenerationState {
  const ReportGenerationState();
  
  const factory ReportGenerationState.idle() = _Idle;
  const factory ReportGenerationState.generating() = _Generating;
  const factory ReportGenerationState.success(Report report) = _Success;
  const factory ReportGenerationState.error(String message) = _Error;
}

class _Idle extends ReportGenerationState {
  const _Idle();
}

class _Generating extends ReportGenerationState {
  const _Generating();
}

class _Success extends ReportGenerationState {
  final Report report;
  const _Success(this.report);
}

class _Error extends ReportGenerationState {
  final String message;
  const _Error(this.message);
}
