import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../domain/entities/report_entity.dart';

/// Widget pour afficher les graphiques de rapport
class ReportChartsWidget extends ConsumerWidget {
  final List<ReportPeriodData> periodData;
  final List<ReportTableData> tableData;

  const ReportChartsWidget({
    super.key,
    required this.periodData,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Graphique des réservations par période
        _buildReservationsChart(context, l10n),
        const SizedBox(height: 24),
        
        // Graphique des revenus par période
        _buildRevenueChart(context, l10n),
        const SizedBox(height: 24),
        
        // Graphique des tables
        _buildTablesChart(context, l10n),
      ],
    );
  }

  Widget _buildReservationsChart(BuildContext context, AppLocalizations l10n) {
    return BentoCard(
      title: l10n.reservationsChart,
      subtitle: l10n.reservationsChartDescription,
      child: SizedBox(
        height: 200,
        child: _buildLineChart(
          context,
          periodData,
          (data) => data.reservations.toDouble(),
          l10n.reservations,
          Colors.blue,
        ),
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context, AppLocalizations l10n) {
    return BentoCard(
      title: l10n.revenueChart,
      subtitle: l10n.revenueChartDescription,
      child: SizedBox(
        height: 200,
        child: _buildLineChart(
          context,
          periodData,
          (data) => data.revenue,
          l10n.revenue,
          Colors.green,
        ),
      ),
    );
  }

  Widget _buildTablesChart(BuildContext context, AppLocalizations l10n) {
    return BentoCard(
      title: l10n.tablesChart,
      subtitle: l10n.tablesChartDescription,
      child: SizedBox(
        height: 200,
        child: _buildBarChart(
          context,
          tableData,
          (data) => data.reservations.toDouble(),
          l10n.reservations,
          Colors.orange,
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    List<ReportPeriodData> data,
    double Function(ReportPeriodData) valueExtractor,
    String label,
    Color color,
  ) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      painter: LineChartPainter(
        data: data,
        valueExtractor: valueExtractor,
        color: color,
        label: label,
      ),
      child: Container(),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    List<ReportTableData> data,
    double Function(ReportTableData) valueExtractor,
    String label,
    Color color,
  ) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      painter: BarChartPainter(
        data: data,
        valueExtractor: valueExtractor,
        color: color,
        label: label,
      ),
      child: Container(),
    );
  }
}

/// Painter pour le graphique linéaire
class LineChartPainter extends CustomPainter {
  final List<ReportPeriodData> data;
  final double Function(ReportPeriodData) valueExtractor;
  final Color color;
  final String label;

  LineChartPainter({
    required this.data,
    required this.valueExtractor,
    required this.color,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxValue = data.map(valueExtractor).reduce((a, b) => a > b ? a : b);
    final minValue = data.map(valueExtractor).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    final pointWidth = size.width / (data.length - 1);
    final pointHeight = size.height - 40; // Marge pour les labels

    // Créer le chemin de la ligne
    for (int i = 0; i < data.length; i++) {
      final value = valueExtractor(data[i]);
      final normalizedValue = valueRange > 0 ? (value - minValue) / valueRange : 0.5;
      
      final x = i * pointWidth;
      final y = size.height - 20 - (normalizedValue * pointHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - 20);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fermer le chemin de remplissage
    fillPath.lineTo(size.width, size.height - 20);
    fillPath.close();

    // Dessiner le remplissage
    canvas.drawPath(fillPath, fillPaint);

    // Dessiner la ligne
    canvas.drawPath(path, paint);

    // Dessiner les points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final value = valueExtractor(data[i]);
      final normalizedValue = valueRange > 0 ? (value - minValue) / valueRange : 0.5;
      
      final x = i * pointWidth;
      final y = size.height - 20 - (normalizedValue * pointHeight);

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour le graphique en barres
class BarChartPainter extends CustomPainter {
  final List<ReportTableData> data;
  final double Function(ReportTableData) valueExtractor;
  final Color color;
  final String label;

  BarChartPainter({
    required this.data,
    required this.valueExtractor,
    required this.color,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.map(valueExtractor).reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / data.length;
    final barHeight = size.height - 40; // Marge pour les labels

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final value = valueExtractor(data[i]);
      final normalizedHeight = maxValue > 0 ? (value / maxValue) * barHeight : 0;
      
      final x = i * barWidth + barWidth * 0.1; // Marge entre les barres
      final y = size.height - 20 - normalizedHeight;
      final width = barWidth * 0.8; // Largeur des barres

      canvas.drawRect(
        Rect.fromLTWH(x, y, width, normalizedHeight.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
