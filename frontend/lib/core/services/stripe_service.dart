import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/stripe_config.dart';
import '../network/api_service.dart';
import '../../shared/errors/contextual_errors.dart';

/// Service pour gérer les paiements Stripe
class StripeService {
  final ApiService _apiService;
  
  StripeService(this._apiService);
  
  /// Initialiser Stripe
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'stripe_initialization_failed',
        message: 'Erreur lors de l\'initialisation de Stripe: $e',
      );
    }
  }
  
  /// Vérifier si Stripe est configuré
  static bool get isConfigured {
    return StripeConfig.isConfigured;
  }
  
  /// Obtenir l'environnement Stripe
  static String get environment {
    return StripeConfig.environment;
  }
  
  /// Créer un PaymentIntent via l'API backend
  Future<String> createPaymentIntent({
    required double amount,
    required String currency,
    required String reservationId,
  }) async {
    try {
      // Appeler l'API backend pour créer le PaymentIntent
      final response = await _apiService.createPaymentIntent(
        amount: amount,
        currency: currency,
        reservationId: reservationId,
      );
      
      return response.clientSecret;
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_intent_creation_failed',
        message: 'Erreur lors de la création du PaymentIntent: $e',
      );
    }
  }
  
  /// Initialiser le PaymentSheet
  Future<void> initPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
        ),
      );
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_sheet_init_failed',
        message: 'Erreur lors de l\'initialisation du PaymentSheet: $e',
      );
    }
  }
  
  /// Présenter le PaymentSheet
  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_sheet_present_failed',
        message: 'Erreur lors de la présentation du PaymentSheet: $e',
      );
    }
  }
  
  /// Traiter un paiement complet avec PaymentSheet
  Future<void> processPayment({
    required double amount,
    required String currency,
    required String reservationId,
    required String merchantDisplayName,
  }) async {
    try {
      // 1. Créer le PaymentIntent via l'API backend
      final clientSecret = await createPaymentIntent(
        amount: amount,
        currency: currency,
        reservationId: reservationId,
      );
      
      // 2. Initialiser le PaymentSheet
      await initPaymentSheet(
        clientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
      );
      
      // 3. Présenter le PaymentSheet à l'utilisateur
      await presentPaymentSheet();
      
      // 4. Confirmer via l'API backend
      await _apiService.confirmPayment(reservationId);
      
    } catch (e) {
      throw ContextualPaymentError(
        errorKey: 'payment_processing_failed',
        message: 'Erreur lors du traitement du paiement: $e',
      );
    }
  }
  
  /// Valider les détails de carte
  bool validateCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) {
    // Valider le numéro de carte (algorithme de Luhn)
    if (!_isValidCardNumber(cardNumber)) {
      return false;
    }
    
    // Valider la date d'expiration
    if (!_isValidExpiryDate(expiryDate)) {
      return false;
    }
    
    // Valider le CVV
    if (!_isValidCvv(cvv)) {
      return false;
    }
    
    // Valider le nom
    if (cardholderName.trim().isEmpty) {
      return false;
    }
    
    return true;
  }
  
  /// Valider le numéro de carte avec l'algorithme de Luhn
  bool _isValidCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(' ', '').replaceAll('-', '');
    
    if (digits.length < 13 || digits.length > 19) {
      return false;
    }
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  /// Valider la date d'expiration
  bool _isValidExpiryDate(String expiryDate) {
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    try {
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');
      
      if (month < 1 || month > 12) return false;
      
      final now = DateTime.now();
      final expiry = DateTime(year, month);
      
      return expiry.isAfter(now);
    } catch (e) {
      return false;
    }
  }
  
  /// Valider le CVV
  bool _isValidCvv(String cvv) {
    return cvv.length >= 3 && cvv.length <= 4 && RegExp(r'^\d+$').hasMatch(cvv);
  }
  
  /// Obtenir le type de carte
  String getCardType(String cardNumber) {
    final digits = cardNumber.replaceAll(' ', '').replaceAll('-', '');
    
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5') || digits.startsWith('2')) return 'Mastercard';
    if (digits.startsWith('3')) return 'American Express';
    if (digits.startsWith('6')) return 'Discover';
    
    return 'Unknown';
  }
}
