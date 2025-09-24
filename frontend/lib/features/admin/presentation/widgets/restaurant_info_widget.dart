import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../domain/entities/restaurant_config_entity.dart';
import '../providers/restaurant_config_provider.dart';

/// Widget pour les informations générales du restaurant
class RestaurantInfoWidget extends ConsumerStatefulWidget {
  const RestaurantInfoWidget({super.key});

  @override
  ConsumerState<RestaurantInfoWidget> createState() => _RestaurantInfoWidgetState();
}

class _RestaurantInfoWidgetState extends ConsumerState<RestaurantInfoWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurantConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _loadRestaurantConfig() {
    final configAsync = ref.read(restaurantConfigProvider);
    configAsync.whenData((config) {
      _nameController.text = config.name;
      _descriptionController.text = config.description;
      _addressController.text = config.address;
      _cityController.text = config.city;
      _postalCodeController.text = config.postalCode;
      _countryController.text = config.country;
      _phoneController.text = config.phone;
      _emailController.text = config.email;
      _websiteController.text = config.website;
    });
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateRestaurantConfigRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
      );

      await ref.read(restaurantConfigNotifierProvider.notifier).updateConfig(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.configurationSaved),
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
            // Informations de base
            BentoCard(
              title: l10n.basicInformation,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.restaurantName,
                      prefixIcon: const Icon(Icons.restaurant),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Adresse
            BentoCard(
              title: l10n.address,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: l10n.streetAddress,
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: l10n.city,
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.requiredField;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: l10n.postalCode,
                            prefixIcon: const Icon(Icons.local_post_office),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.requiredField;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: l10n.country,
                      prefixIcon: const Icon(Icons.public),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact
            BentoCard(
              title: l10n.contact,
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phone,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      if (!value.contains('@')) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      labelText: l10n.website,
                      prefixIcon: const Icon(Icons.web),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de sauvegarde
            Center(
              child: SimpleButton(
                onPressed: _isLoading ? null : _saveConfig,
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

