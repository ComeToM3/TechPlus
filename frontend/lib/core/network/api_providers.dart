import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'standard_api_client.dart';
import 'standard_schedule_api.dart';

/// Provider centralisé pour le client API standard
/// Utilisé par tous les services pour éviter les duplications
final standardApiClientProvider = Provider<StandardApiClient>((ref) {
  return StandardApiClient.create();
});

/// Provider pour l'API des créneaux horaires standardisée
final scheduleApiProvider = Provider<StandardScheduleApi>((ref) {
  final client = ref.watch(standardApiClientProvider);
  return StandardScheduleApi(client);
});

/// Provider pour l'API de disponibilité standardisée (utilise StandardScheduleApi)
final availabilityApiProvider = Provider<StandardScheduleApi>((ref) {
  return ref.watch(scheduleApiProvider);
});
