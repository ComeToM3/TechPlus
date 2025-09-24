import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../domain/entities/analytics_entity.dart';
import '../../providers/analytics_provider.dart';

/// Widget pour afficher les données de comparaison
class ComparisonWidget extends ConsumerWidget {
  final AnalyticsFilters filters;

  const ComparisonWidget({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final comparisonAsync = ref.watch(comparisonDataProvider(filters));

    return BentoCard(
      title: l10n.comparisonData,
      subtitle: l10n.comparisonDataDescription,
      child: comparisonAsync.when(
        data: (data) => _buildComparisonContent(context, l10n, data),
        loading: () => _buildLoadingContent(context, l10n),
        error: (error, stack) => _buildErrorContent(context, l10n, error.toString()),
      ),
    );
  }

  Widget _buildComparisonContent(BuildContext context, AppLocalizations l10n, List<ComparisonData> data) {
    return Column(
      children: [
        // Graphique de comparaison
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
          child: _buildComparisonChart(context, data),
        ),
        const SizedBox(height: 16),
        // Données de comparaison
        _buildComparisonList(context, l10n, data),
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

  Widget _buildComparisonChart(BuildContext context, List<ComparisonData> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return CustomPaint(
      painter: ComparisonChartPainter(data: data),
      size: Size.infinite,
    );
  }

  Widget _buildComparisonList(BuildContext context, AppLocalizations l10n, List<ComparisonData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.comparisonDetails,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...data.take(5).map((item) => _buildComparisonItem(context, item)),
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

  Widget _buildComparisonItem(BuildContext context, ComparisonData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getComparisonColor(item.period),
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
            '${item.value.toStringAsFixed(2)} €',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.changePercentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: item.changePercentage >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getComparisonColor(String period) {
    switch (period.toLowerCase()) {
      case 'today':
        return Colors.blue;
      case 'yesterday':
        return Colors.green;
      case 'last week':
        return Colors.orange;
      case 'last month':
        return Colors.purple;
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
          l10n.loadingComparison,
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
          l10n.errorLoadingComparison,
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

/// Painter pour le graphique de comparaison
class ComparisonChartPainter extends CustomPainter {
  final List<ComparisonData> data;

  ComparisonChartPainter({required this.data});

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

    // Calculer les barres
    final barWidth = size.width / data.length * 0.8;
    final barSpacing = size.width / data.length * 0.2;

    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth + barSpacing) + barSpacing / 2;
      final barHeight = (data[i].value / data.map((d) => d.value).reduce((a, b) => a > b ? a : b)) * size.height;
      final y = size.height - barHeight;

      // Dessiner la barre
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, paint);

      // Dessiner la valeur
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i].value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
