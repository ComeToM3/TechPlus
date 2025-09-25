import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/reservation_local_datasource.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../shared/models/reservation.dart';

/// État du flux de réservation
class ReservationFlowState {
  final DateTime? selectedDate;
  final String? selectedTime;
  final int partySize;
  final bool isLoading;
  final String? error;
  final List<String> availableTimes;
  final bool isDateValid;
  final bool isTimeValid;
  final bool isPartySizeValid;
  
  // Informations client (Étape 2)
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String specialRequests;
  final bool isClientInfoValid;
  final bool isEmailValid;
  final bool isPhoneValid;
  
  // Paiement (Étape 3)
  final bool isPaymentRequired;
  final double depositAmount;
  final String? paymentIntentId;
  final bool isPaymentProcessing;
  final bool isPaymentCompleted;
  final String? paymentError;
  
  // Confirmation (Étape 4)
  final String? reservationId;
  final String? managementToken;
  final bool isReservationConfirmed;
  final bool isEmailSent;
  final bool isProcessingConfirmation;
  final String? confirmationError;

  ReservationFlowState({
    this.selectedDate,
    this.selectedTime,
    this.partySize = 1,
    this.isLoading = false,
    this.error,
    this.availableTimes = const [],
    this.isDateValid = false,
    this.isTimeValid = false,
    this.isPartySizeValid = true,
    this.clientName = '',
    this.clientEmail = '',
    this.clientPhone = '',
    this.specialRequests = '',
    this.isClientInfoValid = false,
    this.isEmailValid = false,
    this.isPhoneValid = true,
    this.isPaymentRequired = false,
    this.depositAmount = 0.0,
    this.paymentIntentId,
    this.isPaymentProcessing = false,
    this.isPaymentCompleted = false,
    this.paymentError,
    this.reservationId,
    this.managementToken,
    this.isReservationConfirmed = false,
    this.isEmailSent = false,
    this.isProcessingConfirmation = false,
    this.confirmationError,
  });

  ReservationFlowState copyWith({
    DateTime? selectedDate,
    String? selectedTime,
    int? partySize,
    bool? isLoading,
    String? error,
    List<String>? availableTimes,
    bool? isDateValid,
    bool? isTimeValid,
    bool? isPartySizeValid,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? specialRequests,
    bool? isClientInfoValid,
    bool? isEmailValid,
    bool? isPhoneValid,
    bool? isPaymentRequired,
    double? depositAmount,
    String? paymentIntentId,
    bool? isPaymentProcessing,
    bool? isPaymentCompleted,
    String? paymentError,
    String? reservationId,
    String? managementToken,
    bool? isReservationConfirmed,
    bool? isEmailSent,
    bool? isProcessingConfirmation,
    String? confirmationError,
  }) {
    return ReservationFlowState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      partySize: partySize ?? this.partySize,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableTimes: availableTimes ?? this.availableTimes,
      isDateValid: isDateValid ?? this.isDateValid,
      isTimeValid: isTimeValid ?? this.isTimeValid,
      isPartySizeValid: isPartySizeValid ?? this.isPartySizeValid,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      isClientInfoValid: isClientInfoValid ?? this.isClientInfoValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isPaymentRequired: isPaymentRequired ?? this.isPaymentRequired,
      depositAmount: depositAmount ?? this.depositAmount,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      isPaymentProcessing: isPaymentProcessing ?? this.isPaymentProcessing,
      isPaymentCompleted: isPaymentCompleted ?? this.isPaymentCompleted,
      paymentError: paymentError,
      reservationId: reservationId ?? this.reservationId,
      managementToken: managementToken ?? this.managementToken,
      isReservationConfirmed: isReservationConfirmed ?? this.isReservationConfirmed,
      isEmailSent: isEmailSent ?? this.isEmailSent,
      isProcessingConfirmation: isProcessingConfirmation ?? this.isProcessingConfirmation,
      confirmationError: confirmationError,
    );
  }

  bool get canProceedToNextStep {
    return isDateValid && isTimeValid && isPartySizeValid && !isLoading;
  }

  bool get canProceedToPayment {
    return canProceedToNextStep && isClientInfoValid && isEmailValid && isPhoneValid;
  }

  bool get canProceedToConfirmation {
    if (isPaymentRequired) {
      return canProceedToPayment && isPaymentCompleted;
    }
    return canProceedToPayment;
  }
}

/// Notifier pour gérer le flux de réservation
class ReservationFlowNotifier extends StateNotifier<ReservationFlowState> {
  final ReservationLocalDataSource _localDataSource;
  final ApiService _apiService;
  
  ReservationFlowNotifier(this._localDataSource, this._apiService) : super(ReservationFlowState());

