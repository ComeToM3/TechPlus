import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import '../providers/restaurant_config_provider.dart';

/// Widget pour la gestion de la politique d'annulation
class CancellationPolicyWidget extends ConsumerStatefulWidget {
  const CancellationPolicyWidget({super.key});

  @override
  ConsumerState<CancellationPolicyWidget> createState() => _CancellationPolicyWidgetState();
}

class _CancellationPolicyWidgetState extends ConsumerState<CancellationPolicyWidget> {
  final _formKey = GlobalKey<FormState>();
  final _policyDescriptionController = TextEditingController();
  final _freeCancellationHoursController = TextEditingController();
  final _cancellationFeePercentageController = TextEditingController();

  bool _isLoading = false;
  bool _isRefundable = true;
  List<CancellationRule> _rules = [];

  @override
  void initState() {
    super.initState();
    _loadCancellationPolicy();
  }

  @override
  void dispose() {
    _policyDescriptionController.dispose();
    _freeCancellationHoursController.dispose();
    _cancellationFeePercentageController.dispose();
    super.dispose();
  }

  void _loadCancellationPolicy() {
    final policyAsync = ref.read(cancellationPolicyProvider);
    policyAsync.whenData((policy) {
      setState(() {
        _isRefundable = policy.isRefundable;
        _freeCancellationHoursController.text = policy.freeCancellationHours.toString();
        _cancellationFeePercentageController.text = policy.cancellationFeePercentage.toString();
        _policyDescriptionController.text = policy.policyDescription;
        _rules = List.from(policy.rules);
      });
    });
  }

  void _addRule() {
    setState(() {
      _rules.add(CancellationRule(
        hoursBeforeReservation: 24,
        feePercentage: 0.0,
        description: '',
      ));
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  void _updateRule(int index, CancellationRule rule) {
    setState(() {
      _rules[index] = rule;
    });
  }

  Future<void> _saveCancellationPolicy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final policy = CancellationPolicy(
        isRefundable: _isRefundable,
        freeCancellationHours: int.parse(_freeCancellationHoursController.text),
        cancellationFeePercentage: double.parse(_cancellationFeePercentageController.text),
        policyDescription: _policyDescriptionController.text,
        rules: _rules,
      );

      await ref.read(cancellationPolicyNotifierProvider.notifier).updateCancellationPolicy(policy);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cancellationPolicySaved),
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
            // Configuration générale
            BentoCard(
              title: l10n.generalSettings,
              child: Column(
                children: [
                  // Remboursable
                  SwitchListTile(
                    title: Text(l10n.refundable),
                    subtitle: Text(l10n.refundableDescription),
                    value: _isRefundable,
                    onChanged: (value) {
                      setState(() {
                        _isRefundable = value;
                      });
                    },
                  ),

                  if (_isRefundable) ...[
                    const SizedBox(height: 16),
                    
                    // Annulation gratuite
                    TextFormField(
                      controller: _freeCancellationHoursController,
                      decoration: InputDecoration(
                        labelText: l10n.freeCancellationHours,
                        prefixIcon: const Icon(Icons.access_time),
                        suffixText: l10n.hours,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.requiredField;
                        }
                        final hours = int.tryParse(value);
                        if (hours == null || hours < 0) {
                          return l10n.invalidHours;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Pourcentage de frais d'annulation
                    TextFormField(
                      controller: _cancellationFeePercentageController,
                      decoration: InputDecoration(
                        labelText: l10n.cancellationFeePercentage,
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
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description de la politique
            BentoCard(
              title: l10n.policyDescription,
              child: TextFormField(
                controller: _policyDescriptionController,
                decoration: InputDecoration(
                  labelText: l10n.policyDescription,
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

            const SizedBox(height: 16),

            // Règles d'annulation
            BentoCard(
              title: l10n.cancellationRules,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cancellationRules,
                        style: theme.textTheme.titleMedium,
                      ),
                      SimpleButton(
                        onPressed: _addRule,
                        text: l10n.addRule,
                        type: ButtonType.secondary,
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_rules.isEmpty)
                    Text(
                      l10n.noRules,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...List.generate(_rules.length, (index) {
                      return _CancellationRuleWidget(
                        rule: _rules[index],
                        onChanged: (updatedRule) => _updateRule(index, updatedRule),
                        onDelete: () => _removeRule(index),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de sauvegarde
            Center(
              child: SimpleButton(
                onPressed: _isLoading ? null : _saveCancellationPolicy,
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

/// Widget pour une règle d'annulation
class _CancellationRuleWidget extends StatefulWidget {
  final CancellationRule rule;
  final Function(CancellationRule) onChanged;
  final VoidCallback onDelete;

  const _CancellationRuleWidget({
    required this.rule,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_CancellationRuleWidget> createState() => _CancellationRuleWidgetState();
}

class _CancellationRuleWidgetState extends State<_CancellationRuleWidget> {
  late int _hoursBeforeReservation;
  late double _feePercentage;
  late String _description;

  @override
  void initState() {
    super.initState();
    _hoursBeforeReservation = widget.rule.hoursBeforeReservation;
    _feePercentage = widget.rule.feePercentage;
    _description = widget.rule.description;
  }

  void _updateRule() {
    widget.onChanged(CancellationRule(
      hoursBeforeReservation: _hoursBeforeReservation,
      feePercentage: _feePercentage,
      description: _description,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.rule,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Heures avant réservation
            TextFormField(
              initialValue: _hoursBeforeReservation.toString(),
              decoration: InputDecoration(
                labelText: l10n.hoursBeforeReservation,
                prefixIcon: const Icon(Icons.access_time),
                suffixText: l10n.hours,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _hoursBeforeReservation = int.tryParse(value) ?? 0;
                _updateRule();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Pourcentage de frais
            TextFormField(
              initialValue: _feePercentage.toString(),
              decoration: InputDecoration(
                labelText: l10n.feePercentage,
                prefixIcon: const Icon(Icons.percent),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _feePercentage = double.tryParse(value) ?? 0.0;
                _updateRule();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              initialValue: _description,
              decoration: InputDecoration(
                labelText: l10n.description,
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
              onChanged: (value) {
                _description = value;
                _updateRule();
              },
            ),
          ],
        ),
      ),
    );
  }
}

