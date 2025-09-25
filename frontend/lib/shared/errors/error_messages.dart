/// Messages d'erreur spécifiques et localisés
class ErrorMessages {
  // Erreurs d'authentification
  static const String invalidCredentials = 'Identifiants invalides';
  static const String userNotFound = 'Utilisateur non trouvé';
  static const String tokenExpired = 'Token expiré';
  static const String tokenInvalid = 'Token invalide';
  static const String accountLocked = 'Compte verrouillé';
  static const String emailAlreadyExists = 'Cet email est déjà utilisé';
  static const String weakPassword = 'Mot de passe trop faible';
  
  // Erreurs de réservation
  static const String reservationNotFound = 'Réservation non trouvée';
  static const String reservationExpired = 'Réservation expirée';
  static const String reservationCancelled = 'Réservation annulée';
  static const String timeSlotUnavailable = 'Créneau non disponible';
  static const String maxPartySizeExceeded = 'Nombre de personnes maximum dépassé';
  static const String minPartySizeNotMet = 'Nombre de personnes minimum non atteint';
  static const String reservationTooEarly = 'Réservation trop en avance';
  static const String reservationTooLate = 'Réservation trop tardive';
  
  // Erreurs de paiement
  static const String paymentFailed = 'Paiement échoué';
  static const String paymentDeclined = 'Paiement refusé';
  static const String insufficientFunds = 'Fonds insuffisants';
  static const String cardExpired = 'Carte expirée';
  static const String invalidCard = 'Carte invalide';
  static const String paymentTimeout = 'Délai de paiement dépassé';
  
  // Erreurs de validation
  static const String requiredField = 'Ce champ est obligatoire';
  static const String invalidEmail = 'Email invalide';
  static const String invalidPhone = 'Numéro de téléphone invalide';
  static const String invalidDate = 'Date invalide';
  static const String invalidTime = 'Heure invalide';
  static const String invalidName = 'Nom invalide';
  static const String invalidPartySize = 'Nombre de personnes invalide';
  
  // Erreurs de réseau
  static const String networkUnavailable = 'Réseau indisponible';
  static const String connectionTimeout = 'Délai de connexion dépassé';
  static const String serverUnavailable = 'Serveur indisponible';
  static const String requestTimeout = 'Délai de requête dépassé';
  
  // Erreurs de serveur
  static const String serverError = 'Erreur du serveur';
  static const String databaseError = 'Erreur de base de données';
  static const String serviceUnavailable = 'Service indisponible';
  static const String maintenanceMode = 'Mode maintenance';
  
  // Erreurs générales
  static const String unknownError = 'Erreur inconnue';
  static const String unexpectedError = 'Erreur inattendue';
  static const String operationFailed = 'Opération échouée';
  static const String accessDenied = 'Accès refusé';
  static const String permissionDenied = 'Permission refusée';
  static const String resourceNotFound = 'Ressource non trouvée';
  static const String quotaExceeded = 'Quota dépassé';
  static const String rateLimitExceeded = 'Limite de taux dépassée';
  
  // Messages de succès
  static const String loginSuccess = 'Connexion réussie';
  static const String logoutSuccess = 'Déconnexion réussie';
  static const String registrationSuccess = 'Inscription réussie';
  static const String reservationCreated = 'Réservation créée';
  static const String reservationUpdated = 'Réservation mise à jour';
  static const String paymentSuccess = 'Paiement réussi';
  static const String dataSaved = 'Données sauvegardées';
  static const String operationSuccess = 'Opération réussie';
  
  // Messages d'information
  static const String loading = 'Chargement...';
  static const String saving = 'Sauvegarde...';
  static const String processing = 'Traitement...';
  static const String pleaseWait = 'Veuillez patienter...';
  static const String retry = 'Réessayer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String close = 'Fermer';
  static const String back = 'Retour';
  static const String next = 'Suivant';
  static const String previous = 'Précédent';
  static const String finish = 'Terminer';
}
