import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../domain/entities/report_entity.dart';

/// Widget pour afficher les métriques de rapport
class ReportMetricsWidget extends ConsumerWidget {
  final ReportMetrics metrics;

  const ReportMetricsWidget({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return BentoCard(
      title: l10n.reportMetrics,
      subtitle: l10n.reportMetricsDescription,
      child: Column(
        children: [
          // Métriques principales
          _buildMainMetrics(context, l10n),
          const SizedBox(height: 24),
          
          // Métriques détaillées
          _buildDetailedMetrics(context, l10n),
        ],
      ),
    );
  }

  Widget _buildMainMetrics(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mainMetrics,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              context,
              l10n.totalReservations,
              metrics.totalReservations.toString(),
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildMetricCard(
              context,
              l10n.totalRevenue,
              '${metrics.totalRevenue.toStringAsFixed(2)} €',
              Icons.euro,
              Colors.green,
            ),
            _buildMetricCard(
              context,
              l10n.occupancyRate,
              '${(metrics.occupancyRate * 100).toStringAsFixed(1)}%',
              Icons.people,
              Colors.orange,
            ),
            _buildMetricCard(
              context,
              l10n.averagePartySize,
              metrics.averagePartySize.toStringAsFixed(1),
              Icons.group,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailedMetrics,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildDetailedMetricRow(
          context,
          l10n.confirmedReservations,
          metrics.confirmedReservations.toString(),
          Colors.green,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.cancelledReservations,
          metrics.cancelledReservations.toString(),
          Colors.red,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.noShowReservations,
          metrics.noShowReservations.toString(),
          Colors.orange,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.cancellationRate,
          '${(metrics.cancellationRate * 100).toStringAsFixed(1)}%',
          Colors.red.shade300,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.noShowRate,
          '${(metrics.noShowRate * 100).toStringAsFixed(1)}%',
          Colors.orange.shade300,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.totalGuests,
          metrics.totalGuests.toString(),
          Colors.blue,
        ),
        _buildDetailedMetricRow(
          context,
          l10n.averageReservationValue,
          '${metrics.averageReservationValue.toStringAsFixed(2)} €',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
