/// Messages d'erreur spécifiques et contextuels avec suggestions d'actions
class EnhancedErrorMessages {
  // Erreurs d'authentification avec contexte
  static const Map<String, String> authErrors = {
    'invalid_credentials': 'Identifiants incorrects. Vérifiez votre email et mot de passe.',
    'user_not_found': 'Aucun compte trouvé avec cet email. Voulez-vous créer un compte ?',
    'token_expired': 'Votre session a expiré. Veuillez vous reconnecter.',
    'token_invalid': 'Session invalide. Veuillez vous reconnecter.',
    'account_locked': 'Votre compte est temporairement verrouillé. Contactez le support.',
    'email_already_exists': 'Un compte existe déjà avec cet email. Essayez de vous connecter.',
    'weak_password': 'Le mot de passe doit contenir au moins 8 caractères avec des lettres et des chiffres.',
    'password_mismatch': 'Les mots de passe ne correspondent pas.',
    'email_not_verified': 'Veuillez vérifier votre email avant de continuer.',
  };

  // Erreurs de réservation avec contexte
  static const Map<String, String> reservationErrors = {
    'reservation_not_found': 'Cette réservation n\'existe pas ou a été supprimée.',
    'reservation_expired': 'Cette réservation a expiré et ne peut plus être modifiée.',
    'reservation_cancelled': 'Cette réservation a été annulée.',
    'time_slot_unavailable': 'Ce créneau n\'est plus disponible. Veuillez choisir un autre horaire.',
    'max_party_size_exceeded': 'Le nombre maximum de personnes pour ce créneau est de {max} personnes.',
    'min_party_size_not_met': 'Le nombre minimum de personnes pour ce créneau est de {min} personnes.',
    'reservation_too_early': 'Les réservations doivent être faites au moins 2 heures à l\'avance.',
    'reservation_too_late': 'Les réservations ne peuvent pas être faites plus de 30 jours à l\'avance.',
    'table_unavailable': 'Aucune table disponible pour ce créneau. Essayez un autre horaire.',
    'restaurant_closed': 'Le restaurant est fermé à cette heure. Veuillez choisir un autre créneau.',
    'special_request_not_available': 'Cette demande spéciale n\'est pas disponible pour ce créneau.',
  };

  // Erreurs de paiement avec contexte
  static const Map<String, String> paymentErrors = {
    'payment_failed': 'Le paiement a échoué. Vérifiez vos informations de carte.',
    'payment_declined': 'Votre carte a été refusée. Contactez votre banque ou utilisez une autre carte.',
    'insufficient_funds': 'Fonds insuffisants sur votre compte. Vérifiez votre solde.',
    'card_expired': 'Votre carte a expiré. Utilisez une carte valide.',
    'invalid_card': 'Informations de carte invalides. Vérifiez le numéro, la date et le CVV.',
    'payment_timeout': 'Le paiement a pris trop de temps. Veuillez réessayer.',
    'stripe_error': 'Erreur de traitement du paiement. Veuillez réessayer dans quelques minutes.',
    'refund_failed': 'Le remboursement a échoué. Contactez le support client.',
    'partial_refund': 'Un remboursement partiel a été effectué selon notre politique d\'annulation.',
  };

  // Erreurs de validation avec contexte
  static const Map<String, String> validationErrors = {
    'required_field': 'Ce champ est obligatoire pour continuer.',
    'invalid_email': 'Format d\'email invalide. Exemple : nom@exemple.com',
    'invalid_phone': 'Format de téléphone invalide. Utilisez le format : +33 1 23 45 67 89',
    'invalid_date': 'Date invalide. Utilisez le format JJ/MM/AAAA',
    'invalid_time': 'Heure invalide. Utilisez le format HH:MM',
    'invalid_name': 'Le nom doit contenir uniquement des lettres et espaces.',
    'invalid_party_size': 'Le nombre de personnes doit être entre 1 et 12.',
    'future_date_required': 'La date doit être dans le futur.',
    'past_date_not_allowed': 'La date ne peut pas être dans le passé.',
    'invalid_postal_code': 'Code postal invalide. Utilisez le format 75001.',
    'invalid_country_code': 'Code pays invalide. Utilisez le format FR.',
  };

  // Erreurs de réseau avec contexte
  static const Map<String, String> networkErrors = {
    'network_unavailable': 'Aucune connexion internet. Vérifiez votre connexion.',
    'connection_timeout': 'Connexion lente. Vérifiez votre connexion internet.',
    'server_unavailable': 'Le serveur est temporairement indisponible. Réessayez dans quelques minutes.',
    'request_timeout': 'La requête a pris trop de temps. Vérifiez votre connexion.',
    'dns_error': 'Impossible de joindre le serveur. Vérifiez votre connexion internet.',
    'ssl_error': 'Erreur de sécurité de connexion. Contactez le support.',
    'api_rate_limit': 'Trop de requêtes. Veuillez patienter avant de réessayer.',
  };

  // Erreurs de serveur avec contexte
  static const Map<String, String> serverErrors = {
    'server_error': 'Erreur temporaire du serveur. Réessayez dans quelques minutes.',
    'database_error': 'Erreur de base de données. Nos équipes ont été notifiées.',
    'service_unavailable': 'Service temporairement indisponible. Réessayez plus tard.',
    'maintenance_mode': 'Le service est en maintenance. Réessayez dans quelques heures.',
    'internal_error': 'Erreur interne. Nos équipes ont été notifiées.',
    'configuration_error': 'Erreur de configuration. Contactez le support.',
    'data_corruption': 'Données corrompues détectées. Contactez le support.',
  };

