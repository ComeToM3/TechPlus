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

  /// Bouton nouvelle réservation
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réservation'**
  String get newReservation;

  /// Réservations
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get reservations;

  /// Nom du restaurant
  ///
  /// In fr, this message translates to:
  /// **'Nom du Restaurant'**
  String get restaurantName;

  /// Slogan du restaurant
  ///
  /// In fr, this message translates to:
  /// **'Une expérience culinaire exceptionnelle'**
  String get restaurantSlogan;

  /// Bouton réserver maintenant
  ///
  /// In fr, this message translates to:
  /// **'Réserver maintenant'**
  String get bookNow;

  /// Titre section services
  ///
  /// In fr, this message translates to:
  /// **'Nos Services'**
  String get ourServices;

  /// Titre service réservation en ligne
  ///
  /// In fr, this message translates to:
  /// **'Réservation en ligne'**
  String get onlineReservation;

  /// Description service réservation en ligne
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre table 24h/24 depuis notre site'**
  String get onlineReservationDescription;

  /// Titre service menu varié
  ///
  /// In fr, this message translates to:
  /// **'Menu varié'**
  String get diverseMenu;

  /// Description service menu varié
  ///
  /// In fr, this message translates to:
  /// **'Découvrez notre carte avec des plats d\'exception'**
  String get diverseMenuDescription;

  /// Titre service premium
  ///
  /// In fr, this message translates to:
  /// **'Service premium'**
  String get premiumService;

  /// Description service premium
  ///
  /// In fr, this message translates to:
  /// **'Un service personnalisé pour votre confort'**
  String get premiumServiceDescription;

  /// Titre aperçu du menu
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du Menu'**
  String get menuPreview;

  /// Bouton voir tout le menu
  ///
  /// In fr, this message translates to:
  /// **'Voir tout le menu'**
  String get viewFullMenu;

  /// Titre section call-to-action
  ///
  /// In fr, this message translates to:
  /// **'Prêt à vivre une expérience culinaire unique ?'**
  String get readyForUniqueExperience;

  /// Description section call-to-action
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre table dès maintenant et découvrez notre cuisine d\'exception'**
  String get bookTableNow;

  /// Bouton réserver une table
  ///
  /// In fr, this message translates to:
  /// **'Réserver une table'**
  String get bookTable;

  /// Titre de la page menu
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Lien à propos
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// Contacter
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Copyright
  ///
  /// In fr, this message translates to:
  /// **'© 2025 TechPlus Restaurant. Tous droits réservés.'**
  String get copyright;

  /// Bouton mode clair
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get lightMode;

  /// Bouton mode sombre
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// Bouton langue
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// Langue française
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// Langue anglaise
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get english;

  /// Lien panneau d'administration
  ///
  /// In fr, this message translates to:
  /// **'Panneau d\'administration'**
  String get adminPanel;

  /// Titre du tableau de bord administrateur
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord Admin'**
  String get adminDashboard;

  /// Message de bienvenue
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get welcomeBack;

  /// Description du tableau de bord
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble de votre restaurant'**
  String get dashboardOverview;

  /// Bouton voir les réservations
  ///
  /// In fr, this message translates to:
  /// **'Voir les réservations'**
  String get viewReservations;

  /// Actualiser
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// Bouton paramètres
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// Erreur de chargement des données
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des données'**
  String get errorLoadingData;

  /// Réessayer
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// Message aucune donnée
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get noDataAvailable;

  /// Description aucune donnée
  ///
  /// In fr, this message translates to:
  /// **'Les métriques apparaîtront ici une fois que vous aurez des réservations'**
  String get noDataDescription;

  /// Métriques principales
  ///
  /// In fr, this message translates to:
  /// **'Métriques principales'**
  String get mainMetrics;

  /// Réservations du jour
  ///
  /// In fr, this message translates to:
  /// **'Réservations du jour'**
  String get todayReservations;

  /// Revenus du jour
  ///
  /// In fr, this message translates to:
  /// **'Revenus du jour'**
  String get todayRevenue;

  /// Occupation des tables
  ///
  /// In fr, this message translates to:
  /// **'Occupation des tables'**
  String get tableOccupancy;

  /// Réservations en attente
  ///
  /// In fr, this message translates to:
  /// **'Réservations en attente'**
  String get pendingReservations;

  /// Titre métriques supplémentaires
  ///
  /// In fr, this message translates to:
  /// **'Métriques supplémentaires'**
  String get additionalMetrics;

  /// Total des réservations
  ///
  /// In fr, this message translates to:
  /// **'Total des réservations'**
  String get totalReservations;

  /// Revenus totaux
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires total'**
  String get totalRevenue;

  /// Total des clients
  ///
  /// In fr, this message translates to:
  /// **'Total clients'**
  String get totalCustomers;

  /// Nouveaux clients
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux clients'**
  String get newCustomers;

  /// Titre section tendances
  ///
  /// In fr, this message translates to:
  /// **'Tendances et analyses'**
  String get trendsAndAnalytics;

  /// Message graphiques à venir
  ///
  /// In fr, this message translates to:
  /// **'Graphiques bientôt disponibles'**
  String get chartsComingSoon;

  /// Titre état des tables
  ///
  /// In fr, this message translates to:
  /// **'État des tables'**
  String get tableStatus;

  /// Bouton voir tout
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get viewAll;

  /// Message plan des tables à venir
  ///
  /// In fr, this message translates to:
  /// **'Plan des tables bientôt disponible'**
  String get tableMapComingSoon;

  /// Statut confirmé
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// Statut en attente
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// Statut annulé
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get cancelled;

  /// Total
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// Résumé des réservations
  ///
  /// In fr, this message translates to:
  /// **'Résumé des réservations du jour'**
  String get reservationsTodaySummary;

  /// Tables occupées
  ///
  /// In fr, this message translates to:
  /// **'Occupées'**
  String get occupied;

  /// Tables disponibles
  ///
  /// In fr, this message translates to:
  /// **'Disponibles'**
  String get available;

  /// Message occupation élevée
  ///
  /// In fr, this message translates to:
  /// **'Occupation élevée - Considérez ajouter des tables'**
  String get highOccupancy;

  /// Message bonne occupation
  ///
  /// In fr, this message translates to:
  /// **'Bonne occupation - Performance optimale'**
  String get goodOccupancy;

  /// Message occupation modérée
  ///
  /// In fr, this message translates to:
  /// **'Occupation modérée - Potentiel d\'amélioration'**
  String get moderateOccupancy;

  /// Message occupation faible
  ///
  /// In fr, this message translates to:
  /// **'Occupation faible - Actions marketing recommandées'**
  String get lowOccupancy;

  /// Revenus
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get revenue;

  /// Message croissance positive des revenus
  ///
  /// In fr, this message translates to:
  /// **'Croissance de {percentage}% par rapport à la moyenne'**
  String revenueGrowthPositive(String percentage);

  /// Message baisse des revenus
  ///
  /// In fr, this message translates to:
  /// **'Baisse de {percentage}% par rapport à la moyenne'**
  String revenueGrowthNegative(String percentage);

  /// Résumé des revenus
  ///
  /// In fr, this message translates to:
  /// **'Analyse des revenus et tendances'**
  String get revenueSummary;

  /// Titre tables populaires
  ///
  /// In fr, this message translates to:
  /// **'Tables populaires'**
  String get topTables;

  /// Places de table
  ///
  /// In fr, this message translates to:
  /// **'places'**
  String get seats;

  /// Résumé des tables populaires
  ///
  /// In fr, this message translates to:
  /// **'Classement des tables les plus demandées'**
  String get topTablesSummary;

  /// Métriques détaillées
  ///
  /// In fr, this message translates to:
  /// **'Métriques détaillées'**
  String get detailedMetrics;

  /// Total des Tables
  ///
  /// In fr, this message translates to:
  /// **'Total des Tables'**
  String get totalTables;

  /// Revenus moyens
  ///
  /// In fr, this message translates to:
  /// **'Revenus moyens'**
  String get averageRevenue;

  /// Titre calendrier des réservations
  ///
  /// In fr, this message translates to:
  /// **'Calendrier des réservations'**
  String get reservationCalendar;

  /// Rapport mensuel
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get monthly;

  /// Rapport hebdomadaire
  ///
  /// In fr, this message translates to:
  /// **'Hebdomadaire'**
  String get weekly;

  /// Rapport quotidien
  ///
  /// In fr, this message translates to:
  /// **'Quotidien'**
  String get daily;

  /// Réservations pour une date
  ///
  /// In fr, this message translates to:
  /// **'Réservations du {day}/{month}'**
  String reservationsForDate(String day, String month);

  /// Message aucune réservation
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation pour cette date'**
  String get noReservationsForDate;

  /// Nombre de personnes
  ///
  /// In fr, this message translates to:
  /// **'personnes'**
  String get people;

  /// Table
  ///
  /// In fr, this message translates to:
  /// **'Table'**
  String get table;

  /// Titre gestion des réservations
  ///
  /// In fr, this message translates to:
  /// **'Gestion des réservations'**
  String get reservationManagement;

  /// Filtres
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filters;

  /// Réservations confirmées
  ///
  /// In fr, this message translates to:
  /// **'Réservations confirmées'**
  String get confirmedReservations;

  /// Actions Rapides
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// Exporter
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get export;

  /// Fermer
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// Filtres avancés
  ///
  /// In fr, this message translates to:
  /// **'Filtres avancés'**
  String get advancedFilters;

  /// Effacer les filtres
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// Placeholder recherche réservations
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des réservations...'**
  String get searchReservations;

  /// Statut de la réservation
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// Tables
  ///
  /// In fr, this message translates to:
  /// **'Tables'**
  String get tables;

  /// Période du rapport
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get dateRange;

  /// Date de début
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get startDate;

  /// Date de fin
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get endDate;

  /// Appliquer les filtres
  ///
  /// In fr, this message translates to:
  /// **'Appliquer les filtres'**
  String get applyFilters;

  /// Éléments sélectionnés
  ///
  /// In fr, this message translates to:
  /// **'{count} éléments sélectionnés'**
  String selectedItems(String count);

  /// Changer le statut
  ///
  /// In fr, this message translates to:
  /// **'Changer le statut'**
  String get changeStatus;

  /// Assigner une table
  ///
  /// In fr, this message translates to:
  /// **'Assigner une table'**
  String get assignTable;

  /// Désassigner la table
  ///
  /// In fr, this message translates to:
  /// **'Désassigner la table'**
  String get unassignTable;

  /// Notifications
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Envoyer un rappel
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un rappel'**
  String get sendReminder;

  /// Envoyer une confirmation
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une confirmation'**
  String get sendConfirmation;

  /// Supprimer la sélection
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la sélection'**
  String get deleteSelected;

  /// Tout sélectionner
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get selectAll;

  /// Effacer la sélection
  ///
  /// In fr, this message translates to:
  /// **'Effacer la sélection'**
  String get clearSelection;

  /// Confirmation de suppression
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cette réservation ?'**
  String get deleteConfirmation;

  /// Exporter les données
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get exportData;

  /// Format d'export
  ///
  /// In fr, this message translates to:
  /// **'Format d\'export'**
  String get exportFormat;

  /// Description CSV
  ///
  /// In fr, this message translates to:
  /// **'Compatible Excel'**
  String get csvDescription;

  /// Description Excel
  ///
  /// In fr, this message translates to:
  /// **'Fichier Excel'**
  String get excelDescription;

  /// Description PDF
  ///
  /// In fr, this message translates to:
  /// **'Document PDF'**
  String get pdfDescription;

  /// Période d'export
  ///
  /// In fr, this message translates to:
  /// **'Période d\'export'**
  String get exportPeriod;

  /// Champs à inclure
  ///
  /// In fr, this message translates to:
  /// **'Champs à inclure'**
  String get includeFields;

  /// Options avancées
  ///
  /// In fr, this message translates to:
  /// **'Options avancées'**
  String get advancedOptions;

  /// Inclure les annulées
  ///
  /// In fr, this message translates to:
  /// **'Inclure les annulées'**
  String get includeCancelled;

  /// Inclure les terminées
  ///
  /// In fr, this message translates to:
  /// **'Inclure les terminées'**
  String get includeCompleted;

  /// Aperçu
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get preview;

  /// Liste des réservations
  ///
  /// In fr, this message translates to:
  /// **'Liste des réservations'**
  String get reservationList;

  /// Erreur chargement réservations
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des réservations'**
  String get errorLoadingReservations;

  /// Aucune réservation
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation'**
  String get noReservations;

  /// Description aucune réservation
  ///
  /// In fr, this message translates to:
  /// **'Commencez par créer votre première réservation'**
  String get noReservationsDescription;

  /// Voir
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// Modifier
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// Dupliquer
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get duplicate;

  /// Modifier la réservation
  ///
  /// In fr, this message translates to:
  /// **'Modifier la réservation'**
  String get editReservation;

  /// Supprimer la réservation
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la réservation'**
  String get deleteReservation;

  /// Informations client
  ///
  /// In fr, this message translates to:
  /// **'Informations client'**
  String get clientInformation;

  /// Informations de base
  ///
  /// In fr, this message translates to:
  /// **'Informations de Base'**
  String get basicInformation;

  /// Non spécifié
  ///
  /// In fr, this message translates to:
  /// **'Non spécifié'**
  String get notSpecified;

  /// Informations de contact
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact'**
  String get contactInformation;

  /// Aucune information de contact
  ///
  /// In fr, this message translates to:
  /// **'Aucune information de contact'**
  String get noContactInfo;

  /// Description aucune info contact
  ///
  /// In fr, this message translates to:
  /// **'Aucun email ou téléphone fourni'**
  String get noContactInfoDescription;

  /// Envoyer un email
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un email'**
  String get sendEmail;

  /// Appeler
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// Historique des modifications
  ///
  /// In fr, this message translates to:
  /// **'Historique des modifications'**
  String get modificationHistory;

  /// Aucun historique
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique'**
  String get noHistory;

  /// Description aucun historique
  ///
  /// In fr, this message translates to:
  /// **'Aucune modification enregistrée'**
  String get noHistoryDescription;

  /// Par
  ///
  /// In fr, this message translates to:
  /// **'Par'**
  String get by;

  /// Maintenant
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get now;

  /// Notes internes
  ///
  /// In fr, this message translates to:
  /// **'Notes internes'**
  String get internalNotes;

  /// Aucune note
  ///
  /// In fr, this message translates to:
  /// **'Aucune note'**
  String get noNotes;

  /// Description aucune note
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des notes pour suivre les détails'**
  String get noNotesDescription;

  /// Ajouter une note
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note'**
  String get addNote;

  /// Type de note
  ///
  /// In fr, this message translates to:
  /// **'Type de note'**
  String get noteType;

  /// Contenu de la note
  ///
  /// In fr, this message translates to:
  /// **'Contenu de la note'**
  String get noteContent;

  /// Placeholder contenu note
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre note...'**
  String get noteContentHint;

  /// Note privée
  ///
  /// In fr, this message translates to:
  /// **'Note privée'**
  String get privateNote;

  /// Supprimer la note
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la note'**
  String get deleteNote;

  /// Confirmation suppression note
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cette note ?'**
  String get deleteNoteConfirmation;

  /// Contenu note requis
  ///
  /// In fr, this message translates to:
  /// **'Le contenu de la note est requis'**
  String get noteContentRequired;

  /// Actions disponibles
  ///
  /// In fr, this message translates to:
  /// **'Actions disponibles'**
  String get availableActions;

  /// Actions principales
  ///
  /// In fr, this message translates to:
  /// **'Actions principales'**
  String get mainActions;

  /// Actions de statut
  ///
  /// In fr, this message translates to:
  /// **'Actions de statut'**
  String get statusActions;

  /// Communication
  ///
  /// In fr, this message translates to:
  /// **'Communication'**
  String get communication;

  /// Gestion
  ///
  /// In fr, this message translates to:
  /// **'Gestion'**
  String get management;

  /// Envoyer un SMS
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un SMS'**
  String get sendSms;

  /// Changer l'heure
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'heure'**
  String get changeTime;

  /// Sélectionner un client
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un client'**
  String get selectClient;

  /// Rechercher un client
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un client'**
  String get searchClient;

  /// Placeholder recherche client
  ///
  /// In fr, this message translates to:
  /// **'Nom, email ou téléphone...'**
  String get searchClientHint;

  /// Sélectionné
  ///
  /// In fr, this message translates to:
  /// **'Sélectionné'**
  String get selected;

  /// Aucun client
  ///
  /// In fr, this message translates to:
  /// **'Aucun client'**
  String get noClients;

  /// Description aucun client
  ///
  /// In fr, this message translates to:
  /// **'Commencez par ajouter des clients'**
  String get noClientsDescription;

  /// Aucun client trouvé
  ///
  /// In fr, this message translates to:
  /// **'Aucun client trouvé'**
  String get noClientsFound;

  /// Description aucun client trouvé
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres mots-clés'**
  String get noClientsFoundDescription;

  /// Nouveau client
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get newClient;

  /// Sélectionner disponibilité
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner disponibilité'**
  String get selectAvailability;

  /// Placeholder pour sélectionner une date
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectDate;

  /// Créneaux disponibles
  ///
  /// In fr, this message translates to:
  /// **'Créneaux disponibles'**
  String get availableSlots;

  /// Aucun créneau disponible
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible'**
  String get noSlotsAvailable;

  /// Description aucun créneau
  ///
  /// In fr, this message translates to:
  /// **'Essayez une autre date'**
  String get noSlotsAvailableDescription;

  /// Info disponibilité
  ///
  /// In fr, this message translates to:
  /// **'Créneaux disponibles pour {partySize} personnes'**
  String availabilityInfo(String partySize);

  /// Informations de réservation
  ///
  /// In fr, this message translates to:
  /// **'Informations de réservation'**
  String get reservationInformation;

  /// Valide
  ///
  /// In fr, this message translates to:
  /// **'Valide'**
  String get valid;

  /// Incomplet
  ///
  /// In fr, this message translates to:
  /// **'Incomplet'**
  String get incomplete;

  /// Nom du client
  ///
  /// In fr, this message translates to:
  /// **'Nom du client'**
  String get clientName;

  /// Placeholder nom client
  ///
  /// In fr, this message translates to:
  /// **'Nom complet du client'**
  String get clientNameHint;

  /// Nom client requis
  ///
  /// In fr, this message translates to:
  /// **'Le nom du client est requis'**
  String get clientNameRequired;

  /// Placeholder nombre de personnes
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes'**
  String get partySizeHint;

  /// Nombre de personnes requis
  ///
  /// In fr, this message translates to:
  /// **'Le nombre de personnes est requis'**
  String get partySizeRequired;

  /// Nombre de personnes invalide
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes invalide (1-20)'**
  String get partySizeInvalid;

  /// Placeholder email
  ///
  /// In fr, this message translates to:
  /// **'email@exemple.com'**
  String get emailHint;

  /// Email invalide
  ///
  /// In fr, this message translates to:
  /// **'Format d\'email invalide'**
  String get emailInvalid;

  /// Placeholder téléphone
  ///
  /// In fr, this message translates to:
  /// **'+1 514 123 4567'**
  String get phoneHint;

  /// Placeholder demandes spéciales
  ///
  /// In fr, this message translates to:
  /// **'Demandes spéciales du client...'**
  String get specialRequestsHint;

  /// Notes admin
  ///
  /// In fr, this message translates to:
  /// **'Notes admin'**
  String get adminNotes;

  /// Placeholder notes admin
  ///
  /// In fr, this message translates to:
  /// **'Notes internes pour l\'équipe...'**
  String get adminNotesHint;

  /// Valider
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// Effacer
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// Formulaire validé
  ///
  /// In fr, this message translates to:
  /// **'Formulaire validé'**
  String get formValidated;

  /// Erreurs formulaire
  ///
  /// In fr, this message translates to:
  /// **'Erreurs dans le formulaire'**
  String get formValidationFailed;

  /// Description création réservation
  ///
  /// In fr, this message translates to:
  /// **'Créez une nouvelle réservation pour un client'**
  String get createReservationDescription;

  /// Remplir informations
  ///
  /// In fr, this message translates to:
  /// **'Remplir informations'**
  String get fillInformation;

  /// Actions finales
  ///
  /// In fr, this message translates to:
  /// **'Actions finales'**
  String get finalActions;

  /// Sauvegarder brouillon
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder brouillon'**
  String get saveDraft;

  /// Formulaire incomplet
  ///
  /// In fr, this message translates to:
  /// **'Formulaire incomplet'**
  String get formIncomplete;

  /// Réservation créée
  ///
  /// In fr, this message translates to:
  /// **'Réservation créée avec succès'**
  String get reservationCreated;

  /// Confirmation annulation
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir annuler ?'**
  String get cancelConfirmation;

  /// Oui
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// Non
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// Gestion des Tables
  ///
  /// In fr, this message translates to:
  /// **'Gestion des Tables'**
  String get tableManagement;

  /// Créer une Table
  ///
  /// In fr, this message translates to:
  /// **'Créer une Table'**
  String get createTable;

  /// Modifier la Table
  ///
  /// In fr, this message translates to:
  /// **'Modifier la Table'**
  String get editTable;

  /// Supprimer la Table
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la Table'**
  String get deleteTable;

  /// Confirmation suppression table
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer la table {number} ?'**
  String deleteTableConfirmation(String number);

  /// Rechercher des tables
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des tables...'**
  String get searchTables;

  /// Aucune table
  ///
  /// In fr, this message translates to:
  /// **'Aucune table'**
  String get noTables;

  /// Description aucune table
  ///
  /// In fr, this message translates to:
  /// **'Commencez par créer des tables'**
  String get noTablesDescription;

  /// Aucune table trouvée
  ///
  /// In fr, this message translates to:
  /// **'Aucune table trouvée'**
  String get noTablesFound;

  /// Description aucune table trouvée
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres critères'**
  String get noTablesFoundDescription;

  /// Erreur de chargement des tables
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get errorLoadingTables;

  /// Plan du Restaurant
  ///
  /// In fr, this message translates to:
  /// **'Plan du Restaurant'**
  String get restaurantLayout;

  /// Actions sur le Plan
  ///
  /// In fr, this message translates to:
  /// **'Actions sur le Plan'**
  String get layoutActions;

  /// Modifier le Plan
  ///
  /// In fr, this message translates to:
  /// **'Modifier le Plan'**
  String get editLayout;

  /// Réinitialiser le Plan
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le Plan'**
  String get resetLayout;

  /// Erreur de chargement du plan
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement du plan'**
  String get errorLoadingLayout;

  /// Aucun plan
  ///
  /// In fr, this message translates to:
  /// **'Aucun plan'**
  String get noLayout;

  /// Description aucun plan
  ///
  /// In fr, this message translates to:
  /// **'Créez un plan pour votre restaurant'**
  String get noLayoutDescription;

  /// Plan sauvegardé
  ///
  /// In fr, this message translates to:
  /// **'Plan sauvegardé'**
  String get layoutSaved;

  /// Statistiques Générales
  ///
  /// In fr, this message translates to:
  /// **'Statistiques Générales'**
  String get generalStatistics;

  /// Statistiques par Table
  ///
  /// In fr, this message translates to:
  /// **'Statistiques par Table'**
  String get tableStatistics;

  /// Tables Disponibles
  ///
  /// In fr, this message translates to:
  /// **'Tables Disponibles'**
  String get availableTables;

  /// Tables Occupées
  ///
  /// In fr, this message translates to:
  /// **'Tables Occupées'**
  String get occupiedTables;

  /// Capacité Totale
  ///
  /// In fr, this message translates to:
  /// **'Capacité Totale'**
  String get totalCapacity;

  /// Occupation
  ///
  /// In fr, this message translates to:
  /// **'Occupation'**
  String get occupancy;

  /// Aucune statistique
  ///
  /// In fr, this message translates to:
  /// **'Aucune statistique disponible'**
  String get noStatistics;

  /// Actions en Lot
  ///
  /// In fr, this message translates to:
  /// **'Actions en Lot'**
  String get bulkActions;

  /// Liste
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get list;

  /// Plan
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get layout;

  /// Statistiques
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistics;

  /// Gestion du Menu
  ///
  /// In fr, this message translates to:
  /// **'Gestion du Menu'**
  String get menuManagement;

  /// Créer un Article
  ///
  /// In fr, this message translates to:
  /// **'Créer un Article'**
  String get createMenuItem;

  /// Modifier l'Article
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'Article'**
  String get editMenuItem;

  /// Supprimer l'Article
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'Article'**
  String get deleteMenuItem;

  /// Confirmation suppression article
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer l\'article {name} ?'**
  String deleteMenuItemConfirmation(String name);

  /// Rechercher des articles
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des articles...'**
  String get searchMenuItems;

  /// Aucun article
  ///
  /// In fr, this message translates to:
  /// **'Aucun article'**
  String get noMenuItems;

  /// Description aucun article
  ///
  /// In fr, this message translates to:
  /// **'Commencez par créer des articles'**
  String get noMenuItemsDescription;

  /// Aucun article trouvé
  ///
  /// In fr, this message translates to:
  /// **'Aucun article trouvé'**
  String get noMenuItemsFound;

  /// Description aucun article trouvé
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres critères'**
  String get noMenuItemsFoundDescription;

  /// Erreur de chargement des articles
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get errorLoadingMenuItems;

  /// Rendre Disponible
  ///
  /// In fr, this message translates to:
  /// **'Rendre Disponible'**
  String get makeAvailable;

  /// Rendre Indisponible
  ///
  /// In fr, this message translates to:
  /// **'Rendre Indisponible'**
  String get makeUnavailable;

  /// Disponibles uniquement
  ///
  /// In fr, this message translates to:
  /// **'Disponibles uniquement'**
  String get availableOnly;

  /// Toutes les catégories
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get allCategories;

  /// Articles
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get menuItems;

  /// Catégories
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categories;

  /// Images
  ///
  /// In fr, this message translates to:
  /// **'Images'**
  String get images;

  /// Créer une Catégorie
  ///
  /// In fr, this message translates to:
  /// **'Créer une Catégorie'**
  String get createCategory;

  /// Actions sur les Catégories
  ///
  /// In fr, this message translates to:
  /// **'Actions sur les Catégories'**
  String get categoryActions;

  /// Réorganiser les Catégories
  ///
  /// In fr, this message translates to:
  /// **'Réorganiser les Catégories'**
  String get reorderCategories;

  /// Aucune catégorie
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get noCategories;

  /// Description aucune catégorie
  ///
  /// In fr, this message translates to:
  /// **'Commencez par créer des catégories'**
  String get noCategoriesDescription;

  /// Gestion des Images
  ///
  /// In fr, this message translates to:
  /// **'Gestion des Images'**
  String get imageManagement;

  /// Description gestion des images
  ///
  /// In fr, this message translates to:
  /// **'Gérez les images de votre menu'**
  String get imageManagementDescription;

  /// Uploader une Image
  ///
  /// In fr, this message translates to:
  /// **'Uploader une Image'**
  String get uploadImage;

  /// Optimiser les Images
  ///
  /// In fr, this message translates to:
  /// **'Optimiser les Images'**
  String get optimizeImages;

  /// Articles Populaires
  ///
  /// In fr, this message translates to:
  /// **'Articles Populaires'**
  String get popularItems;

  /// Catégories Populaires
  ///
  /// In fr, this message translates to:
  /// **'Catégories Populaires'**
  String get popularCategories;

  /// Aucun article populaire
  ///
  /// In fr, this message translates to:
  /// **'Aucun article populaire'**
  String get noPopularItems;

  /// Aucune catégorie populaire
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie populaire'**
  String get noPopularCategories;

  /// Supprimer
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// Confirmer
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// Annuler
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// Marquer Terminé
  ///
  /// In fr, this message translates to:
  /// **'Marquer Terminé'**
  String get markCompleted;

  /// Marquer No-Show
  ///
  /// In fr, this message translates to:
  /// **'Marquer No-Show'**
  String get markNoShow;

  /// Rouvrir
  ///
  /// In fr, this message translates to:
  /// **'Rouvrir'**
  String get reopen;

  /// Restaurer
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get restore;

  /// No description provided for @specialRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes spéciales'**
  String get specialRequests;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get completed;

  /// No description provided for @noShow.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get noShow;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @restaurantConfiguration.
  ///
  /// In fr, this message translates to:
  /// **'Configuration du Restaurant'**
  String get restaurantConfiguration;

  /// No description provided for @generalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations Générales'**
  String get generalInformation;

  /// No description provided for @openingHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures d\'Ouverture'**
  String get openingHours;

  /// No description provided for @paymentSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de Paiement'**
  String get paymentSettings;

  /// No description provided for @cancellationPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique d\'Annulation'**
  String get cancellationPolicy;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @streetAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get streetAddress;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In fr, this message translates to:
  /// **'Code Postal'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get country;

  /// No description provided for @website.
  ///
  /// In fr, this message translates to:
  /// **'Site Web'**
  String get website;

  /// No description provided for @requiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get invalidEmail;

  /// No description provided for @configurationSaved.
  ///
  /// In fr, this message translates to:
  /// **'Configuration sauvegardée'**
  String get configurationSaved;

  /// No description provided for @configureOpeningHours.
  ///
  /// In fr, this message translates to:
  /// **'Configurez les heures d\'ouverture'**
  String get configureOpeningHours;

  /// No description provided for @openTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure d\'ouverture'**
  String get openTime;

  /// No description provided for @closeTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de fermeture'**
  String get closeTime;

  /// No description provided for @lunchBreak.
  ///
  /// In fr, this message translates to:
  /// **'Pause déjeuner'**
  String get lunchBreak;

  /// No description provided for @breakStart.
  ///
  /// In fr, this message translates to:
  /// **'Début de pause'**
  String get breakStart;

  /// No description provided for @breakEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de pause'**
  String get breakEnd;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @openingHoursSaved.
  ///
  /// In fr, this message translates to:
  /// **'Heures d\'ouverture sauvegardées'**
  String get openingHoursSaved;

  /// No description provided for @paymentMethods.
  ///
  /// In fr, this message translates to:
  /// **'Méthodes de Paiement'**
  String get paymentMethods;

  /// No description provided for @stripe.
  ///
  /// In fr, this message translates to:
  /// **'Stripe'**
  String get stripe;

  /// No description provided for @stripeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par carte via Stripe'**
  String get stripeDescription;

  /// No description provided for @stripePublicKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé publique Stripe'**
  String get stripePublicKey;

  /// No description provided for @stripeSecretKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé secrète Stripe'**
  String get stripeSecretKey;

  /// No description provided for @paypal.
  ///
  /// In fr, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// No description provided for @paypalDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement via PayPal'**
  String get paypalDescription;

  /// No description provided for @paypalClientId.
  ///
  /// In fr, this message translates to:
  /// **'ID client PayPal'**
  String get paypalClientId;

  /// No description provided for @cash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get cash;

  /// No description provided for @cashDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement en espèces'**
  String get cashDescription;

  /// No description provided for @card.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get card;

  /// No description provided for @cardDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par carte'**
  String get cardDescription;

  /// No description provided for @financialSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres Financiers'**
  String get financialSettings;

  /// No description provided for @depositPercentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage d\'acompte'**
  String get depositPercentage;

  /// No description provided for @taxRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de taxe'**
  String get taxRate;

  /// No description provided for @taxIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Taxe incluse'**
  String get taxIncluded;

  /// No description provided for @taxIncludedDescription.
  ///
  /// In fr, this message translates to:
  /// **'La taxe est incluse dans le prix'**
  String get taxIncludedDescription;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @paymentTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions de Paiement'**
  String get paymentTerms;

  /// No description provided for @invalidPercentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage invalide'**
  String get invalidPercentage;

  /// No description provided for @paymentSettingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de paiement sauvegardés'**
  String get paymentSettingsSaved;

  /// No description provided for @generalSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres Généraux'**
  String get generalSettings;

  /// No description provided for @refundable.
  ///
  /// In fr, this message translates to:
  /// **'Remboursable'**
  String get refundable;

  /// No description provided for @refundableDescription.
  ///
  /// In fr, this message translates to:
  /// **'Les réservations peuvent être remboursées'**
  String get refundableDescription;

  /// No description provided for @freeCancellationHours.
  ///
  /// In fr, this message translates to:
  /// **'Annulation gratuite (heures)'**
  String get freeCancellationHours;

  /// No description provided for @hours.
  ///
  /// In fr, this message translates to:
  /// **'heures'**
  String get hours;

  /// No description provided for @invalidHours.
  ///
  /// In fr, this message translates to:
  /// **'Nombre d\'heures invalide'**
  String get invalidHours;

  /// No description provided for @cancellationFeePercentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage de frais d\'annulation'**
  String get cancellationFeePercentage;

  /// No description provided for @policyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description de la politique'**
  String get policyDescription;

  /// No description provided for @cancellationRules.
  ///
  /// In fr, this message translates to:
  /// **'Règles d\'Annulation'**
  String get cancellationRules;

  /// No description provided for @addRule.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une règle'**
  String get addRule;

  /// No description provided for @noRules.
  ///
  /// In fr, this message translates to:
  /// **'Aucune règle définie'**
  String get noRules;

  /// No description provided for @rule.
  ///
  /// In fr, this message translates to:
  /// **'Règle'**
  String get rule;

  /// No description provided for @hoursBeforeReservation.
  ///
  /// In fr, this message translates to:
  /// **'Heures avant réservation'**
  String get hoursBeforeReservation;

  /// No description provided for @feePercentage.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage de frais'**
  String get feePercentage;

  /// No description provided for @cancellationPolicySaved.
  ///
  /// In fr, this message translates to:
  /// **'Politique d\'annulation sauvegardée'**
  String get cancellationPolicySaved;

  /// No description provided for @analytics.
  ///
  /// In fr, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @mainKPIs.
  ///
  /// In fr, this message translates to:
  /// **'KPIs Principaux'**
  String get mainKPIs;

  /// No description provided for @mainKPIsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Métriques clés de performance'**
  String get mainKPIsDescription;

  /// No description provided for @averageOrderValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur moyenne des commandes'**
  String get averageOrderValue;

  /// No description provided for @occupancyRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'occupation'**
  String get occupancyRate;

  /// Taux d'annulation
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'annulation'**
  String get cancellationRate;

  /// Taux de no-show
  ///
  /// In fr, this message translates to:
  /// **'Taux de no-show'**
  String get noShowRate;

  /// No description provided for @viewDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails'**
  String get viewDetails;

  /// No description provided for @loadingKPIs.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des KPIs...'**
  String get loadingKPIs;

  /// No description provided for @errorLoadingKPIs.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des KPIs'**
  String get errorLoadingKPIs;

  /// No description provided for @evolutionMetrics.
  ///
  /// In fr, this message translates to:
  /// **'Métriques d\'évolution'**
  String get evolutionMetrics;

  /// No description provided for @evolutionMetricsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Évolution des métriques dans le temps'**
  String get evolutionMetricsDescription;

  /// No description provided for @viewMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get viewMore;

  /// No description provided for @loadingEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de l\'évolution...'**
  String get loadingEvolution;

  /// No description provided for @errorLoadingEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement de l\'évolution'**
  String get errorLoadingEvolution;

  /// No description provided for @comparisonData.
  ///
  /// In fr, this message translates to:
  /// **'Données de comparaison'**
  String get comparisonData;

  /// No description provided for @comparisonDataDescription.
  ///
  /// In fr, this message translates to:
  /// **'Comparaison des performances'**
  String get comparisonDataDescription;

  /// No description provided for @comparisonDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails de comparaison'**
  String get comparisonDetails;

  /// No description provided for @loadingComparison.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de la comparaison...'**
  String get loadingComparison;

  /// No description provided for @errorLoadingComparison.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement de la comparaison'**
  String get errorLoadingComparison;

  /// No description provided for @predictions.
  ///
  /// In fr, this message translates to:
  /// **'Prédictions'**
  String get predictions;

  /// No description provided for @predictionsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prédictions basées sur les données historiques'**
  String get predictionsDescription;

  /// No description provided for @predictionDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails des prédictions'**
  String get predictionDetails;

  /// No description provided for @loadingPredictions.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des prédictions...'**
  String get loadingPredictions;

  /// No description provided for @errorLoadingPredictions.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des prédictions'**
  String get errorLoadingPredictions;

  /// No description provided for @analyticsOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble des analytics'**
  String get analyticsOverview;

  /// No description provided for @analyticsOverviewDescription.
  ///
  /// In fr, this message translates to:
  /// **'Analyse complète des performances du restaurant'**
  String get analyticsOverviewDescription;

  /// No description provided for @refreshData.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser les données'**
  String get refreshData;

  /// No description provided for @clearCache.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get clearCache;

  /// No description provided for @configureFilters.
  ///
  /// In fr, this message translates to:
  /// **'Configurer les filtres'**
  String get configureFilters;

  /// No description provided for @exportInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Export en cours...'**
  String get exportInProgress;

  /// No description provided for @cacheCleared.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé'**
  String get cacheCleared;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @saving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get saving;

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

  /// Titre de la page rapports
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reports;

  /// Filtres de rapport
  ///
  /// In fr, this message translates to:
  /// **'Filtres de rapport'**
  String get reportFilters;

  /// Description des filtres de rapport
  ///
  /// In fr, this message translates to:
  /// **'Configurez les filtres pour générer votre rapport'**
  String get reportFiltersDescription;

  /// Type de rapport
  ///
  /// In fr, this message translates to:
  /// **'Type de rapport'**
  String get reportType;

  /// Rapport personnalisé
  ///
  /// In fr, this message translates to:
  /// **'Personnalisé'**
  String get custom;

  /// Statut des réservations
  ///
  /// In fr, this message translates to:
  /// **'Statut des réservations'**
  String get reservationStatus;

  /// Options
  ///
  /// In fr, this message translates to:
  /// **'Options'**
  String get options;

  /// Inclure les no-show
  ///
  /// In fr, this message translates to:
  /// **'Inclure les no-show'**
  String get includeNoShow;

  /// Réinitialiser les filtres
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get resetFilters;

  /// Métriques du rapport
  ///
  /// In fr, this message translates to:
  /// **'Métriques du rapport'**
  String get reportMetrics;

  /// Description des métriques du rapport
  ///
  /// In fr, this message translates to:
  /// **'Métriques détaillées du rapport'**
  String get reportMetricsDescription;

  /// Réservations annulées
  ///
  /// In fr, this message translates to:
  /// **'Réservations annulées'**
  String get cancelledReservations;

  /// Réservations no-show
  ///
  /// In fr, this message translates to:
  /// **'Réservations no-show'**
  String get noShowReservations;

  /// Total des invités
  ///
  /// In fr, this message translates to:
  /// **'Total des invités'**
  String get totalGuests;

  /// Valeur moyenne des réservations
  ///
  /// In fr, this message translates to:
  /// **'Valeur moyenne des réservations'**
  String get averageReservationValue;

  /// Graphique des réservations
  ///
  /// In fr, this message translates to:
  /// **'Graphique des réservations'**
  String get reservationsChart;

  /// Description du graphique des réservations
  ///
  /// In fr, this message translates to:
  /// **'Évolution du nombre de réservations'**
  String get reservationsChartDescription;

  /// Graphique des revenus
  ///
  /// In fr, this message translates to:
  /// **'Graphique des revenus'**
  String get revenueChart;

  /// Description du graphique des revenus
  ///
  /// In fr, this message translates to:
  /// **'Évolution des revenus'**
  String get revenueChartDescription;

  /// Graphique des tables
  ///
  /// In fr, this message translates to:
  /// **'Graphique des tables'**
  String get tablesChart;

  /// Description du graphique des tables
  ///
  /// In fr, this message translates to:
  /// **'Performance par table'**
  String get tablesChartDescription;

  /// Actions du rapport
  ///
  /// In fr, this message translates to:
  /// **'Actions du rapport'**
  String get reportActions;

  /// Sauvegarder le rapport
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder le rapport'**
  String get saveReport;

  /// Exporter en PDF
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPDF;

  /// Exporter en Excel
  ///
  /// In fr, this message translates to:
  /// **'Exporter en Excel'**
  String get exportExcel;

  /// Exporter en CSV
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportCSV;

  /// Génération du rapport
  ///
  /// In fr, this message translates to:
  /// **'Génération du rapport...'**
  String get generatingReport;

  /// Erreur génération rapport
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la génération du rapport'**
  String get errorGeneratingReport;

  /// Rapport sauvegardé
  ///
  /// In fr, this message translates to:
  /// **'Rapport sauvegardé'**
  String get reportSaved;

  /// Taille moyenne des groupes
  ///
  /// In fr, this message translates to:
  /// **'Taille moyenne des groupes'**
  String get averagePartySize;
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
