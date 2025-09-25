/// Configuration Stripe pour les paiements
class StripeConfig {
  // Clés Stripe - À configurer selon l'environnement
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_...', // Clé de test par défaut
  );
  
  static const String secretKey = String.fromEnvironment(
    'STRIPE_SECRET_KEY',
    defaultValue: 'sk_test_...', // Clé secrète de test par défaut
  );
  
  // Configuration des paiements
  static const String currency = 'EUR';
  static const double depositAmount = 10.0; // Montant fixe de l'acompte
  static const int paymentThreshold = 6; // Seuil pour le paiement obligatoire
  
  // Configuration des webhooks
  static const String webhookSecret = String.fromEnvironment(
    'STRIPE_WEBHOOK_SECRET',
    defaultValue: 'whsec_...', // Secret webhook par défaut
  );
  
  // URLs des endpoints
  static const String createPaymentIntentEndpoint = '/api/payments/create-intent';
  static const String confirmPaymentEndpoint = '/api/payments/confirm';
  static const String refundPaymentEndpoint = '/api/payments/refund';
  
  // Configuration de l'interface
  static const String merchantDisplayName = 'TechPlus Restaurant';
  static const String merchantCountryCode = 'FR';
  
  // Vérifier si Stripe est configuré
  static bool get isConfigured {
    return publishableKey != 'pk_test_...' && 
           secretKey != 'sk_test_...' &&
           webhookSecret != 'whsec_...';
  }
  
  // Obtenir l'environnement Stripe
  static String get environment {
    if (publishableKey.startsWith('pk_live_')) {
      return 'production';
    } else if (publishableKey.startsWith('pk_test_')) {
      return 'test';
    } else {
      return 'development';
    }
  }
}
