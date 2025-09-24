import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../widgets/restaurant_info_widget.dart';
import '../widgets/opening_hours_widget.dart';
import '../widgets/payment_settings_widget.dart';
import '../widgets/cancellation_policy_widget.dart';

/// Page de configuration du restaurant
class RestaurantConfigPage extends ConsumerStatefulWidget {
  const RestaurantConfigPage({super.key});

  @override
  ConsumerState<RestaurantConfigPage> createState() => _RestaurantConfigPageState();
}

class _RestaurantConfigPageState extends ConsumerState<RestaurantConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.restaurantConfiguration),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.info_outline),
              text: l10n.generalInformation,
            ),
            Tab(
              icon: const Icon(Icons.schedule),
              text: l10n.openingHours,
            ),
            Tab(
              icon: const Icon(Icons.payment),
              text: l10n.paymentSettings,
            ),
            Tab(
              icon: const Icon(Icons.cancel_outlined),
              text: l10n.cancellationPolicy,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RestaurantInfoWidget(),
          OpeningHoursWidget(),
          PaymentSettingsWidget(),
          CancellationPolicyWidget(),
        ],
      ),
    );
  }
}

