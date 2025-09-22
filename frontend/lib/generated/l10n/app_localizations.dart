import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  /// Le titre de l'application
  ///
  /// In fr, this message translates to:
  /// **'TechPlus'**
  String get appTitle;

  /// Message de bienvenue
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// Message de bienvenue avec nom d'utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue {userName}'**
  String welcomeUser(String userName);

  /// Bouton de connexion
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// Bouton d'inscription
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// Champ email
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// Champ mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// Champ nom
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// Bouton de déconnexion
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// Titre de la page des réservations
  ///
  /// In fr, this message translates to:
  /// **'Mes Réservations'**
  String get myReservations;

  /// Bouton pour créer une nouvelle réservation
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Réservation'**
  String get newReservation;

  /// Titre des réservations
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get reservations;

  /// Champ nom du restaurant
  ///
  /// In fr, this message translates to:
  /// **'Nom du restaurant'**
  String get restaurantName;

  /// Champ date
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// Champ heure
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get time;

  /// Nombre de personnes pour la réservation
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes'**
  String get partySize;

  /// Bouton pour créer une réservation
  ///
  /// In fr, this message translates to:
  /// **'Créer la réservation'**
  String get createReservation;

  /// Titre de la page de détails
  ///
  /// In fr, this message translates to:
  /// **'Détails Réservation'**
  String get reservationDetails;

  /// Statut de la réservation
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// Statut en attente
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// Statut confirmé
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// Statut annulé
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get cancelled;

  /// Message de statut du système
  ///
  /// In fr, this message translates to:
  /// **'Système opérationnel'**
  String get systemOperational;

  /// Message de configuration
  ///
  /// In fr, this message translates to:
  /// **'Backend et Frontend configurés'**
  String get backendFrontendConfigured;

  /// Tooltip pour basculer le thème
  ///
  /// In fr, this message translates to:
  /// **'Basculer le thème'**
  String get toggleTheme;

  /// Placeholder pour sélectionner une date
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectDate;

  /// Placeholder pour sélectionner une heure
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une heure'**
  String get selectTime;

  /// Message quand aucune réservation n'est trouvée
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation trouvée.'**
  String get noReservationsFound;

  /// Message de succès lors de la création d'une réservation
  ///
  /// In fr, this message translates to:
  /// **'Réservation créée avec succès !'**
  String get reservationCreatedSuccessfully;

  /// Titre d'erreur
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// Message d'erreur pour identifiants invalides
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides'**
  String get invalidCredentials;

  /// Message de validation pour l'email
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get pleaseEnterEmail;

  /// Message de validation pour le mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get pleaseEnterPassword;

  /// Message de validation pour le nom
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get pleaseEnterName;

  /// Message de validation pour la longueur du mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères'**
  String get passwordMinLength;

  /// Message de validation pour le nom du restaurant
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer le nom du restaurant'**
  String get pleaseEnterRestaurantName;

  /// Message de validation pour la date et l'heure
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une date et une heure'**
  String get pleaseSelectDateAndTime;

  /// Lien vers l'inscription
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? S\'inscrire'**
  String get noAccountYet;

  /// Lien vers la connexion
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get alreadyHaveAccount;

  /// Titre de la page d'inscription
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// Description pour les réservations
  ///
  /// In fr, this message translates to:
  /// **'Voir et gérer'**
  String get seeAndManage;

  /// Description pour créer une réservation
  ///
  /// In fr, this message translates to:
  /// **'Créer une réservation'**
  String get createReservationDesc;

  /// Bouton pour modifier une réservation
  ///
  /// In fr, this message translates to:
  /// **'Modifier la réservation'**
  String get modifyReservation;

  /// Bouton pour annuler une réservation
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get cancelReservation;

  /// Message pour fonctionnalité à venir
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité de modification à venir'**
  String get modifyFeatureComing;

  /// Message pour fonctionnalité d'annulation à venir
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité d\'annulation à venir'**
  String get cancelFeatureComing;

  /// Message de chargement
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// Description de l'application
  ///
  /// In fr, this message translates to:
  /// **'Système de réservation pour restaurants'**
  String get restaurantReservationSystem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