  /// Sélectionner une date
  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      selectedTime: null, // Reset time when date changes
      isLoading: true,
      error: null,
    );

    try {
      // Appeler l'API backend pour récupérer les créneaux disponibles
      final availableTimes = await _apiService.getAvailableTimeSlots(date, state.partySize);
      
      state = state.copyWith(
        availableTimes: availableTimes,
        isDateValid: true,
        isTimeValid: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la récupération des créneaux: $e',
        isLoading: false,
      );
    }
  }

  /// Sélectionner un créneau horaire
  void selectTime(String time) {
    state = state.copyWith(
      selectedTime: time,
      isTimeValid: true,
      error: null,
    );
  }

  /// Modifier le nombre de personnes
  void setPartySize(int size) {
    final isValid = size >= 1 && size <= 12;
    state = state.copyWith(
      partySize: size,
      isPartySizeValid: isValid,
      error: isValid ? null : 'Le nombre de personnes doit être entre 1 et 12',
    );
  }

  /// Réinitialiser la sélection
  void resetSelection() {
    state = ReservationFlowState();
  }

  /// Valider la sélection complète
  bool validateSelection() {
    if (state.selectedDate == null) {
      state = state.copyWith(error: 'Veuillez sélectionner une date');
      return false;
    }
    
    if (state.selectedTime == null) {
      state = state.copyWith(error: 'Veuillez sélectionner un créneau horaire');
      return false;
    }
    
    if (!state.isPartySizeValid) {
      state = state.copyWith(error: 'Veuillez vérifier le nombre de personnes');
      return false;
    }

    return true;
  }

  /// Obtenir les créneaux disponibles pour une date donnée
  Future<List<String>> _getAvailableTimesForDate(DateTime date, WidgetRef ref) async {
    try {
      // Appeler l'API réelle pour obtenir les créneaux disponibles
      final availabilityApi = ref.read(availabilityApiProvider);
      final slots = await availabilityApi.getAvailableSlots(
        date: date,
        partySize: state.partySize,
      );
      
      // Retourner seulement les créneaux disponibles
      return slots
          .where((slot) => slot.isAvailable)
          .map((slot) => slot.time)
          .toList();
    } catch (e) {
      // En cas d'erreur, retourner une liste vide
      return [];
    }
  }

  /// Calculer la durée de réservation
  int getReservationDuration() {
    if (state.partySize <= 4) {
      return 90; // 1h30 pour 1-4 personnes
    } else {
      return 120; // 2h00 pour 5+ personnes
    }
  }

  /// Vérifier si un paiement est requis
  bool isPaymentRequired() {
    return state.partySize >= 6;
  }

  /// Calculer le montant de l'acompte
  double getDepositAmount() {
    if (isPaymentRequired()) {
      return 10.0; // 10€ d'acompte pour 6+ personnes
    }
    return 0.0;
  }

  /// Mettre à jour le nom du client
  void updateClientName(String name) {
    final isValid = name.trim().isNotEmpty && name.trim().length >= 2;
    state = state.copyWith(
      clientName: name.trim(),
      isClientInfoValid: isValid && state.isEmailValid && state.isPhoneValid,
      error: isValid ? null : 'Le nom doit contenir au moins 2 caractères',
    );
  }

  /// Mettre à jour l'email du client
  void updateClientEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final isValid = email.trim().isNotEmpty && emailRegex.hasMatch(email.trim());
    
    state = state.copyWith(
      clientEmail: email.trim(),
      isEmailValid: isValid,
      isClientInfoValid: isValid && state.clientName.isNotEmpty && state.isPhoneValid,
      error: isValid ? null : 'Veuillez entrer un email valide',
    );
  }

  /// Mettre à jour le téléphone du client
  void updateClientPhone(String phone) {
    // Le téléphone est optionnel, donc toujours valide s'il est vide
    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    final isValid = phone.trim().isEmpty || phoneRegex.hasMatch(phone.trim());
    
    state = state.copyWith(
      clientPhone: phone.trim(),
      isPhoneValid: isValid,
      isClientInfoValid: isValid && state.clientName.isNotEmpty && state.isEmailValid,
      error: isValid ? null : 'Veuillez entrer un numéro de téléphone valide (format français)',
    );
  }

  /// Mettre à jour les demandes spéciales
  void updateSpecialRequests(String requests) {
    state = state.copyWith(
      specialRequests: requests.trim(),
    );
  }

  /// Valider toutes les informations client
  bool validateClientInfo() {
    if (state.clientName.isEmpty) {
      state = state.copyWith(error: 'Le nom est requis');
      return false;
    }
    
    if (state.clientEmail.isEmpty) {
      state = state.copyWith(error: 'L\'email est requis');
      return false;
    }
    
    if (!state.isEmailValid) {
      state = state.copyWith(error: 'Veuillez entrer un email valide');
      return false;
    }
    
    if (!state.isPhoneValid) {
      state = state.copyWith(error: 'Veuillez entrer un numéro de téléphone valide');
      return false;
    }

    return true;
  }

  /// Sauvegarder temporairement les informations
  Future<void> saveTemporaryData() async {
    try {
      final data = {
        'selectedDate': state.selectedDate?.millisecondsSinceEpoch,
        'selectedTime': state.selectedTime,
        'partySize': state.partySize,
        'clientName': state.clientName,
        'clientEmail': state.clientEmail,
        'clientPhone': state.clientPhone,
        'specialRequests': state.specialRequests,
        'availableTimes': state.availableTimes,
      };
      
      await _localDataSource.saveTemporaryReservation(data);
    } catch (e) {
      // En cas d'erreur, on continue sans sauvegarder
      // Les données restent dans le state
    }
  }

  /// Charger les données temporaires
  Future<void> loadTemporaryData() async {
    try {
      final data = await _localDataSource.loadTemporaryReservation();
      
      if (data != null) {
        final selectedDate = data['selectedDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(data['selectedDate'])
            : null;
            
        state = state.copyWith(
          selectedDate: selectedDate,
          selectedTime: data['selectedTime'],
          partySize: data['partySize'] ?? 1,
          clientName: data['clientName'] ?? '',
          clientEmail: data['clientEmail'] ?? '',
          clientPhone: data['clientPhone'] ?? '',
          specialRequests: data['specialRequests'] ?? '',
          availableTimes: List<String>.from(data['availableTimes'] ?? []),
        );
        
        // Revalider les informations
        if (selectedDate != null) {
          state = state.copyWith(isDateValid: true);
        }
        if (data['selectedTime'] != null) {
          state = state.copyWith(isTimeValid: true);
        }
        if (data['clientName'] != null && data['clientName'].isNotEmpty) {
          updateClientName(data['clientName']);
        }
        if (data['clientEmail'] != null && data['clientEmail'].isNotEmpty) {
          updateClientEmail(data['clientEmail']);
        }
        if (data['clientPhone'] != null && data['clientPhone'].isNotEmpty) {
          updateClientPhone(data['clientPhone']);
        }
      }
    } catch (e) {
      // En cas d'erreur, on continue avec les valeurs par défaut
    }
  }

  /// Nettoyer les données temporaires
  Future<void> clearTemporaryData() async {
    await _localDataSource.clearTemporaryReservation();
  }

  /// Initialiser les informations de paiement
  void initializePayment() {
    final requiresPayment = state.partySize >= 6;
    final depositAmount = requiresPayment ? 10.0 : 0.0;
    
    state = state.copyWith(
      isPaymentRequired: requiresPayment,
      depositAmount: depositAmount,
      paymentError: null,
    );
  }

  /// Créer un PaymentIntent Stripe
  Future<void> createPaymentIntent() async {
    if (!state.isPaymentRequired) return;
    
    state = state.copyWith(
      isPaymentProcessing: true,
      paymentError: null,
    );

    try {
      // Appeler l'API backend pour créer le PaymentIntent
      final paymentIntent = await _apiService.createPaymentIntent(
        amount: state.depositAmount,
        currency: 'EUR',
        reservationId: state.reservationId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      state = state.copyWith(
        paymentIntentId: paymentIntent.paymentIntentId,
        isPaymentProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPaymentProcessing: false,
        paymentError: 'Erreur lors de la création du paiement: $e',
      );
    }
  }

  /// Confirmer le paiement
  Future<void> confirmPayment(String paymentMethodId) async {
    if (!state.isPaymentRequired || state.paymentIntentId == null) return;
    
    state = state.copyWith(
      isPaymentProcessing: true,
      paymentError: null,
    );

    try {
      // Appeler l'API backend pour confirmer le paiement
      await _apiService.confirmPayment(state.paymentIntentId!);
      
      state = state.copyWith(
        isPaymentCompleted: true,
        isPaymentProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPaymentProcessing: false,
        paymentError: 'Erreur lors de la confirmation du paiement: $e',
      );
    }
  }

  /// Annuler le paiement
  Future<void> cancelPayment() async {
    state = state.copyWith(
      paymentIntentId: null,
      isPaymentProcessing: false,
      isPaymentCompleted: false,
      paymentError: null,
    );
  }

  /// Obtenir la politique d'annulation
  String getCancellationPolicy() {
    if (!state.isPaymentRequired) {
      return 'Aucun paiement requis pour cette réservation.';
    }
    
    return '''
Politique d'annulation et de remboursement :

• Plus de 24h avant la réservation : Remboursement complet automatique
• Moins de 24h avant la réservation : Aucun remboursement (acompte perdu)
• No-show (absence sans prévenir) : Aucun remboursement (acompte perdu)
• Annulation par le restaurant : Remboursement complet

L'acompte de ${state.depositAmount.toStringAsFixed(2)}€ sera débité immédiatement et sera remboursé selon les conditions ci-dessus.
''';
  }

  /// Calculer le montant total estimé
  double getEstimatedTotal() {
    // Prix moyen par personne : 25€
    const averagePricePerPerson = 25.0;
    return state.partySize * averagePricePerPerson;
  }

  /// Confirmer la réservation
  Future<void> confirmReservation() async {
    state = state.copyWith(
      isProcessingConfirmation: true,
      confirmationError: null,
    );

    try {
      // Créer l'objet réservation
      final reservation = Reservation(
        id: '', // Sera généré par le backend
        date: state.selectedDate!,
        time: state.selectedTime!,
        duration: 90, // Durée par défaut
        partySize: state.partySize,
        specialRequests: state.specialRequests,
        clientName: state.clientName,
        clientEmail: state.clientEmail,
        clientPhone: state.clientPhone,
        status: 'PENDING',
        restaurantId: 'restaurant_1', // À récupérer depuis la configuration
      );

      // Appeler l'API backend pour créer la réservation
      final createdReservation = await _apiService.createReservation(reservation);
      
      state = state.copyWith(
        reservationId: createdReservation.id,
        managementToken: createdReservation.managementToken,
        isReservationConfirmed: true,
        isProcessingConfirmation: false,
      );
      
      // Envoyer l'email de confirmation
      await _sendConfirmationEmail();
      
    } catch (e) {
      state = state.copyWith(
        isProcessingConfirmation: false,
        confirmationError: 'Erreur lors de la confirmation de la réservation: $e',
      );
    }
  }

  /// Envoyer l'email de confirmation
  Future<void> _sendConfirmationEmail() async {
    try {
      // Appeler l'API backend pour envoyer l'email de confirmation
      await _apiService.sendConfirmationEmail(
        reservationId: state.reservationId!,
        clientEmail: state.clientEmail,
      );
      
      state = state.copyWith(
        isEmailSent: true,
      );
    } catch (e) {
      // L'email n'est pas critique, on continue
      state = state.copyWith(
        isEmailSent: false,
      );
    }
  }

  /// Générer un token de gestion sécurisé
  String _generateManagementToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final token = StringBuffer();
    
    for (int i = 0; i < 32; i++) {
      token.write(chars[(random + i) % chars.length]);
    }
    
    return token.toString();
  }

  /// Obtenir le lien de gestion
  String getManagementLink() {
    if (state.managementToken == null) return '';
    return '/manage-reservation?token=${state.managementToken}';
  }

  /// Obtenir le récapitulatif de la réservation
  Map<String, dynamic> getReservationSummary() {
    return {
      'reservationId': state.reservationId,
      'date': state.selectedDate?.toIso8601String(),
      'time': state.selectedTime,
      'partySize': state.partySize,
      'duration': state.partySize <= 4 ? 90 : 120, // minutes
      'clientName': state.clientName,
      'clientEmail': state.clientEmail,
      'clientPhone': state.clientPhone,
      'specialRequests': state.specialRequests,
      'isPaymentRequired': state.isPaymentRequired,
      'depositAmount': state.depositAmount,
      'paymentStatus': state.isPaymentCompleted ? 'completed' : 'none',
      'estimatedTotal': getEstimatedTotal(),
      'managementToken': state.managementToken,
      'status': state.isReservationConfirmed ? 'confirmed' : 'pending',
    };
  }

  /// Réinitialiser le flux pour une nouvelle réservation
  void resetReservationFlow() {
    state = ReservationFlowState();
  }
}

/// Provider pour le flux de réservation
final reservationFlowProvider = StateNotifierProvider<ReservationFlowNotifier, ReservationFlowState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReservationFlowNotifier(ReservationLocalDataSource(), apiService);
});

/// Provider pour les dates disponibles (30 prochains jours)
final availableDatesProvider = Provider<List<DateTime>>((ref) {
  final now = DateTime.now();
  final dates = <DateTime>[];
  
  for (int i = 0; i < 30; i++) {
    final date = now.add(Duration(days: i));
    // Exclure les lundis (jour de fermeture)
    if (date.weekday != DateTime.monday) {
      dates.add(date);
    }
  }
  
  return dates;
});

/// Provider pour les heures d'ouverture
final openingHoursProvider = Provider<Map<String, String>>((ref) {
  return {
    'mardi': '12:00 - 14:30, 19:00 - 22:30',
    'mercredi': '12:00 - 14:30, 19:00 - 22:30',
    'jeudi': '12:00 - 14:30, 19:00 - 22:30',
    'vendredi': '12:00 - 14:30, 19:00 - 22:30',
    'samedi': '12:00 - 14:30, 19:00 - 22:30',
    'dimanche': '19:00 - 22:30',
  };
});