  // Erreurs générales avec contexte
  static const Map<String, String> generalErrors = {
    'unknown_error': 'Une erreur inattendue s\'est produite. Réessayez ou contactez le support.',
    'unexpected_error': 'Erreur inattendue. Nos équipes ont été notifiées.',
    'operation_failed': 'L\'opération a échoué. Vérifiez vos données et réessayez.',
    'access_denied': 'Accès refusé. Vous n\'avez pas les permissions nécessaires.',
    'permission_denied': 'Permission refusée. Contactez un administrateur.',
    'resource_not_found': 'Ressource non trouvée. Elle a peut-être été supprimée.',
    'quota_exceeded': 'Limite de quota dépassée. Contactez le support pour augmenter votre limite.',
    'rate_limit_exceeded': 'Trop de tentatives. Attendez quelques minutes avant de réessayer.',
    'feature_unavailable': 'Cette fonctionnalité n\'est pas encore disponible.',
    'browser_not_supported': 'Votre navigateur n\'est pas supporté. Utilisez Chrome, Firefox ou Safari.',
  };

  // Messages de succès avec contexte
  static const Map<String, String> successMessages = {
    'login_success': 'Connexion réussie ! Bienvenue.',
    'logout_success': 'Déconnexion réussie. À bientôt !',
    'registration_success': 'Inscription réussie ! Vérifiez votre email.',
    'reservation_created': 'Réservation créée avec succès ! Vous recevrez un email de confirmation.',
    'reservation_updated': 'Réservation mise à jour avec succès !',
    'reservation_cancelled': 'Réservation annulée avec succès.',
    'payment_success': 'Paiement effectué avec succès !',
    'data_saved': 'Données sauvegardées avec succès !',
    'operation_success': 'Opération réussie !',
    'email_sent': 'Email envoyé avec succès !',
    'password_reset': 'Instructions de réinitialisation envoyées par email.',
    'profile_updated': 'Profil mis à jour avec succès !',
  };

  // Messages d'information avec contexte
  static const Map<String, String> infoMessages = {
    'loading': 'Chargement en cours...',
    'saving': 'Sauvegarde en cours...',
    'processing': 'Traitement en cours...',
    'please_wait': 'Veuillez patienter...',
    'retry': 'Réessayer',
    'cancel': 'Annuler',
    'confirm': 'Confirmer',
    'close': 'Fermer',
    'back': 'Retour',
    'next': 'Suivant',
    'previous': 'Précédent',
    'finish': 'Terminer',
    'continue': 'Continuer',
    'save': 'Enregistrer',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'create': 'Créer',
    'update': 'Mettre à jour',
    'search': 'Rechercher',
    'filter': 'Filtrer',
    'sort': 'Trier',
    'export': 'Exporter',
    'import': 'Importer',
  };

  // Actions suggérées pour chaque type d'erreur
  static const Map<String, List<String>> suggestedActions = {
    'auth_errors': ['Vérifier les identifiants', 'Réinitialiser le mot de passe', 'Créer un compte'],
    'reservation_errors': ['Choisir un autre créneau', 'Modifier le nombre de personnes', 'Contacter le restaurant'],
    'payment_errors': ['Vérifier les informations de carte', 'Utiliser une autre carte', 'Contacter la banque'],
    'validation_errors': ['Corriger les champs en erreur', 'Vérifier le format des données', 'Remplir tous les champs obligatoires'],
    'network_errors': ['Vérifier la connexion internet', 'Réessayer dans quelques minutes', 'Contacter le support'],
    'server_errors': ['Réessayer plus tard', 'Contacter le support', 'Vérifier le statut du service'],
  };

  /// Obtenir un message d'erreur spécifique avec contexte
  static String getErrorMessage(String errorKey, {Map<String, String>? parameters}) {
    String message = '';
    
    // Chercher dans les différentes catégories
    if (authErrors.containsKey(errorKey)) {
      message = authErrors[errorKey]!;
    } else if (reservationErrors.containsKey(errorKey)) {
      message = reservationErrors[errorKey]!;
    } else if (paymentErrors.containsKey(errorKey)) {
      message = paymentErrors[errorKey]!;
    } else if (validationErrors.containsKey(errorKey)) {
      message = validationErrors[errorKey]!;
    } else if (networkErrors.containsKey(errorKey)) {
      message = networkErrors[errorKey]!;
    } else if (serverErrors.containsKey(errorKey)) {
      message = serverErrors[errorKey]!;
    } else if (generalErrors.containsKey(errorKey)) {
      message = generalErrors[errorKey]!;
    } else {
      message = generalErrors['unknown_error']!;
    }

    // Remplacer les paramètres si fournis
    if (parameters != null) {
      parameters.forEach((key, value) {
        message = message.replaceAll('{$key}', value);
      });
    }

    return message;
  }

  /// Obtenir les actions suggérées pour un type d'erreur
  static List<String> getSuggestedActions(String errorCategory) {
    return suggestedActions[errorCategory] ?? ['Réessayer', 'Contacter le support'];
  }

  /// Obtenir un message de succès
  static String getSuccessMessage(String successKey) {
    return successMessages[successKey] ?? 'Opération réussie !';
  }

  /// Obtenir un message d'information
  static String getInfoMessage(String infoKey) {
    return infoMessages[infoKey] ?? 'Information';
  }
}
