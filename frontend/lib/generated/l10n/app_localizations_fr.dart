// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TechPlus';

  @override
  String get welcome => 'Bienvenue';

  @override
  String welcomeUser(String userName) {
    return 'Bienvenue $userName';
  }

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get name => 'Nom';

  @override
  String get logout => 'Déconnexion';

  @override
  String get myReservations => 'Mes Réservations';

  @override
  String get newReservation => 'Nouvelle Réservation';

  @override
  String get reservations => 'Réservations';

  @override
  String get restaurantName => 'Nom du restaurant';

  @override
  String get date => 'Date';

  @override
  String get time => 'Heure';

  @override
  String get partySize => 'Nombre de personnes';

  @override
  String get createReservation => 'Créer la réservation';

  @override
  String get reservationDetails => 'Détails Réservation';

  @override
  String get status => 'Statut';

  @override
  String get pending => 'En attente';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get systemOperational => 'Système opérationnel';

  @override
  String get backendFrontendConfigured => 'Backend et Frontend configurés';

  @override
  String get toggleTheme => 'Basculer le thème';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get selectTime => 'Sélectionner une heure';

  @override
  String get noReservationsFound => 'Aucune réservation trouvée.';

  @override
  String get reservationCreatedSuccessfully =>
      'Réservation créée avec succès !';

  @override
  String get error => 'Erreur';

  @override
  String get invalidCredentials => 'Identifiants invalides';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre email';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get pleaseEnterName => 'Veuillez entrer votre nom';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get pleaseEnterRestaurantName =>
      'Veuillez entrer le nom du restaurant';

  @override
  String get pleaseSelectDateAndTime =>
      'Veuillez sélectionner une date et une heure';

  @override
  String get noAccountYet => 'Pas encore de compte ? S\'inscrire';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get seeAndManage => 'Voir et gérer';

  @override
  String get createReservationDesc => 'Créer une réservation';

  @override
  String get modifyReservation => 'Modifier la réservation';

  @override
  String get cancelReservation => 'Annuler la réservation';

  @override
  String get modifyFeatureComing => 'Fonctionnalité de modification à venir';

  @override
  String get cancelFeatureComing => 'Fonctionnalité d\'annulation à venir';

  @override
  String get loading => 'Chargement...';

  @override
  String get restaurantReservationSystem =>
      'Système de réservation pour restaurants';
}
