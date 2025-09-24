import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../shared/widgets/cards/bento_card.dart';
import '../../../../../shared/widgets/buttons/simple_button.dart';
import '../../../domain/entities/analytics_entity.dart';
import '../../providers/analytics_provider.dart';

/// Widget pour afficher les KPIs principaux
class KPIsWidget extends ConsumerWidget {
  final AnalyticsFilters filters;

  const KPIsWidget({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final kpisAsync = ref.watch(mainKPIsProvider(filters));

    return BentoCard(
      title: l10n.mainKPIs,
      subtitle: l10n.mainKPIsDescription,
      child: kpisAsync.when(
        data: (kpis) => _buildKPIsContent(context, l10n, kpis),
        loading: () => _buildLoadingContent(context, l10n),
        error: (error, stack) => _buildErrorContent(context, l10n, error.toString()),
      ),
    );
  }

  Widget _buildKPIsContent(BuildContext context, AppLocalizations l10n, MainKPIs kpis) {
    return Column(
      children: [
        // Métriques principales
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                l10n.totalRevenue,
                '${kpis.totalRevenue.toStringAsFixed(2)} €',
                Icons.euro,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                l10n.totalReservations,
                kpis.totalReservations.toString(),
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                l10n.averageOrderValue,
                '${kpis.averageOrderValue.toStringAsFixed(2)} €',
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                l10n.occupancyRate,
                '${(kpis.occupancyRate * 100).toStringAsFixed(1)}%',
                Icons.people,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                l10n.cancellationRate,
                '${(kpis.cancellationRate * 100).toStringAsFixed(1)}%',
                Icons.cancel,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                l10n.noShowRate,
                '${(kpis.noShowRate * 100).toStringAsFixed(1)}%',
                Icons.person_off,
                Colors.grey,
              ),
            ),
          ],
        ),
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

  Widget _buildKPICard(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          l10n.loadingKPIs,
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
          l10n.errorLoadingKPIs,
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
