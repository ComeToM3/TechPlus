import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stripe_service.dart';
import '../network/api_service_provider.dart';

/// Provider pour le service Stripe
final stripeServiceProvider = Provider<StripeService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StripeService(apiService);
});

/// Provider pour vérifier si Stripe est configuré
final isStripeConfiguredProvider = Provider<bool>((ref) {
  return StripeService.isConfigured;
});

/// Provider pour l'environnement Stripe
final stripeEnvironmentProvider = Provider<String>((ref) {
  return StripeService.environment;
});
