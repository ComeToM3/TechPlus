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
  String get newReservation => 'Nouvelle réservation';

  @override
  String get reservations => 'Réservations';

  @override
  String get restaurantName => 'Nom du Restaurant';

  @override
  String get restaurantSlogan => 'Une expérience culinaire exceptionnelle';

  @override
  String get bookNow => 'Réserver maintenant';

  @override
  String get ourServices => 'Nos Services';

  @override
  String get onlineReservation => 'Réservation en ligne';

  @override
  String get onlineReservationDescription =>
      'Réservez votre table 24h/24 depuis notre site';

  @override
  String get diverseMenu => 'Menu varié';

  @override
  String get diverseMenuDescription =>
      'Découvrez notre carte avec des plats d\'exception';

  @override
  String get premiumService => 'Service premium';

  @override
  String get premiumServiceDescription =>
      'Un service personnalisé pour votre confort';

  @override
  String get menuPreview => 'Aperçu du Menu';

  @override
  String get viewFullMenu => 'Voir tout le menu';

  @override
  String get readyForUniqueExperience =>
      'Prêt à vivre une expérience culinaire unique ?';

  @override
  String get bookTableNow =>
      'Réservez votre table dès maintenant et découvrez notre cuisine d\'exception';

  @override
  String get bookTable => 'Réserver une table';

  @override
  String get menu => 'Menu';

  @override
  String get about => 'À propos';

  @override
  String get contact => 'Contact';

  @override
  String get copyright => '© 2025 TechPlus Restaurant. Tous droits réservés.';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get adminPanel => 'Panneau d\'administration';

  @override
  String get adminDashboard => 'Tableau de bord Admin';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get dashboardOverview => 'Vue d\'ensemble de votre restaurant';

  @override
  String get viewReservations => 'Voir les réservations';

  @override
  String get refresh => 'Actualiser';

  @override
  String get settings => 'Paramètres';

  @override
  String get errorLoadingData => 'Erreur de chargement des données';

  @override
  String get retry => 'Réessayer';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get noDataDescription =>
      'Les métriques apparaîtront ici une fois que vous aurez des réservations';

  @override
  String get mainMetrics => 'Métriques principales';

  @override
  String get todayReservations => 'Réservations du jour';

  @override
  String get todayRevenue => 'Revenus du jour';

  @override
  String get tableOccupancy => 'Occupation des tables';

  @override
  String get pendingReservations => 'Réservations en attente';

  @override
  String get additionalMetrics => 'Métriques supplémentaires';

  @override
  String get totalReservations => 'Total des réservations';

  @override
  String get totalRevenue => 'Chiffre d\'affaires total';

  @override
  String get totalCustomers => 'Total clients';

  @override
  String get newCustomers => 'Nouveaux clients';

  @override
  String get trendsAndAnalytics => 'Tendances et analyses';

  @override
  String get chartsComingSoon => 'Graphiques bientôt disponibles';

  @override
  String get tableStatus => 'État des tables';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get tableMapComingSoon => 'Plan des tables bientôt disponible';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get pending => 'En attente';

  @override
  String get cancelled => 'Annulé';

  @override
  String get total => 'Total';

  @override
  String get reservationsTodaySummary => 'Résumé des réservations du jour';

  @override
  String get occupied => 'Occupées';

  @override
  String get available => 'Disponibles';

  @override
  String get highOccupancy =>
      'Occupation élevée - Considérez ajouter des tables';

  @override
  String get goodOccupancy => 'Bonne occupation - Performance optimale';

  @override
  String get moderateOccupancy =>
      'Occupation modérée - Potentiel d\'amélioration';

  @override
  String get lowOccupancy =>
      'Occupation faible - Actions marketing recommandées';

  @override
  String get revenue => 'Revenus';

  @override
  String revenueGrowthPositive(String percentage) {
    return 'Croissance de $percentage% par rapport à la moyenne';
  }

  @override
  String revenueGrowthNegative(String percentage) {
    return 'Baisse de $percentage% par rapport à la moyenne';
  }

  @override
  String get revenueSummary => 'Analyse des revenus et tendances';

  @override
  String get topTables => 'Tables populaires';

  @override
  String get seats => 'places';

  @override
  String get topTablesSummary => 'Classement des tables les plus demandées';

  @override
  String get detailedMetrics => 'Métriques détaillées';

  @override
  String get totalTables => 'Total des Tables';

  @override
  String get averageRevenue => 'Revenus moyens';

  @override
  String get reservationCalendar => 'Calendrier des réservations';

  @override
  String get monthly => 'Mensuel';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get daily => 'Quotidien';

  @override
  String reservationsForDate(String day, String month) {
    return 'Réservations du $day/$month';
  }

  @override
  String get noReservationsForDate => 'Aucune réservation pour cette date';

  @override
  String get people => 'personnes';

  @override
  String get table => 'Table';

  @override
  String get reservationManagement => 'Gestion des réservations';

  @override
  String get filters => 'Filtres';

  @override
  String get confirmedReservations => 'Réservations confirmées';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get export => 'Exporter';

  @override
  String get close => 'Fermer';

  @override
  String get advancedFilters => 'Filtres avancés';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get searchReservations => 'Rechercher des réservations...';

  @override
  String get status => 'Statut';

  @override
  String get tables => 'Tables';

  @override
  String get dateRange => 'Période';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String selectedItems(String count) {
    return '$count éléments sélectionnés';
  }

  @override
  String get changeStatus => 'Changer le statut';

  @override
  String get assignTable => 'Assigner une table';

  @override
  String get unassignTable => 'Désassigner la table';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendReminder => 'Envoyer un rappel';

  @override
  String get sendConfirmation => 'Envoyer une confirmation';

  @override
  String get deleteSelected => 'Supprimer la sélection';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String get deleteConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette réservation ?';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportFormat => 'Format d\'export';

  @override
  String get csvDescription => 'Compatible Excel';

  @override
  String get excelDescription => 'Fichier Excel';

  @override
  String get pdfDescription => 'Document PDF';

  @override
  String get exportPeriod => 'Période d\'export';

  @override
  String get includeFields => 'Champs à inclure';

  @override
  String get advancedOptions => 'Options avancées';

  @override
  String get includeCancelled => 'Inclure les annulées';

  @override
  String get includeCompleted => 'Inclure les terminées';

  @override
  String get preview => 'Aperçu';

  @override
  String get reservationList => 'Liste des réservations';

  @override
  String get errorLoadingReservations =>
      'Erreur lors du chargement des réservations';

  @override
  String get noReservations => 'Aucune réservation';

  @override
  String get noReservationsDescription =>
      'Commencez par créer votre première réservation';

  @override
  String get view => 'Voir';

  @override
  String get edit => 'Modifier';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get editReservation => 'Modifier la réservation';

  @override
  String get deleteReservation => 'Supprimer la réservation';

  @override
  String get clientInformation => 'Informations client';

  @override
  String get basicInformation => 'Informations de Base';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get noContactInfo => 'Aucune information de contact';

  @override
  String get noContactInfoDescription => 'Aucun email ou téléphone fourni';

  @override
  String get sendEmail => 'Envoyer un email';

  @override
  String get call => 'Appeler';

  @override
  String get modificationHistory => 'Historique des modifications';

  @override
  String get noHistory => 'Aucun historique';

  @override
  String get noHistoryDescription => 'Aucune modification enregistrée';

  @override
  String get by => 'Par';

  @override
  String get now => 'Maintenant';

  @override
  String get internalNotes => 'Notes internes';

  @override
  String get noNotes => 'Aucune note';

  @override
  String get noNotesDescription => 'Ajoutez des notes pour suivre les détails';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get noteType => 'Type de note';

  @override
  String get noteContent => 'Contenu de la note';

  @override
  String get noteContentHint => 'Saisissez votre note...';

  @override
  String get privateNote => 'Note privée';

  @override
  String get deleteNote => 'Supprimer la note';

  @override
  String get deleteNoteConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette note ?';

  @override
  String get noteContentRequired => 'Le contenu de la note est requis';

  @override
  String get availableActions => 'Actions disponibles';

  @override
  String get mainActions => 'Actions principales';

  @override
  String get statusActions => 'Actions de statut';

  @override
  String get communication => 'Communication';

  @override
  String get management => 'Gestion';

  @override
  String get sendSms => 'Envoyer un SMS';

  @override
  String get changeTime => 'Changer l\'heure';

  @override
  String get selectClient => 'Sélectionner un client';

  @override
  String get searchClient => 'Rechercher un client';

  @override
  String get searchClientHint => 'Nom, email ou téléphone...';

  @override
  String get selected => 'Sélectionné';

  @override
  String get noClients => 'Aucun client';

  @override
  String get noClientsDescription => 'Commencez par ajouter des clients';

  @override
  String get noClientsFound => 'Aucun client trouvé';

  @override
  String get noClientsFoundDescription => 'Essayez avec d\'autres mots-clés';

  @override
  String get newClient => 'Nouveau client';

  @override
  String get selectAvailability => 'Sélectionner disponibilité';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get availableSlots => 'Créneaux disponibles';

  @override
  String get noSlotsAvailable => 'Aucun créneau disponible';

  @override
  String get noSlotsAvailableDescription => 'Essayez une autre date';

  @override
  String availabilityInfo(String partySize) {
    return 'Créneaux disponibles pour $partySize personnes';
  }

  @override
  String get reservationInformation => 'Informations de réservation';

  @override
  String get valid => 'Valide';

  @override
  String get incomplete => 'Incomplet';

  @override
  String get clientName => 'Nom du client';

  @override
  String get clientNameHint => 'Nom complet du client';

  @override
  String get clientNameRequired => 'Le nom du client est requis';

  @override
  String get partySizeHint => 'Nombre de personnes';

  @override
  String get partySizeRequired => 'Le nombre de personnes est requis';

  @override
  String get partySizeInvalid => 'Nombre de personnes invalide (1-20)';

  @override
  String get emailHint => 'email@exemple.com';

  @override
  String get emailInvalid => 'Format d\'email invalide';

  @override
  String get phoneHint => '+1 514 123 4567';

  @override
  String get specialRequestsHint => 'Demandes spéciales du client...';

  @override
  String get adminNotes => 'Notes admin';

  @override
  String get adminNotesHint => 'Notes internes pour l\'équipe...';

  @override
  String get validate => 'Valider';

  @override
  String get clear => 'Effacer';

  @override
  String get formValidated => 'Formulaire validé';

  @override
  String get formValidationFailed => 'Erreurs dans le formulaire';

  @override
  String get createReservationDescription =>
      'Créez une nouvelle réservation pour un client';

  @override
  String get fillInformation => 'Remplir informations';

  @override
  String get finalActions => 'Actions finales';

  @override
  String get saveDraft => 'Sauvegarder brouillon';

  @override
  String get formIncomplete => 'Formulaire incomplet';

  @override
  String get reservationCreated => 'Réservation créée avec succès';

  @override
  String get cancelConfirmation => 'Êtes-vous sûr de vouloir annuler ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get tableManagement => 'Gestion des Tables';

  @override
  String get createTable => 'Créer une Table';

  @override
  String get editTable => 'Modifier la Table';

  @override
  String get deleteTable => 'Supprimer la Table';

  @override
  String deleteTableConfirmation(String number) {
    return 'Êtes-vous sûr de vouloir supprimer la table $number ?';
  }

  @override
  String get searchTables => 'Rechercher des tables...';

  @override
  String get noTables => 'Aucune table';

  @override
  String get noTablesDescription => 'Commencez par créer des tables';

  @override
  String get noTablesFound => 'Aucune table trouvée';

  @override
  String get noTablesFoundDescription => 'Essayez avec d\'autres critères';

  @override
  String get errorLoadingTables => 'Erreur de chargement';

  @override
  String get restaurantLayout => 'Plan du Restaurant';

  @override
  String get layoutActions => 'Actions sur le Plan';

  @override
  String get editLayout => 'Modifier le Plan';

  @override
  String get resetLayout => 'Réinitialiser le Plan';

  @override
  String get errorLoadingLayout => 'Erreur de chargement du plan';

  @override
  String get noLayout => 'Aucun plan';

  @override
  String get noLayoutDescription => 'Créez un plan pour votre restaurant';

  @override
  String get layoutSaved => 'Plan sauvegardé';

  @override
  String get generalStatistics => 'Statistiques Générales';

  @override
  String get tableStatistics => 'Statistiques par Table';

  @override
  String get availableTables => 'Tables Disponibles';

  @override
  String get occupiedTables => 'Tables Occupées';

  @override
  String get totalCapacity => 'Capacité Totale';

  @override
  String get occupancy => 'Occupation';

  @override
  String get noStatistics => 'Aucune statistique disponible';

  @override
  String get bulkActions => 'Actions en Lot';

  @override
  String get list => 'Liste';

  @override
  String get layout => 'Plan';

  @override
  String get statistics => 'Statistiques';

  @override
  String get menuManagement => 'Gestion du Menu';

  @override
  String get createMenuItem => 'Créer un Article';

  @override
  String get editMenuItem => 'Modifier l\'Article';

  @override
  String get deleteMenuItem => 'Supprimer l\'Article';

  @override
  String deleteMenuItemConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer l\'article $name ?';
  }

  @override
  String get searchMenuItems => 'Rechercher des articles...';

  @override
  String get noMenuItems => 'Aucun article';

  @override
  String get noMenuItemsDescription => 'Commencez par créer des articles';

  @override
  String get noMenuItemsFound => 'Aucun article trouvé';

  @override
  String get noMenuItemsFoundDescription => 'Essayez avec d\'autres critères';

  @override
  String get errorLoadingMenuItems => 'Erreur de chargement';

  @override
  String get makeAvailable => 'Rendre Disponible';

  @override
  String get makeUnavailable => 'Rendre Indisponible';

  @override
  String get availableOnly => 'Disponibles uniquement';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get menuItems => 'Articles';

  @override
  String get categories => 'Catégories';

  @override
  String get images => 'Images';

  @override
  String get createCategory => 'Créer une Catégorie';

  @override
  String get categoryActions => 'Actions sur les Catégories';

  @override
  String get reorderCategories => 'Réorganiser les Catégories';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get noCategoriesDescription => 'Commencez par créer des catégories';

  @override
  String get imageManagement => 'Gestion des Images';

  @override
  String get imageManagementDescription => 'Gérez les images de votre menu';

  @override
  String get uploadImage => 'Uploader une Image';

  @override
  String get optimizeImages => 'Optimiser les Images';

  @override
  String get popularItems => 'Articles Populaires';

  @override
  String get popularCategories => 'Catégories Populaires';

  @override
  String get noPopularItems => 'Aucun article populaire';

  @override
  String get noPopularCategories => 'Aucune catégorie populaire';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get markCompleted => 'Marquer Terminé';

  @override
  String get markNoShow => 'Marquer No-Show';

  @override
  String get reopen => 'Rouvrir';

  @override
  String get restore => 'Restaurer';

  @override
  String get specialRequests => 'Demandes spéciales';

  @override
  String get completed => 'Terminé';

  @override
  String get noShow => 'Absent';

  @override
  String get search => 'Rechercher';

  @override
  String get phone => 'Téléphone';

  @override
  String get save => 'Enregistrer';

  @override
  String get restaurantConfiguration => 'Configuration du Restaurant';

  @override
  String get generalInformation => 'Informations Générales';

  @override
  String get openingHours => 'Heures d\'Ouverture';

  @override
  String get paymentSettings => 'Paramètres de Paiement';

  @override
  String get cancellationPolicy => 'Politique d\'Annulation';

  @override
  String get description => 'Description';

  @override
  String get address => 'Adresse';

  @override
  String get streetAddress => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get postalCode => 'Code Postal';

  @override
  String get country => 'Pays';

  @override
  String get website => 'Site Web';

  @override
  String get requiredField => 'Champ requis';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get configurationSaved => 'Configuration sauvegardée';

  @override
  String get configureOpeningHours => 'Configurez les heures d\'ouverture';

  @override
  String get openTime => 'Heure d\'ouverture';

  @override
  String get closeTime => 'Heure de fermeture';

  @override
  String get lunchBreak => 'Pause déjeuner';

  @override
  String get breakStart => 'Début de pause';

  @override
  String get breakEnd => 'Fin de pause';

  @override
  String get notes => 'Notes';

  @override
  String get openingHoursSaved => 'Heures d\'ouverture sauvegardées';

  @override
  String get paymentMethods => 'Méthodes de Paiement';

  @override
  String get stripe => 'Stripe';

  @override
  String get stripeDescription => 'Paiement par carte via Stripe';

  @override
  String get stripePublicKey => 'Clé publique Stripe';

  @override
  String get stripeSecretKey => 'Clé secrète Stripe';

  @override
  String get paypal => 'PayPal';

  @override
  String get paypalDescription => 'Paiement via PayPal';

  @override
  String get paypalClientId => 'ID client PayPal';

  @override
  String get cash => 'Espèces';

  @override
  String get cashDescription => 'Paiement en espèces';

  @override
  String get card => 'Carte';

  @override
  String get cardDescription => 'Paiement par carte';

  @override
  String get financialSettings => 'Paramètres Financiers';

  @override
  String get depositPercentage => 'Pourcentage d\'acompte';

  @override
  String get taxRate => 'Taux de taxe';

  @override
  String get taxIncluded => 'Taxe incluse';

  @override
  String get taxIncludedDescription => 'La taxe est incluse dans le prix';

  @override
  String get currency => 'Devise';

  @override
  String get paymentTerms => 'Conditions de Paiement';

  @override
  String get invalidPercentage => 'Pourcentage invalide';

  @override
  String get paymentSettingsSaved => 'Paramètres de paiement sauvegardés';

  @override
  String get generalSettings => 'Paramètres Généraux';

  @override
  String get refundable => 'Remboursable';

  @override
  String get refundableDescription =>
      'Les réservations peuvent être remboursées';

  @override
  String get freeCancellationHours => 'Annulation gratuite (heures)';

  @override
  String get hours => 'heures';

  @override
  String get invalidHours => 'Nombre d\'heures invalide';

  @override
  String get cancellationFeePercentage => 'Pourcentage de frais d\'annulation';

  @override
  String get policyDescription => 'Description de la politique';

  @override
  String get cancellationRules => 'Règles d\'Annulation';

  @override
  String get addRule => 'Ajouter une règle';

  @override
  String get noRules => 'Aucune règle définie';

  @override
  String get rule => 'Règle';

  @override
  String get hoursBeforeReservation => 'Heures avant réservation';

  @override
  String get feePercentage => 'Pourcentage de frais';

  @override
  String get cancellationPolicySaved => 'Politique d\'annulation sauvegardée';

  @override
  String get analytics => 'Analytics';

  @override
  String get mainKPIs => 'KPIs Principaux';

  @override
  String get mainKPIsDescription => 'Métriques clés de performance';

  @override
  String get averageOrderValue => 'Valeur moyenne des commandes';

  @override
  String get occupancyRate => 'Taux d\'occupation';

  @override
  String get cancellationRate => 'Taux d\'annulation';

  @override
  String get noShowRate => 'Taux de no-show';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get loadingKPIs => 'Chargement des KPIs...';

  @override
  String get errorLoadingKPIs => 'Erreur lors du chargement des KPIs';

  @override
  String get evolutionMetrics => 'Métriques d\'évolution';

  @override
  String get evolutionMetricsDescription =>
      'Évolution des métriques dans le temps';

  @override
  String get viewMore => 'Voir plus';

  @override
  String get loadingEvolution => 'Chargement de l\'évolution...';

  @override
  String get errorLoadingEvolution =>
      'Erreur lors du chargement de l\'évolution';

  @override
  String get comparisonData => 'Données de comparaison';

  @override
  String get comparisonDataDescription => 'Comparaison des performances';

  @override
  String get comparisonDetails => 'Détails de comparaison';

  @override
  String get loadingComparison => 'Chargement de la comparaison...';

  @override
  String get errorLoadingComparison =>
      'Erreur lors du chargement de la comparaison';

  @override
  String get predictions => 'Prédictions';

  @override
  String get predictionsDescription =>
      'Prédictions basées sur les données historiques';

  @override
  String get predictionDetails => 'Détails des prédictions';

  @override
  String get loadingPredictions => 'Chargement des prédictions...';

  @override
  String get errorLoadingPredictions =>
      'Erreur lors du chargement des prédictions';

  @override
  String get analyticsOverview => 'Vue d\'ensemble des analytics';

  @override
  String get analyticsOverviewDescription =>
      'Analyse complète des performances du restaurant';

  @override
  String get refreshData => 'Actualiser les données';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get configureFilters => 'Configurer les filtres';

  @override
  String get exportInProgress => 'Export en cours...';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get apply => 'Appliquer';

  @override
  String get saving => 'Enregistrement...';

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
  String get systemOperational => 'Système opérationnel';

  @override
  String get backendFrontendConfigured => 'Backend et Frontend configurés';

  @override
  String get toggleTheme => 'Basculer le thème';

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

  @override
  String get reports => 'Rapports';

  @override
  String get reportFilters => 'Filtres de rapport';

  @override
  String get reportFiltersDescription =>
      'Configurez les filtres pour générer votre rapport';

  @override
  String get reportType => 'Type de rapport';

  @override
  String get custom => 'Personnalisé';

  @override
  String get reservationStatus => 'Statut des réservations';

  @override
  String get options => 'Options';

  @override
  String get includeNoShow => 'Inclure les no-show';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get reportMetrics => 'Métriques du rapport';

  @override
  String get reportMetricsDescription => 'Métriques détaillées du rapport';

  @override
  String get cancelledReservations => 'Réservations annulées';

  @override
  String get noShowReservations => 'Réservations no-show';

  @override
  String get totalGuests => 'Total des invités';

  @override
  String get averageReservationValue => 'Valeur moyenne des réservations';

  @override
  String get reservationsChart => 'Graphique des réservations';

  @override
  String get reservationsChartDescription =>
      'Évolution du nombre de réservations';

  @override
  String get revenueChart => 'Graphique des revenus';

  @override
  String get revenueChartDescription => 'Évolution des revenus';

  @override
  String get tablesChart => 'Graphique des tables';

  @override
  String get tablesChartDescription => 'Performance par table';

  @override
  String get reportActions => 'Actions du rapport';

  @override
  String get saveReport => 'Sauvegarder le rapport';

  @override
  String get exportPDF => 'Exporter en PDF';

  @override
  String get exportExcel => 'Exporter en Excel';

  @override
  String get exportCSV => 'Exporter en CSV';

  @override
  String get generatingReport => 'Génération du rapport...';

  @override
  String get errorGeneratingReport => 'Erreur lors de la génération du rapport';

  @override
  String get reportSaved => 'Rapport sauvegardé';

  @override
  String get averagePartySize => 'Taille moyenne des groupes';
}
