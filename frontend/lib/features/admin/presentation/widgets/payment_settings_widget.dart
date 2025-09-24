import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import '../providers/restaurant_config_provider.dart';

/// Widget pour la gestion des paramètres de paiement
class PaymentSettingsWidget extends ConsumerStatefulWidget {
  const PaymentSettingsWidget({super.key});

  @override
  ConsumerState<PaymentSettingsWidget> createState() => _PaymentSettingsWidgetState();
}

class _PaymentSettingsWidgetState extends ConsumerState<PaymentSettingsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _stripePublicKeyController = TextEditingController();
  final _stripeSecretKeyController = TextEditingController();
  final _paypalClientIdController = TextEditingController();
  final _depositPercentageController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  bool _isLoading = false;
  bool _isStripeEnabled = false;
  bool _isPayPalEnabled = false;
  bool _isCashEnabled = true;
  bool _isCardEnabled = true;
  bool _isTaxIncluded = false;
  String _currency = 'EUR';

  final List<String> _currencies = ['EUR', 'USD', 'GBP', 'CAD'];

  @override
  void initState() {
    super.initState();
    _loadPaymentSettings();
  }

  @override
  void dispose() {
    _stripePublicKeyController.dispose();
    _stripeSecretKeyController.dispose();
    _paypalClientIdController.dispose();
    _depositPercentageController.dispose();
    _taxRateController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  void _loadPaymentSettings() {
    final settingsAsync = ref.read(paymentSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _isStripeEnabled = settings.isStripeEnabled;
        _isPayPalEnabled = settings.isPayPalEnabled;
        _isCashEnabled = settings.isCashEnabled;
        _isCardEnabled = settings.isCardEnabled;
        _isTaxIncluded = settings.isTaxIncluded;
        _currency = settings.currency;
        _stripePublicKeyController.text = settings.stripePublicKey ?? '';
        _stripeSecretKeyController.text = settings.stripeSecretKey ?? '';
        _paypalClientIdController.text = settings.paypalClientId ?? '';
        _depositPercentageController.text = settings.depositPercentage.toString();
        _taxRateController.text = settings.taxRate.toString();
        _paymentTermsController.text = settings.paymentTerms;
      });
    });
  }

  Future<void> _savePaymentSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final settings = PaymentSettings(
        isStripeEnabled: _isStripeEnabled,
        stripePublicKey: _stripePublicKeyController.text.isNotEmpty 
            ? _stripePublicKeyController.text 
            : null,
        stripeSecretKey: _stripeSecretKeyController.text.isNotEmpty 
            ? _stripeSecretKeyController.text 
            : null,
        isPayPalEnabled: _isPayPalEnabled,
        paypalClientId: _paypalClientIdController.text.isNotEmpty 
            ? _paypalClientIdController.text 
            : null,
        isCashEnabled: _isCashEnabled,
        isCardEnabled: _isCardEnabled,
        depositPercentage: double.parse(_depositPercentageController.text),
        currency: _currency,
        taxRate: double.parse(_taxRateController.text),
        isTaxIncluded: _isTaxIncluded,
        paymentTerms: _paymentTermsController.text,
      );

      await ref.read(paymentSettingsNotifierProvider.notifier).updatePaymentSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentSettingsSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Méthodes de paiement
            BentoCard(
              title: l10n.paymentMethods,
              child: Column(
                children: [
                  // Stripe
                  SwitchListTile(
                    title: Text(l10n.stripe),
                    subtitle: Text(l10n.stripeDescription),
                    value: _isStripeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isStripeEnabled = value;
                      });
                    },
                  ),
                  if (_isStripeEnabled) ...[
                    TextFormField(
                      controller: _stripePublicKeyController,
                      decoration: InputDecoration(
                        labelText: l10n.stripePublicKey,
                        prefixIcon: const Icon(Icons.key),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stripeSecretKeyController,
                      decoration: InputDecoration(
                        labelText: l10n.stripeSecretKey,
                        prefixIcon: const Icon(Icons.key),
                      ),
                      obscureText: true,
                    ),
                  ],

                  const Divider(),

                  // PayPal
                  SwitchListTile(
                    title: Text(l10n.paypal),
                    subtitle: Text(l10n.paypalDescription),
                    value: _isPayPalEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isPayPalEnabled = value;
                      });
                    },
                  ),
                  if (_isPayPalEnabled) ...[
                    TextFormField(
                      controller: _paypalClientIdController,
                      decoration: InputDecoration(
                        labelText: l10n.paypalClientId,
                        prefixIcon: const Icon(Icons.key),
                      ),
                    ),
                  ],

                  const Divider(),

                  // Espèces
                  SwitchListTile(
                    title: Text(l10n.cash),
                    subtitle: Text(l10n.cashDescription),
                    value: _isCashEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isCashEnabled = value;
                      });
                    },
                  ),

                  // Carte
                  SwitchListTile(
                    title: Text(l10n.card),
                    subtitle: Text(l10n.cardDescription),
                    value: _isCardEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isCardEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Paramètres financiers
            BentoCard(
              title: l10n.financialSettings,
              child: Column(
                children: [
                  // Pourcentage d'acompte
                  TextFormField(
                    controller: _depositPercentageController,
                    decoration: InputDecoration(
                      labelText: l10n.depositPercentage,
                      prefixIcon: const Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      final percentage = double.tryParse(value);
                      if (percentage == null || percentage < 0 || percentage > 100) {
                        return l10n.invalidPercentage;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Taux de taxe
                  TextFormField(
                    controller: _taxRateController,
                    decoration: InputDecoration(
                      labelText: l10n.taxRate,
                      prefixIcon: const Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0 || rate > 100) {
                        return l10n.invalidPercentage;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Taxe incluse
                  SwitchListTile(
                    title: Text(l10n.taxIncluded),
                    subtitle: Text(l10n.taxIncludedDescription),
                    value: _isTaxIncluded,
                    onChanged: (value) {
                      setState(() {
                        _isTaxIncluded = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Devise
                  DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: InputDecoration(
                      labelText: l10n.currency,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _currency = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Conditions de paiement
            BentoCard(
              title: l10n.paymentTerms,
              child: TextFormField(
                controller: _paymentTermsController,
                decoration: InputDecoration(
                  labelText: l10n.paymentTerms,
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de sauvegarde
            Center(
              child: SimpleButton(
                onPressed: _isLoading ? null : _savePaymentSettings,
                text: _isLoading ? l10n.saving : l10n.save,
                type: ButtonType.primary,
                size: ButtonSize.large,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

