import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../domain/entities/analytics_entity.dart';
import '../../providers/analytics_provider.dart';

/// Widget pour afficher les prédictions
class PredictionsWidget extends ConsumerWidget {
  final AnalyticsFilters filters;

  const PredictionsWidget({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final predictionsAsync = ref.watch(predictionsProvider(filters));

    return BentoCard(
      title: l10n.predictions,
      subtitle: l10n.predictionsDescription,
      child: predictionsAsync.when(
        data: (data) => _buildPredictionsContent(context, l10n, data),
        loading: () => _buildLoadingContent(context, l10n),
        error: (error, stack) => _buildErrorContent(context, l10n, error.toString()),
      ),
    );
  }

  Widget _buildPredictionsContent(BuildContext context, AppLocalizations l10n, List<PredictionData> data) {
    return Column(
      children: [
        // Graphique des prédictions
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
          child: _buildPredictionsChart(context, data),
        ),
        const SizedBox(height: 16),
        // Liste des prédictions
        _buildPredictionsList(context, l10n, data),
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

  Widget _buildPredictionsChart(BuildContext context, List<PredictionData> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return CustomPaint(
      painter: PredictionsChartPainter(data: data),
      size: Size.infinite,
    );
  }

  Widget _buildPredictionsList(BuildContext context, AppLocalizations l10n, List<PredictionData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.predictionDetails,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...data.take(5).map((item) => _buildPredictionItem(context, item)),
        if (data.length > 5)
          TextButton(
            onPressed: () {
              // Action pour voir plus
            },
            child: Text(l10n.viewMore),
          ),
      ],
    );
  }

  Widget _buildPredictionItem(BuildContext context, PredictionData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPredictionColor(item.confidence),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.period,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${item.predictedValue.toStringAsFixed(2)} €',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(item.confidence * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getPredictionColor(item.confidence),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPredictionColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLoadingContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          l10n.loadingPredictions,
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
          l10n.errorLoadingPredictions,
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

/// Painter pour le graphique des prédictions
class PredictionsChartPainter extends CustomPainter {
  final List<PredictionData> data;

  PredictionsChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

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
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].predictedValue / data.map((d) => d.predictedValue).reduce((a, b) => a > b ? a : b)) * size.height;
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
