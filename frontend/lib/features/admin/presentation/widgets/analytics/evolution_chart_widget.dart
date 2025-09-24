import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../domain/entities/analytics_entity.dart';
import '../../providers/analytics_provider.dart';

/// Widget pour afficher les graphiques d'évolution
class EvolutionChartWidget extends ConsumerWidget {
  final AnalyticsFilters filters;

  const EvolutionChartWidget({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final evolutionAsync = ref.watch(evolutionMetricsProvider(filters));

    return BentoCard(
      title: l10n.evolutionMetrics,
      subtitle: l10n.evolutionMetricsDescription,
      child: evolutionAsync.when(
        data: (metrics) => _buildEvolutionContent(context, l10n, metrics),
        loading: () => _buildLoadingContent(context, l10n),
        error: (error, stack) => _buildErrorContent(context, l10n, error.toString()),
      ),
    );
  }

  Widget _buildEvolutionContent(BuildContext context, AppLocalizations l10n, List<AnalyticsMetrics> metrics) {
    return Column(
      children: [
        // Graphique d'évolution
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: _buildChart(context, metrics),
        ),
        const SizedBox(height: 16),
        // Métriques détaillées
        _buildMetricsList(context, l10n, metrics),
        const SizedBox(height: 16),
        // Actions
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                onPressed: () {
                  // Action pour voir les détails
                },
                text: l10n.viewDetails,
                type: ButtonType.primary,
                size: ButtonSize.medium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SimpleButton(
                onPressed: () {
                  // Action pour exporter
                },
                text: l10n.export,
                type: ButtonType.secondary,
                size: ButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<AnalyticsMetrics> metrics) {
    if (metrics.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // Trouver les valeurs min et max
    double minValue = metrics.map((m) => m.value).reduce((a, b) => a < b ? a : b);
    double maxValue = metrics.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    
    // Ajouter une marge
    double range = maxValue - minValue;
    minValue -= range * 0.1;
    maxValue += range * 0.1;

    return CustomPaint(
      painter: EvolutionChartPainter(
        metrics: metrics,
        minValue: minValue,
        maxValue: maxValue,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildMetricsList(BuildContext context, AppLocalizations l10n, List<AnalyticsMetrics> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailedMetrics,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...metrics.take(5).map((metric) => _buildMetricItem(context, metric)),
        if (metrics.length > 5)
          TextButton(
            onPressed: () {
              // Action pour voir plus
            },
            child: Text(l10n.viewMore),
          ),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, AnalyticsMetrics metric) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getMetricColor(metric.metric),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              metric.metric,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${metric.value.toStringAsFixed(2)} €',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(String metric) {
    switch (metric.toLowerCase()) {
      case 'revenue':
        return Colors.green;
      case 'reservations':
        return Colors.blue;
      case 'occupancy':
        return Colors.orange;
      case 'cancellation':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          l10n.loadingEvolution,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, AppLocalizations l10n, String error) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.errorLoadingEvolution,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SimpleButton(
          onPressed: () {
            // Retry action
          },
          text: l10n.retry,
          type: ButtonType.primary,
          size: ButtonSize.medium,
        ),
      ],
    );
  }
}

/// Painter pour le graphique d'évolution
class EvolutionChartPainter extends CustomPainter {
  final List<AnalyticsMetrics> metrics;
  final double minValue;
  final double maxValue;

  EvolutionChartPainter({
    required this.metrics,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Calculer les points
    final points = <Offset>[];
    for (int i = 0; i < metrics.length; i++) {
      final x = (i / (metrics.length - 1)) * size.width;
      final y = size.height - ((metrics[i].value - minValue) / (maxValue - minValue)) * size.height;
      points.add(Offset(x, y));
    }

    // Dessiner la ligne
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Dessiner le remplissage
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Dessiner les points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
