import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/layouts/responsive_layout.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/report_provider.dart';
import '../widgets/reports/report_filters_widget.dart';
import '../widgets/reports/report_metrics_widget.dart';
import '../widgets/reports/report_charts_widget.dart';

/// Page principale pour les rapports
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportFilters _currentFilters = ReportFilters(
    reportType: ReportType.daily,
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
            tooltip: l10n.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCurrentReport,
            tooltip: l10n.export,
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres de rapport
              ReportFiltersWidget(
                initialFilters: _currentFilters,
                onFiltersChanged: _onFiltersChanged,
              ),
              const SizedBox(height: 24),
              
              // Contenu du rapport
              _buildReportContent(l10n),
            ],
          ),
        ),
        tablet: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres de rapport
              ReportFiltersWidget(
                initialFilters: _currentFilters,
                onFiltersChanged: _onFiltersChanged,
              ),
              const SizedBox(height: 24),
              
              // Contenu du rapport
              _buildReportContent(l10n),
            ],
          ),
        ),
        desktop: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres de rapport
              ReportFiltersWidget(
                initialFilters: _currentFilters,
                onFiltersChanged: _onFiltersChanged,
              ),
              const SizedBox(height: 24),
              
              // Contenu du rapport
              _buildReportContent(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final reportAsync = ref.watch(generateReportProvider(_currentFilters));

        return reportAsync.when(
          data: (report) => _buildReportData(report, l10n),
          loading: () => _buildLoadingState(l10n),
          error: (error, stack) => _buildErrorState(error.toString(), l10n),
        );
      },
    );
  }

  Widget _buildReportData(Report report, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du rapport
        _buildReportHeader(report, l10n),
        const SizedBox(height: 24),
        
        // Métriques
        ReportMetricsWidget(metrics: report.metrics),
        const SizedBox(height: 24),
        
        // Graphiques
        ReportChartsWidget(
          periodData: report.periodData,
          tableData: report.tableData,
        ),
        const SizedBox(height: 24),
        
        // Actions du rapport
        _buildReportActions(report, l10n),
      ],
    );
  }

  Widget _buildReportHeader(Report report, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Généré le ${_formatDateTime(report.generatedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildReportTypeChip(report.type, l10n),
              ],
            ),
            if (report.notes != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.notes!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeChip(ReportType type, AppLocalizations l10n) {
    Color color;
    String label;
    
    switch (type) {
      case ReportType.daily:
        color = Colors.blue;
        label = l10n.daily;
        break;
      case ReportType.weekly:
        color = Colors.green;
        label = l10n.weekly;
        break;
      case ReportType.monthly:
        color = Colors.orange;
        label = l10n.monthly;
        break;
      case ReportType.custom:
        color = Colors.purple;
        label = l10n.custom;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReportActions(Report report, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportActions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SimpleButton(
                  onPressed: () => _saveReport(report),
                  text: l10n.saveReport,
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  icon: Icons.save,
                ),
                SimpleButton(
                  onPressed: () => _exportReport(report, ExportFormat.pdf),
                  text: l10n.exportPDF,
                  type: ButtonType.secondary,
                  size: ButtonSize.medium,
                  icon: Icons.picture_as_pdf,
                ),
                SimpleButton(
                  onPressed: () => _exportReport(report, ExportFormat.excel),
                  text: l10n.exportExcel,
                  type: ButtonType.secondary,
                  size: ButtonSize.medium,
                  icon: Icons.table_chart,
                ),
                SimpleButton(
                  onPressed: () => _exportReport(report, ExportFormat.csv),
                  text: l10n.exportCSV,
                  type: ButtonType.secondary,
                  size: ButtonSize.medium,
                  icon: Icons.file_download,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.generatingReport,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorGeneratingReport,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SimpleButton(
              onPressed: _refreshReports,
              text: l10n.retry,
              type: ButtonType.primary,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  void _onFiltersChanged(ReportFilters filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _refreshReports() {
    setState(() {
      // Force refresh by updating the filters
      _currentFilters = _currentFilters.copyWith();
    });
  }

  void _saveReport(Report report) async {
    try {
      await ref.read(saveReportProvider(report).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reportSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportReport(Report report, ExportFormat format) async {
    try {
      final options = ExportOptions(
        format: format,
        includeCharts: true,
        includeDetails: true,
        includeMetrics: true,
      );
      
      final downloadUrl = await ref.read(
        exportReportProvider((report: report, options: options)).future,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export disponible: $downloadUrl'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportCurrentReport() {
    // Export du rapport actuel en PDF par défaut
    final reportAsync = ref.read(generateReportProvider(_currentFilters));
    reportAsync.whenData((report) {
      _exportReport(report, ExportFormat.pdf);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
